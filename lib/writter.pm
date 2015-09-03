package lib::writter ;

use strict;
use warnings ;
use Exporter ;
use Carp ;

use Data::Dumper ;
use JSON ;

use vars qw($VERSION @ISA @EXPORT %EXPORT_TAGS);

our $VERSION = "1.0";
our @ISA = qw(Exporter);
our @EXPORT = qw( write_csv_skel );
our %EXPORT_TAGS = ( ALL => [qw( write_csv_skel )] );

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

=head2 METHOD write_csv_skel

	## Description : prepare and write csv output file
	## Input : $csv_file, $rows
	## Output : $csv_file
	## Usage : my ( $csv_file ) = write_csv_skel( $csv_file, $rows ) ;
	
=cut
## START of SUB
sub write_csv_skel {
	## Retrieve Values
    my $self = shift ;
    my ( $csv_file, $rows ) = @_ ;
    
    my $ocsv = lib::csv::new() ;
	my $csv = $ocsv->get_csv_object("\t") ;
	$ocsv->write_csv_from_arrays($csv, $$csv_file, $rows) ;
    
    return($csv_file) ;
}
## END of SUB

=head2 METHOD write_xls_skel

	## Description : prepare and write xls output file
	## Input : $xls_file, $rows
	## Output : $xls_file
	## Usage : my ( $xls_file ) = write_xls_skel( $xls_file, $rows ) ;
	
=cut
## START of SUB
sub write_xls_skel {
	## Retrieve Values
    my $self = shift ;
    my ( $out_xls, $mzs, $pcs, $pcgroups ) = @_ ;
    
    my $results = undef ;
    my $i = 0 ;
    
    open(XLS, '>:utf8', "$$out_xls") or die "Cant' create the file $$out_xls\n" ;
    print XLS "SUBMITTED_MASS\tPCGROUP\tMASSBANK_ID\tSPECTRA_TITLE\tFORMULA\tCPD_MW\tSCORE\tCOMMENTS\n" ;
    $results = ['SUBMITTED_MASS','PCGROUP','MASSBANK_ID','tSPECTRA_TITLE','FORMULA','CPD_MW','SCORE','COMMENTS'] ;
    
    foreach my $pc (@{$pcs}) {
    	
    	if ($pcgroups->{$pc}) {
    		
    		if ($pcgroups->{$pc}{annotation}{num_res}) {
    			my $result = undef ;
    			if ($pcgroups->{$pc}{annotation}{num_res} == 0) {
    				$result = $mzs->[$i]."\t".$pc."\t".'NA'."\t".'NA'."\t".'NA'."\t".'NA'."\t"."0"."\t"."No_result_found_on_MassBank" ;
    				print XLS "$mzs->[$i]\t$pc\tNA\tNA\tNA\tNA\t0\tNo_result_found_on_MassBank\n" ;
    			}
    			elsif ($pcgroups->{$pc}{annotation}{num_res} > 0) {
    				
    				my @entries = @{$pcgroups->{$pc}{annotation}{res} } ;
    				
    				foreach my $entry (@entries) {
    					## print submitted mass
	    				if ($mzs->[$i]) { 	print XLS "$mzs->[$i]\t" ; $result .= $mzs->[$i]."\t" ; 	}
	    				else {				print XLS "$mzs->[$i]\t" ; }
	    				## print submitted pcgroup
	    				if ($pc ) { 	 print XLS "$pc\t" ; $result .= $pc."\t" ; 	} ## pb de clean de la derniere ligne !!!!!!
	    				else {		print XLS "$pc\t" ; }
	    				## print massbank id
	    				if ($entry->{'id'}) { 	print XLS "$entry->{'id'}\t" ; $result .= $entry->{'id'}."\t" ; 	}
	    				else {				print XLS "NA\t" ; }
	    				## print massbank title
	    				if ($entry->{'title'}) { 	print XLS "$entry->{'title'}\t" ; $result .= $entry->{'title'}."\t" ; 	}
	    				else {				print XLS "NA\t" ; }
	    				## print massbank formula
	    				if ($entry->{'formula'}) { 	print XLS "$entry->{'formula'}\t" ; $result .= $entry->{'formula'}."\t" ; 	}
	    				else {				print XLS "NA\t" ; }
	    				## print massbank exactMass
	    				if ($entry->{'exactMass'}) { 	print XLS "$entry->{'exactMass'}\t" ; $result .= $entry->{'exactMass'}."\t" ; 	}
	    				else {				print XLS "NA\t" ; }
	    				## print massbank title
	    				if ($entry->{'score'}) { 	print XLS "$entry->{'score'}\t" ; $result .= $entry->{'score'}."\t" ; 	}
	    				else {				print XLS "NA\n" ; }
	    				## print massbank comment
	    				print XLS "NA\n" ; $result .= "NA\n" ;
    				} ## End foreach entries
    			}
    		}
    	}
    	else {
    		croak "No such pc group exists in your pcgroups object - No xls written\n" ;
    	}
    	$i++ ;
    	
    } ## End foreach pcs
    
	close(XLS) ;
    return($results) ;
}
## END of SUB

=head2 METHOD write_json_skel

	## Description : prepare and write json output file
	## Input : $json_file, $scalar
	## Output : $json_file
	## Usage : my ( $json_file ) = write_json_skel( $csv_file, $scalar ) ;
	
=cut
## START of SUB
sub write_json_skel {
	## Retrieve Values
    my $self = shift ;
    my ( $json_file, $scalar ) = @_ ;
    
    my $utf8_encoded_json_text = encode_json $scalar ;
    open(JSON, '>:utf8', "$$json_file") or die "Cant' create the file $$json_file\n" ;
    print JSON $utf8_encoded_json_text ;
    close(JSON) ;
    
    return($json_file) ;
}
## END of SUB



1 ;


__END__

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

 perldoc writter.pm

=head1 Exports

=over 4

=item :ALL is ...

=back

=head1 AUTHOR

Franck Giacomoni E<lt>franck.giacomoni@clermont.inra.frE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 VERSION

version 1 : 14 / 08 / 2015

version 2 : ??

=cut