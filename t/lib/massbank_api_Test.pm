package lib::massbank_api_Test ;

use diagnostics; # this gives you more debugging information
use warnings;    # this warns you of bad practices
use strict;      # this prevents silly errors
use Exporter ;
use Carp ;

use Data::Dumper ;

our $VERSION = "1.0";
our @ISA = qw(Exporter);
our @EXPORT = qw( get_pcgroup_listTest get_pcgroupsTest threading_methods_getRecordInfoTest connectMassBankTest connectMassBankJPTest connectMassBankDETest getInstrumentTypesTest getRecordInfoTest searchSpectrumTest searchSpectrumNBTest getPeakTest);
our %EXPORT_TAGS = ( ALL => [qw(get_pcgroup_listTest get_pcgroupsTest threading_methods_getRecordInfoTest connectMassBankTest connectMassBankJPTest connectMassBankDETest getInstrumentTypesTest getRecordInfoTest searchSpectrumTest searchSpectrumNBTest getPeakTest)] );

use lib '/Users/fgiacomoni/Inra/labs/perl/galaxy_tools/massbank_ws_searchspectrum' ;
use lib::massbank_api qw( :ALL ) ;
use lib::threader qw( :ALL ) ;
use lib::mapper qw( :ALL ) ;

sub connectMassBankTest {
	my ($uri, $proxy) = @_ ;
    my $oBih = lib::massbank_api->new() ;
    my ($soap) = $oBih->connectMassBank($uri, $proxy) ;
    return ($soap) ;
}

sub connectMassBankJPTest {
    my $oBih = lib::massbank_api->new() ;
    my ($soap) = $oBih->connectMassBankJP() ;
    return ($soap) ;
}

sub connectMassBankDETest {
    my $oBih = lib::massbank_api->new() ;
    my ($soap) = $oBih->connectMassBankDE() ;
    return ($soap) ;
}

sub getInstrumentTypesTest {
	my ($server) = @_ ;
	my $osoap = undef ;
    my $oBih = lib::massbank_api->new() ;
    
    if ($server eq 'JP') { 		($osoap) = $oBih->connectMassBankJP() ; }
    elsif ($server eq 'DE') {	($osoap) = $oBih->connectMassBankDE() ; }
    else {						croak "Can't call an unknown server through MassBank API\n" ; }
    
    my $res = $oBih->getInstrumentTypes($osoap) ;
    return ($res) ;
}

sub getRecordInfoTest {
	my ($server, $ids) = @_ ;
	
	my $oBih = lib::massbank_api->new() ;
    my ($osoap) = $oBih->selectMassBank($server) ;
    my ($res) = $oBih->getRecordInfo($osoap, $ids) ;

    return($res) ;
}


sub searchSpectrumTest {
	my ($mzs, $intensities, $ion, $instruments, $max, $unit, $tol, $cutoff) = @_ ;
	my $pcgroup_id = 1 ;
	my $oBih = lib::massbank_api->new() ;
    my ($osoap) = $oBih->selectMassBank('DE') ;
    my ($res, $num) = $oBih->searchSpectrum($osoap, $pcgroup_id, $mzs, $intensities, $ion, $instruments, $max, $unit, $tol, $cutoff) ;
    return($res) ;
}

sub searchSpectrumNBTest {
	my ($mzs, $intensities, $ion, $instruments, $max, $unit, $tol, $cutoff) = @_ ;
	my $pcgroup_id = 1 ;
	my $oBih = lib::massbank_api->new() ;
    my ($osoap) = $oBih->selectMassBank('DE') ;
    my ($res, $num) = $oBih->searchSpectrum($osoap, $pcgroup_id, $mzs, $intensities, $ion, $instruments, $max, $unit, $tol, $cutoff) ;
    return($num) ;
}

sub getPeakTest {
	my ($ids) = @_ ;
	
	my $oBih = lib::massbank_api->new() ;
    my ($osoap) = $oBih->selectMassBank('DE') ;
    my ($res) = $oBih->getPeak($osoap, $ids) ;
    return($res) ;
}

sub threading_methods_getRecordInfoTest {
	my ($ids) = @_ ;
	
	my $results = undef ;
	my $othreads = lib::threader->new() ;
	my $oquery = lib::massbank_api->new() ;
	my ($osoap) = $oquery->selectMassBank('DE') ;
	$results = $othreads->threading_getRecordInfo($osoap, $ids) ; 
	return($results) ;
}


sub get_pcgroupsTest {
	my ( $pcs, $mzs, $ints, $names ) = @_;
	my $omap = lib::mapper->new() ;
	my $pcgroups = $omap->get_pcgroups($pcs, $mzs, $ints, $names) ;
#	print Dumper $pcgroups ;
	return ($pcgroups) ;
}


sub get_pcgroup_listTest {
	my ($pcs) = @_ ; 
	my $omap = lib::mapper->new() ;
	my $pcgroup_list = $omap->get_pcgroup_list($pcs) ;
#	print Dumper $pcgroup_list ;
	return ($pcgroup_list) ;
}



1 ;