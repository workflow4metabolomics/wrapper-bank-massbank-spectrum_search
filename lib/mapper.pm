package lib::mapper ;

use strict;
use warnings ;
use Exporter ;
use Carp ;

use Data::Dumper ;

use vars qw($VERSION @ISA @EXPORT %EXPORT_TAGS);

our $VERSION = "1.0";
our @ISA = qw(Exporter);
our @EXPORT = qw( add_min_max_for_pcgroup_res get_massbank_records_by_chunk compute_ids_from_pcgroups_res filter_pcgroup_res get_pcgroup_list get_pcgroups set_massbank_matrix_object add_massbank_matrix_to_input_matrix map_pc_to_generic_json);
our %EXPORT_TAGS = ( ALL => [qw( add_min_max_for_pcgroup_res get_massbank_records_by_chunk compute_ids_from_pcgroups_res filter_pcgroup_res get_pcgroup_list get_pcgroups set_massbank_matrix_object add_massbank_matrix_to_input_matrix map_pc_to_generic_json)] );

=head1 NAME

My::Module - An example module

=head1 SYNOPSIS

    use My::Module;
    my $object = My::Module->new();
    print $object->as_string;

=head1 DESCRIPTION

This module does not really exist, it
was made for the sole purpose of
demonstrating how POD works.

=head1 METHODS

Methods are :

=head2 METHOD new

	## Description : new
	## Input : $self
	## Ouput : bless $self ;
	## Usage : new() ;

=cut

sub new {
    ## Variables
    my $self={};
    bless($self) ;
    return $self ;
}
### END of SUB

=head2 METHOD get_pcgroups

	## Description : get and prepare pcgroup features (mzs, into, names) from input cvs parser
	## Input : $pcs, $mzs, $ints, $names
	## Output : $pcgroups
	## Usage : my ( $pcgroups ) = get_pcgroups( $pcs, $mzs, $ints, $names ) ;
	
=cut
## START of SUB
sub get_pcgroups {
    my $self = shift;
    my ( $pcs, $mzs, $ints ) = @_;
    
    my %pcgroups = () ;
    my $i = 0 ;
    
    ## Warn diff matrix dimension :
    my $num_pcs = scalar(@{$pcs}) ;
    my $num_mzs = scalar(@{$mzs}) ;
    my $num_ints = scalar(@{$ints}) ;
    
    if ( ($num_pcs == $num_mzs ) and ( $num_mzs == $num_ints ) ) {
		my @pcs = @{$pcs} ;
    	
    	foreach my $pc (@{$pcs}) {
	    	
	    	if ( ! $pcgroups{$pc} ) { $pcgroups{$pc}->{'id'} = $pc ;	$pcgroups{$pc}->{'annotation'} = {} ; $pcgroups{$pc}->{'massbank_ids'} = [] ; }
	    	
	    	push (@{$pcgroups{$pc}->{'mzmed'}}, $mzs->[$i]) if ($mzs->[$i]) ; ## map mzs by pcgroup

	    	if ($ints->[$i] > 0 ) { 	push (@{$pcgroups{$pc}->{'into'}}, $ints->[$i])  ; ## map into by pcgroup
	    	}
	    	elsif ($ints->[$i] == 0) {
	    		push (@{$pcgroups{$pc}->{'into'}}, $ints->[$i])  ; ## map into by pcgroup even value is 0
	    	}
	    	else {
	    		warn "Undefined value found in pcgroups array\n" ;
	    	}
	    	$i++ ;
	    }
    }
    else {
    	warn "The different ARRAYS (pcs, mzs, ints) doesn't have the same size : mapping is not possible \n!!"
    }
    return (\%pcgroups) ;
}
### END of SUB

=head2 METHOD get_pcgroup_list

	## Description : get and prepare unik pcgroup list from input cvs parsed list
	## Input : $pcs
	## Output : $list
	## Usage : my ( $list ) = get_pcgroup_list( $pcs ) ;
	
=cut
## START of SUB
sub get_pcgroup_list {
	my $self = shift;
    my ( $pcs ) = @_;
    
    my @pcgroup_list = () ;
    my $i = 0 ;
    
    my %hash = map { $_, 1 } @{$pcs} ;
 	@pcgroup_list = keys %hash;
 	@pcgroup_list = sort { $a <=> $b } @pcgroup_list ;
	
	return (\@pcgroup_list) ;
}

### END of SUB


=head2 METHOD filter_pcgroup_res

	## Description : This method filter the results returned by massbank with a user defined score threshold
	## Input : $pcgroups, $threshold
	## Output : $pcgroups
	## Usage : my ( $pcgroups ) = filter_pcgroup_res ( $pcgroups, $threshold ) ;
	
=cut
## START of SUB
sub filter_pcgroup_res {
    ## Retrieve Values
    my $self = shift ;
    my ( $pcgroups, $threshold ) = @_ ;

    my %temp = () ;
    
    if (!defined $threshold) {
    	$threshold = 0.5 ; ## default value
    }

	if ( (defined $pcgroups) and (defined $threshold) ) {
		%temp = %{$pcgroups} ;
		
		foreach my $pc (keys %temp) {
			
			if ( $temp{$pc}{'annotation'}{'num_res'} > 0 ) {
					my @filtered_annot = reverse(grep { $_->{'score'} >= $threshold if ($_->{'score'})  } @{$temp{$pc}{'annotation'}{'res'}}) ;
					my $new_num_res = scalar (@filtered_annot) ;
					my @ids = () ;
					foreach (@filtered_annot) { push (@ids, $_->{'id'} ) }
					$temp{$pc}{'annotation'}{'res'} =\@filtered_annot ;
					$temp{$pc}{'annotation'}{'num_res'}  = $new_num_res ;
					$temp{$pc}{'massbank_ids'} = \@ids ;
			}
			else {
				warn "No result found for this pcgroup\n" ;
			}
		}
	} ## End IF
	else {
		warn "No pcgroup and threshold defined\n" ;
	}
    return (\%temp) ;
}
### END of SUB

=head2 METHOD add_min_max_for_pcgroup_res

	## Description : This method add min / max value for each mzmed contained in pcgroup
	## Input : $pcgroups
	## Output : $pcgroups
	## Usage : my ( $pcgroups ) = add_min_max_for_pcgroup_res ( $pcgroups ) ;
	
=cut
## START of SUB
sub add_min_max_for_pcgroup_res {
    ## Retrieve Values
    my $self = shift ;
    my ( $pcgroups, $delta ) = @_ ;

    my %temp = () ;
    
    if (!defined $delta) {
    	$delta = 0.01 ; ## default value
    }

	if ( defined $pcgroups) {
		%temp = %{$pcgroups} ;

		foreach my $pc (keys %temp) {
			my %mz_intervales = () ;
			if ( $temp{$pc}{'mzmed'} ) {
				my @temp = @{$temp{$pc}{'mzmed'}} ;
				foreach my $mz (@temp) {
					my ($min, $max) = lib::mapper::new->min_and_max_from_double_with_delta($mz, 'Da', $delta);
					$mz_intervales{$mz} = {'min' => $min, 'max' => $max } ;
				}
			}
			else {
				warn "No mzmed found for this pcgroup\n" ;
			}
			$temp{$pc}{'intervales'} = \%mz_intervales ;
			
		}
	} ## End IF
	else {
		warn "No pcgroup and threshold defined\n" ;
	}
    return (\%temp) ;
}
### END of SUB



=head2 METHOD min_and_max_from_double_with_delta

	## Description : returns the minimum and maximum double according to the delta
	## Input : \$double, \$delta_type, \$delta
	## Output : \$min, \$max
	## Usage : ($min, $max)= min_and_max_from_double_with_delta($double, $delta_type, $mz_delta) ;
	
=cut
## START of SUB
sub min_and_max_from_double_with_delta {
	## Retrieve Values
    my $self = shift ;
    my ( $double, $delta_type, $delta ) = @_ ;
    my ( $min, $max ) = ( undef, undef ) ;
    
	if ($delta_type eq 'ppm'){
		$min = $double - ($delta * 10**-6 * $double);
		$max = $double + ($delta * 10**-6 * $double) + 0.0000000001; ## it's to included the maximum value in the search
	}
	elsif ($delta_type eq 'Da'){
		$min = $double - $delta;
		$max = $double + $delta + 0.0000000001; ## it's to included the maximum value in the search
	}
	else {	croak "The double delta type '$delta_type' isn't a valid type !\n" ;	}
	
    return($min, $max) ;
}
## END of SUB


=head2 METHOD compute_ids_from_pcgroups_res

	## Description : get all ids returned by massbank with sent queries and keep only unique ones.
	## Input : $pcgroups
	## Output : $unique_ids
	## Usage : my ( $unique_ids ) = compute_ids_from_pcgroups_res ( $pcgroups ) ;
	
=cut
## START of SUB
sub compute_ids_from_pcgroups_res {
    ## Retrieve Values
    my $self = shift ;
    my ( $pcgroups ) = @_;
    my ( @ids, @unique ) = ( (), () ) ;
    
    if ( defined $pcgroups ) {
		
		foreach my $pc ( keys %{$pcgroups} ) {
			if ( $pcgroups->{$pc}{'massbank_ids'} ) {
				push (@ids , @{ $pcgroups->{$pc}{'massbank_ids'} } ) ;
			}
		}
		@unique = do { my %seen; grep { !$seen{$_}++ } @ids };
		@unique = sort { $a cmp $b } @unique;
	}
    return (\@unique) ;
}
### END of SUB


=head2 METHOD get_massbank_records_by_chunk

	## Description : get massbank records from a complete list but send queries chunk by chunk.
	## Input : $ids, $chunk_size
	## Output : $records
	## Usage : my ( $records ) = get_massbank_records_by_chunk ( $ids, $chunk_size ) ;
	
=cut
## START of SUB
sub get_massbank_records_by_chunk {
    ## Retrieve Values
    my $self = shift ;
    my ( $server, $ids, $chunk_size ) = @_;
    my ( @records, @sent_ids ) = ( (), () ) ;
    
    my $current = 0 ;
    my $pos = 1 ; 
    my @temp_ids = () ;
    
    my $num_ids = scalar(@{$ids}) ;
#    print "The number of given massbank ids is: $num_ids\n" ;
    
    foreach my $id (@{$ids}) {
    	$current++ ;
#    	print "$id - - $current/$num_ids) - - $pos \n" ;
    	
    	if (  ($current == $num_ids) or ($pos == $chunk_size)  ) {
#    		print "Querying Massbank with...\n" ;
    		push (@temp_ids, $id) ;
    		## send query
    		my $omassbank = lib::massbank_api->new() ;
			my ($osoap) = $omassbank->selectMassBank($server) ;
			my ($records) = $omassbank->getRecordInfo($osoap, \@temp_ids) ;
			push (@records, @{$records}) ;
    		
    		@temp_ids = () ; 
    		$pos = 0 ;
    	}
    	elsif ($pos < $chunk_size) {
#    		print "store...\n";
    		push (@temp_ids, $id) ;
    		$pos ++ ;
    	}
    	else {
    		warn "Something goes wrong : out of range\n"
    	}
    	
    	
    }
    my $num_records = scalar(@records) ;
#    print "The number of received massbank records is: $num_records\n" ;
    return (\@records) ;
}
### END of SUB

=head2 METHOD set_massbank_matrix_object

	## Description : build the massbank_row under its ref form
	## Input : $header, $init_mzs, $entries
	## Output : $massbank_matrix
	## Usage : my ( $massbank_matrix ) = set_lm_matrix_object( $header, $init_mzs, $entries ) ;
	
=cut
## START of SUB
sub set_massbank_matrix_object {
	## Retrieve Values
    my $self = shift ;
    my ( $header, $init_pcs, $pcgroups ) = @_ ;
    
    my @massbank_matrix = () ;
    
    if ( defined $header ) {
    	my @headers = () ;
    	push @headers, $header ;
    	push @massbank_matrix, \@headers ;
    }
    ## map foreach listed pc group the massbank ids 
    foreach my $pc ( @{$init_pcs} ) {
		my @ids = () ;
		if ($pcgroups->{$pc}) {
			my @massbank_ids = @{$pcgroups->{$pc}{'massbank_ids'} } ;
			my $nb_ids = $pcgroups->{$pc}{'annotation'}{'num_res'} ;
			
			my $massbank_ids_string = undef ;
			
			## manage empty array
			if (!defined $nb_ids) { carp "The number of massbank ids is not defined\n" ; }
			elsif ( $nb_ids > 0 ) { $massbank_ids_string = join('|', @massbank_ids ) ; 	}
			elsif ( $nb_ids == 0 ) { $massbank_ids_string = 'No_result_found_on_MassBank' ; }
			
			push (@ids, $massbank_ids_string) ;
			push (@massbank_matrix, \@ids) ;
		}
		else{
			carp "This pc group number doesn't exist for mapping\n" ;
		}
    	
    }
    return(\@massbank_matrix) ;
}
## END of SUB

=head2 METHOD add_massbank_matrix_to_input_matrix

	## Description : build a full matrix (input + lm column)
	## Input : $input_matrix_object, $massbank_matrix_object
	## Output : $output_matrix_object
	## Usage : my ( $output_matrix_object ) = add_massbank_matrix_to_input_matrix( $input_matrix_object, $massbank_matrix_object ) ;
	
=cut
## START of SUB
sub add_massbank_matrix_to_input_matrix {
	## Retrieve Values
    my $self = shift ;
    my ( $input_matrix_object, $massbank_matrix_object ) = @_ ;
    
    my @output_matrix_object = () ;
    my $index_row = 0 ;
    
    foreach my $row ( @{$input_matrix_object} ) {
    	my @init_row = @{$row} ;
    	
    	if ( $massbank_matrix_object->[$index_row] ) {
    		my $dim = scalar(@{$massbank_matrix_object->[$index_row]}) ;
    		
    		if ($dim > 1) { warn "the add method can't manage more than one column\n" ;}
    		my $lm_col =  $massbank_matrix_object->[$index_row][$dim-1] ;

   		 	push (@init_row, $lm_col) ;
	    	$index_row++ ;
    	}
    	push (@output_matrix_object, \@init_row) ;
    }
    return(\@output_matrix_object) ;
}
## END of SUB

=head2 METHOD map_res_to_generic_json

	## Description : build json structure with all massbank results
	## Input : $mzs, $pcs, $pcgroups_results
	## Output : $json_scalar
	## Usage : my ( $json_scalar ) = add_massbank_matrix_to_input_matrix( $mzs, $pcs, $pcgroups_results ) ;
	
=cut
## START of SUB
sub map_pc_to_generic_json {
    my $self = shift;
    my ( $pcs, $pcgroups ) = @_ ;
    

    my @json_scalar = () ;
    ## JSON DESIGN
#   [
#		{ "searchResult": {  
#			"results": [ { "formula":"C22H22N4O5",  "id":"JP006651", "title":"BENZAMIDE; EI-B; MS",  "score":"0.933207676010", "exactMass":"422.15902"}, ... ],
#			"numResults":20 },
#		"id":"comp0" }, ...
#	]
    
    foreach my $pc (@{$pcs}) {
		
    	my $pc_res = {} ;
    	my $num_res = undef ;
    	
    	if ($pcgroups->{$pc}) {
    		$num_res = $pcgroups->{$pc}{'annotation'}{'num_res'} if ( $pcgroups->{$pc}{'annotation'}{'num_res'} >= 0 ) ;
    		$pc_res->{'searchResult'}{'numResults'} = $num_res ;
    		my @results = @{$pcgroups->{$pc}{'annotation'}{'res'}} if ( $pcgroups->{$pc}{'annotation'}{'res'} );
    		$pc_res->{'searchResult'}{'results'} = \@results ;
    		$pc_res->{'id'} = $pc if ( $pc >= 0 ); ## id is a pc group_id for the moment
    		
    		push (@json_scalar, $pc_res) ;
    	}
    	else {
    		warn "The pc group $pc doesn't exist in results !" ;
    	}    	
    }
    
	return(\@json_scalar) ;
}
## END of SUB


=head2 METHOD mapGroupsWithRecords

	## Description : map records with pcgroups mz to adjust massbank id annotations
	## Input : $pcgroups, $records
	## Output : $pcgroups
	## Usage : my ( $var4 ) = mapGroupsWithRecords ( $$pcgroups, $records ) ;
	
=cut
## START of SUB
sub mapGroupsWithRecords {
    ## Retrieve Values
    my $self = shift ;
    my ( $pcgroups, $records ) = @_;

    my %temp = () ;
    my (%intervales, @annotation_ids) = ( (), ()  ) ;
    
    if ( ( defined $pcgroups ) and ( defined $records )  ) {
    	
		%temp = %{$pcgroups} ;
		my @real_ids ;
		foreach my $pc (keys %temp) {

			if ( $temp{$pc}{'intervales'} ) { %intervales = %{$temp{$pc}{'intervales'}} ; }
			else { warn "Cant't find any intervale values\n" ; }
			if ( $temp{$pc}{'massbank_ids'} ) { @annotation_ids = @{$temp{$pc}{'massbank_ids'}} ; }
			else { warn "Cant't find any massbank id values\n" ; }
			
#			print Dumper %intervales;
#			print Dumper @annotation_ids ;
			
			## map with intervales 
			foreach my $mz (keys %intervales) {
				my ( $min, $max ) = ( $intervales{$mz}{'min'}, $intervales{$mz}{'max'} ) ;
				
				foreach my $id (@annotation_ids) {
#					print "Analyse mzs of id: $id...\n" ;
					if ($records->{$id}) {
						foreach my $peak_mz (@{$records->{$id}}) {
							my $record_mz = $peak_mz->{'mz'} ;
							if ( ($record_mz > $min ) and ($record_mz < $max) ){
								push(@real_ids, $id) ;
#								print "$mz - - $id\n" ;
							}
							else {
								next ;
							}
						} ## foreach
					}
					else {
						warn "The id $id seems to be not present in getting records\n" ;
						next ;
					}
				}
				my @temp = @real_ids ;
				$temp{$pc}{'enrich_annotation'}{$mz} = \@temp ;
				@real_ids = () ;
			}
		}
    }
    else {
    	warn"Can't find record or pcgroup data\n" ;
    }
    
    return (\%temp) ;
}
### END of SUB


1 ;


__END__

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

 perldoc XXX.pm

=head1 Exports

=over 4

=item :ALL is ...

=back

=head1 AUTHOR

Franck Giacomoni E<lt>franck.giacomoni@clermont.inra.frE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 VERSION

version 1 : xx / xx / 201x

version 2 : ??

=cut