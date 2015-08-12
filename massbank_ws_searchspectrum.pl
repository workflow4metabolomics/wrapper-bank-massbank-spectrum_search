#!perl

## script  : XXX.pl

## Notes :
#	-> think about input csv file without intensities ! 
#   -> THINK ABOUT Ids importance in input format

#=============================================================================
#                              Included modules and versions
#=============================================================================
## Perl modules
use strict ;
use warnings ;
use Carp qw (cluck croak carp) ;

use threads;
use threads::shared;
use Thread::Queue;

use Data::Dumper ;
use Getopt::Long ;
use FindBin ; ## Allows you to locate the directory of original perl script

## Specific Perl Modules (PFEM)
use lib $FindBin::Bin ;
my $binPath = $FindBin::Bin ;
use lib::csv  qw( :ALL ) ;
use lib::conf  qw( :ALL ) ;

## Dedicate Perl Modules (Home made...)
use lib::massbank_api qw( :ALL ) ;
use lib::threader qw(:ALL) ;
use lib::mapper qw(:ALL) ;



## Initialized values
my ($help, $mzs_file, $col_id, $col_mz, $col_int, $col_pcgroup, $line_header ) = ( undef, undef, undef, undef, undef,undef, undef ) ;
my $mass = undef ;
my ($ion_mode, $instruments, $max, $unit, $tol, $cutoff) = ( undef, undef, undef, undef, undef, undef ) ;
my ($out_json, $out_csv, $out_xls ) = ( undef, undef, undef ) ;

## Local values :
my $server = 'JP' ;
my $threading_threshold = 6 ;

#=============================================================================
#                                Manage EXCEPTIONS
#=============================================================================
&GetOptions ( 	"help|h"     	=> \$help,       # HELP
				"masses:s"		=> \$mzs_file,
				"col_id:i"		=> \$col_id, # A voir
				"col_mz:i"		=> \$col_mz,
				"col_int:i"		=> \$col_int,
				"col_pcgroup:i"	=> \$col_pcgroup,
				"lineheader:i"	=> \$line_header,
				"mode:s"		=> \$ion_mode, 
				"instruments:s@"	=> \$instruments, 
				"max:i"			=> \$max, 
				"unit:s"		=> \$unit, 
				"tolerance:f"	=> \$tol, 
				"cutoff:f"		=> \$cutoff,
				"server:s"		=> \$server, ## by default JP
				"json:s"		=> \$out_json,
				"xls:s"			=> \$out_xls,
				"csv:s"			=> \$out_csv,
            ) ;
         
## if you put the option -help or -h function help is started
if ( defined($help) ){ &help ; }

#=============================================================================
#                                MAIN SCRIPT
#=============================================================================

## -------------- Conf file ------------------------ :
my ( $CONF ) = ( undef ) ;
foreach my $conf ( <$binPath/*.cfg> ) {
	my $oConf = lib::conf::new() ;
	$CONF = $oConf->as_conf($conf) ;
}

## -------------- HTML template file ------------------------ :
foreach my $html_template ( <$binPath/*.tmpl> ) { $CONF->{'HTML_TEMPLATE'} = $html_template ; }

## Main variables :
my ($pcs, $mzs, $ids, $into) = (undef, undef, undef, undef) ;

## manage a list of masses separate by space only 
if ( ( defined $mass ) and ( $mass ne "" ) and ( $mass =~ /[\s]+/ ) ) {
} ## END IF
elsif ( ( defined $mass ) and ( $mass ne "" ) and ( $mass > 0 ) ) {
} ## END IF
## manage csv file containing list of masses (every thing is manage in jar)
elsif ( ( defined $mzs_file ) and ( $mzs_file ne "" ) and ( -e $mzs_file ) ) {
	
	## parse csv ids and masses
	my $is_header = undef ;
	my $ocsv = lib::csv->new() ;
	my $csv = $ocsv->get_csv_object( "\t" ) ;
	if ( ( defined $line_header ) and ( $line_header > 0 ) ) { $is_header = 'yes' ;    }
	$pcs = $ocsv->get_value_from_csv( $csv, $mzs_file, $col_pcgroup, $is_header ) ; ## retrieve pc values on csv
	$mzs = $ocsv->get_value_from_csv( $csv, $mzs_file, $col_mz, $is_header ) ; ## retrieve mz values on csv
	$ids = $ocsv->get_value_from_csv( $csv, $mzs_file, $col_id, $is_header ) ; ## retrieve ids values on csv
	$into = $ocsv->get_value_from_csv( $csv, $mzs_file, $col_int, $is_header ) if ( defined $col_int ); ## retrieve into values on csv // optionnal in input files
	
	## manage input file with no into colunm / init into with a default value of 10
	if ( !defined $col_int ) {
		my $nb_ids = scalar(@{$ids}) ;
		my @intos = map {10} (0..$nb_ids) ;
		my $nb_intos = scalar(@intos) ;
		if ($nb_intos == $nb_ids) { $into = \@intos ;	}
	}
	
	
	## Build pcgroups with their features :
	my $omap = lib::mapper->new() ;
	my $pcgroups = $omap->get_pcgroups($pcs, $mzs, $into, $ids ) ;
	my $pcgroup_list = $omap->get_pcgroup_list($pcs ) ;
	
#	print Dumper $pcgroups ;
	
	
	my $pc_num = scalar(@{$pcgroup_list}) ;
	
	## manage a list of query pc_group dependant:
	if ($pcgroups) {
		
		if ($pc_num > $CONF->{'THREADING_THRESHOLD'}) {
			print $server."\n" ;
			print "\n------  ** ** ** Using multithreading mode ** ** ** --------\n\n" ;
			my $time_start = time ;
			
			our $NBTHREADS = $CONF->{'THREADING_THRESHOLD'} ;

#			use constant THREADS => 6 ;
			my $Qworks = Thread::Queue->new();
			my @threads = () ;
			my @queries = () ;
			my @Qresults = () ;
			
			foreach my $pc_group_id (keys %{$pcgroups}) {
				push (@queries, $pcgroups->{$pc_group_id}) if $pcgroups->{$pc_group_id} ;
			}
			
			for (1..$NBTHREADS) {
				my $oworker = lib::threader->new ;
			    push @threads, threads->create(sub { $oworker->searchSpectrumWorker($Qworks, $server) ; } ) ;
			}
			
			$Qworks->enqueue(@queries);
			$Qworks->enqueue(undef) for 1..$NBTHREADS;
			push @Qresults, $_->join foreach @threads;

			
			my $time_end = time ;
			my $seconds = $time_end-$time_start ;
			print "\n------  Time used in multithreading mode : $seconds seconds --------\n\n" ;
			
			print Dumper @Qresults ;
			## TODO...
			#Map @Qresults with annotation hash 
			
		}
		else {
			## connexion
			print $server."\n" ;
			my $omassbank = lib::massbank_api->new() ;
			my $soap = $omassbank->selectMassBank($server) ;
			print "\n------  ** ** ** Using batch mode ** ** ** --------\n\n" ;
			my $time_start = time ;
			foreach my $pcgroup (keys %{$pcgroups}) {
				## searchSpectrum via SOAP
				print "Annot pcgroup n-$pcgroup\n" ;
				my $oquery = lib::massbank_api->new() ;
				my ($results, $num) = $oquery->searchSpectrum($soap, $pcgroups->{$pcgroup}{'id'}, $pcgroups->{$pcgroup}{'mzmed'}, $pcgroups->{$pcgroup}{'into'}, $ion_mode, $instruments, $max, $unit, $tol, $cutoff) ;
				$pcgroups->{$pcgroup}{'annotation'} = $results ;
	#			print Dumper $results ;
			}
			my $time_end = time ;
			my $seconds = $time_end-$time_start ;
			print "\n------  Time used in foreach mode: $seconds seconds --------\n\n" ;
		}
	}
	else {
		
	}
	
	print Dumper $pcgroups
	
}














#====================================================================================
# Help subroutine called with -h option
# number of arguments : 0
# Argument(s)        :
# Return           : 1
#====================================================================================
sub help {
	print STDERR "
massbank_ws_searchspectrum.pl

# massbank_ws_searchspectrum.pl is a script to use SOAP massbank webservice and send specific queries about spectra searches. 
# Input : a list of mzs, intensities, pcgroup.
# Author : Franck Giacomoni and Marion Landi
# Email : franck.giacomoni\@clermont.inra.fr
# Version : 1.0
# Created : 10/06/2015
USAGE :		 
		massbank_ws_searchspectrum.pl -help OR
		
		massbank_ws_searchspectrum.pl 
			-masses [name of input file] -col_id -col_mz -col_int -col_pcgroup -lineheader
			-mode [ion mode : Positive, Negative or Both ]
			-instruments [array of string: all or values obtained by getInstrumentTypes method]
			-max [0 is all results or int]
			-unit [unit or ppm]
			-tolerance [Tolerance of values of m/z of peaks: 0.3 unit or 50 ppm]
			-cutoff [Ignore peaks whose intensity is not larger than the value of cutoff. Default: 50)]
			
			-json [ouput file for JSON]
			-xls [ouput file for XLS]
			-csv [ouput file for TABULAR]
		
		";
	exit(1);
}

## END of script - F Giacomoni 

__END__

=head1 NAME

 XXX.pl -- script for

=head1 USAGE

 XXX.pl -precursors -arg1 [-arg2] 
 or XXX.pl -help

=head1 SYNOPSIS

This script manage ... 

=head1 DESCRIPTION

This main program is a ...

=over 4

=item B<function01>

=item B<function02>

=back

=head1 AUTHOR

Franck Giacomoni E<lt>franck.giacomoni@clermont.inra.frE<gt>
Marion Landi E<lt>marion.landi@clermont.inra.frE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 VERSION

version 1 : xx / xx / 201x

version 2 : ??

=cut