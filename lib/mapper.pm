package lib::mapper ;

use strict;
use warnings ;
use Exporter ;
use Carp ;

use Data::Dumper ;

use vars qw($VERSION @ISA @EXPORT %EXPORT_TAGS);

our $VERSION = "1.0";
our @ISA = qw(Exporter);
our @EXPORT = qw( get_pcgroup_list get_pcgroups set_massbank_matrix_object add_massbank_matrix_to_input_matrix);
our %EXPORT_TAGS = ( ALL => [qw( get_pcgroup_list get_pcgroups set_massbank_matrix_object add_massbank_matrix_to_input_matrix)] );

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
	    	push (@{$pcgroups{$pc}->{'into'}}, $ints->[$i]) if ($ints->[$i]) ; ## map into by pcgroup

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