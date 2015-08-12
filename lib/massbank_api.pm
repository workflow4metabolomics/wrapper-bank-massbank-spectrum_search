package lib::massbank_api ;

use strict;
use warnings ;
use Exporter ;
use Carp ;

use Data::Dumper ;
#use SOAP::Lite +trace => [qw (debug)];
use SOAP::Lite ;

use vars qw($VERSION @ISA @EXPORT %EXPORT_TAGS);

our $VERSION = "1.0";
our @ISA = qw(Exporter);
our @EXPORT = qw( connectMassBankJP connectMassBankDE selectMassBank getInstrumentTypes getRecordInfo searchSpectrum getPeak);
our %EXPORT_TAGS = ( ALL => [qw( connectMassBankJP connectMassBankDE selectMassBank getInstrumentTypes getRecordInfo searchSpectrum getPeak)] );




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


=head2 METHOD connectMassBankJP

	## Description : create a soap object throught the webservice japan massbank.
	## Input : $self
	## Ouput : $soap ;
	## Usage : my $soap = connectMassBankJP() ;

=cut
sub connectMassBankJP() {
	## Retrieve Values
    my $self = shift ;
	my $osoap = SOAP::Lite 
		-> uri('http://api.massbank')
		-> proxy('http://www.massbank.jp/api/services/MassBankAPI?wsdl', timeout => 100 )
		-> on_fault(sub { my($soap, $res) = @_; 
         die ref $res ? $res->faultstring : $soap->transport->status, "\n";});
	
	return ($osoap);
}
### END of SUB

=head2 METHOD connectMassBankDE

	## Description : create a soap object throught the webservice UFZ-DE massbank.
	## Input : $self
	## Ouput : $soap ;
	## Usage : my $soap = connectMassBankDE() ;

=cut
sub connectMassBankDE() {
	## Retrieve Values
    my $self = shift ;
	my $osoap = SOAP::Lite 
		-> uri('http://api.massbank')
#		-> proxy('http://massbank.ufz.de/MassBank/api/services/MassBankAPI?wsdl', timeout => 500 )
		-> proxy('http://massbank.normandata.eu/MassBank/api/services/MassBankAPI?wsdl', timeout => 500 )
		-> on_fault(sub { my($soap, $res) = @_; 
         die ref $res ? $res->faultstring : $soap->transport->status, "\n";});
	return ($osoap);
}
### END of SUB

=head2 METHOD selectMassBank

	## Description : create a soap object throught a choice of servers like UFZ-DE mirror or JP mirror.
	## Input : $server
	## Ouput : $soap ;
	## Usage : my $soap = selectMassBank($server) ;

=cut
sub selectMassBank() {
	## Retrieve Values
    my $self = shift ;
    my ( $server ) = @_ ;
    
    my $osoap = undef ;
    
    my $ombk = new() ;
    
    if ( (defined $server ) and ($server eq 'JP') ) {
    	$osoap = $ombk->connectMassBankJP() ;
    }
    elsif ( (defined $server ) and ($server eq 'DE') ){
    	$osoap = $ombk->connectMassBankDE() ;
    }
    elsif ( !defined $server ) {
    	croak "Can't adress SOAP connexion : undefined MassBank server\n" ;
    }
    else {
    	croak "Can't adress SOAP connexion : unknown MassBank server ($server)\n" ;
    }
	return ($osoap);
}
### END of SUB



=head2 METHOD getInstrumentTypes

	## Description : Get a list of the instrument types resistered in MassBank
	## Input : $soap
	## Ouput : $res ;
	## Usage : $res = getInstrumentTypes($soap) ;

=cut
sub getInstrumentTypes() {
	## Retrieve Values
    my $self = shift ;
    my ($osoap) = @_ ;
    my @records = () ;

	my $res = $osoap -> getInstrumentTypes ;
	
	## DETECTING A SOAP FAULT
	if ($res->fault) { 		@records = $res->faultdetail; }
	else {					@records = $res->valueof('//return'); }
	
	return(\@records) ;
}
### END of SUB

=head2 METHOD getRecordInfo

	## Description : Get the data of MassBank records specified by Record IDs. A MassBank record includes peak data, analytical conditions and so on).
	## Input : $osoap, $ids
	## Ouput : $dats
	## Usage : $dats = getRecordInfo($osoap, $ids) ;

=cut

sub getRecordInfo() {
	## Retrieve Values
    my $self = shift ;
	my ($osoap, $ids) = @_ ;
	
	my @dats = () ;
    
    if ( defined $ids ) {
    	
    	my @query = @{$ids} ;
    	my $nb_ids = scalar (@query) ;
    	
    	if ( $nb_ids > 0 ) {
			my $method = SOAP::Data->name('getRecordInfo') ->attr({xmlns => 'http://api.massbank'});
			my @params = ( SOAP::Data->name('ids' => @query  ) );
			# Call method
			my $som = $osoap->call($method => @params);
		    ## DETECTING A SOAP FAULT
			if ($som->fault) {
				push(@dats, undef) ;
				warn "\t\t WARN: The query Id is false, MassBank don't find any record\n" ;
			}
			else {
				if ($som->valueof('//info') ne '') { # avoid to fill array with false id returning '' value
					@dats = $som->valueof('//info');	
				}
				else {
					warn "\t\t WARN: The query Id is false, MassBank don't find any record\n" ;
				}
			}
    	}
    	else {
    		warn "\t\t WARN: Query Ids list is empty, MassBank soap will be quiet\n" ;
    	}
    }
    else {
    	warn "\t\t WARN: Query Ids list is undef, MassBank soap will be quiet\n" ;
    }
    
    return(\@dats) ;
}
### END of SUB



=head2 METHOD getPeakFromId

	## Description : Get the peak data of MassBank records specified by Record IDs.
	## Input : $ids
	## Ouput : 
	## Usage : my ($pks) = getPeak($soap, $ids) ;

=cut

sub getPeak() { 
	## Retrieve Values
    my $self = shift ;
	my ($osoap, $ids) = @_;
	my (@dat, @ids, @dats) = ( (), () );
	@ids = @{$ids} ;
	
	foreach my $id ( @ids ) {
		push(@dat, SOAP::Data -> name('ids' => $id));
	}
	
	my $data = SOAP::Data -> value(@dat);
	my $som = $osoap -> getPeak($data) ;
	
	## DETECTING A SOAP FAULT OR NOT
	if ($som->fault) { 		@dats = $som->faultdetail ; }
	else {					@dats = $som->valueof('//return') ; }
	
#	print Dumper $som->valueof('//return') ;
	return(\@dats) ;
}

=head2 METHOD searchSpectrum

	## Description : Get the response equivalent to the "Spectrum Search" results.
	## Input : $osoap, $pcgroup_id, $mzs, $intensities, $ion, $instruments, $max, $unit, $tol, $cutoff
	## Ouput : $spectra, $numspectra
	## Usage : ($spectra, $numspectra) = searchSpectrum($osoap, $mzs, $intensities, $ion, $instruments, $max, $unit, $tol, $cutoff) ;

=cut

sub searchSpectrum() {
	## Retrieve Values
    my $self = shift ;
	my ($osoap, $pcgroup_id , $mzs, $intensities, $ion, $instruments, $max, $unit, $tol, $cutoff) = @_;
	
	# init in case :
	$ion = 'both' if ( !defined $ion ) ;
	$instruments = ['all'] if ( !defined $instruments ) ;
	$max = 0 if ( !defined $max ) ;
	$unit = 'unit' if ( !defined $unit ) ;
	$cutoff = 5 if ( !defined $cutoff ) ;
	if ( !defined $tol ) {
		if ( $unit eq 'unit' ) { $tol = 0.3 ; }
		else { $tol = 50 ; }
	}
	
	my @dats = () ;
	my %ret = ();
	my $numdats = 0 ;
    
    if ( defined $mzs ) {
    	my $nb_mzs = scalar (@{$mzs}) ;
    	
    	if ( $nb_mzs > 0 ) {
    		
    		my @mzs = @{$mzs} ;
    		my @ints = @{$intensities} ;
    		my ( @dat1, @dat2 ) = ( (), () ) ;
			my $i = 0 ;
			
			foreach my $mz (@mzs) {
				push(@dat1, SOAP::Data -> name('mzs' => $mz) );
				push(@dat2, SOAP::Data -> name('intensities' => $ints[$i]) );
				$i++ ;
			}
			
			push(@dat2, SOAP::Data -> name('unit' => $unit) ) ;
			push(@dat2, SOAP::Data -> name('tolerance' => $tol) ) ;
			push(@dat2, SOAP::Data -> name('cutoff' => $cutoff) ) ;

			foreach my $ins ( @{$instruments} ) {
				push(@dat2, SOAP::Data -> name('instrumentTypes' => $ins));
			}
			push(@dat2, SOAP::Data -> name('ionMode' => $ion));
			push(@dat2, SOAP::Data -> name('maxNumResults' => $max));
			
			my $data = SOAP::Data -> value(@dat1, @dat2);
			my $som = $osoap -> searchSpectrum($data);
			
		    ## DETECTING A SOAP FAULT OR NOT
		    if ( $som ) {
		    	if ($som->fault) {
					$ret{'fault'} = $som->faultstring; $ret{'num_res'} = -1 ; 
				}
				else {
					@dats = $som->valueof('//results/[>0]'); 
					$numdats = $som->valueof('//numResults') ;
					my $i ;
					my @res = () ;
					## For results
					if ($numdats > 0) {
						## insert nb of res 
						$ret{ 'num_res'} = $numdats ;
						$ret{ 'pcgroup_id'} = $pcgroup_id ;
						
						## manage mapping for spectral features
						for ( $i = 0; $i < $numdats; $i ++ ) {
							my ($exactMass, $formula, $id, $score, $title) = @dats[($i * 5) .. ($i * 5 + 4)];
							my (%val) = ('id', $id, 'title', $title, 'formula', $formula, 'exactMass', $exactMass, 'score', $score);
							push(@res, { %val });
						}
						$ret{'res'} = \@res;
					}
					## for no results for the query
					else {
						$ret{ 'num_res'} = $numdats ;
						$ret{ 'pcgroup_id'} = $pcgroup_id ;
						my (%val) = ('id', undef, 'title', undef, 'formula', undef, 'exactMass', undef, 'score', undef);
						push(@res, { %val });
						$ret{'res'} = \@res;
					}
	    		}
		    }
		    else {
		    	carp "The som return (from the searchSpectrum method) isn't defined\n" ; }
    	}
    	else { carp "Query MZs list is empty, MassBank soap will stop\n" ; }
    }
    else { carp "Query MZs list is undef, MassBank soap will stop\n" ; }
#	print Dumper @ret ;
    return(\%ret, $numdats) ;
}
### END of SUB




#=head2 METHOD new
#
#	## Description : new
#	## Input : $self
#	## Ouput : bless $self ;
#	## Usage : new() ;
#
#=cut
#
#sub searchPeak() { local($soap, $mz, $max, $ion, $rel, $inst, $tol) = @_;
#	$ion = 'both' if ( $ion eq '' );
#	$rel += 0;
#	$max += 0;
#	local(@inst) = @$inst;
#	@inst = ('all') if ( scalar(@inst) == 0 );
#	$tol = 0.3 if ( $tol eq '' );
#	local(@mz) = @$mz;
#	local(@dat) = ();
#	local($mzv);
#	foreach $mzv ( @mz ) {
#		push(@dat, SOAP::Data -> name('mzs' => $mzv));
#	}
#	push(@dat, SOAP::Data -> name('relativeIntensity' => $rel));
#	push(@dat, SOAP::Data -> name('tolerance' => $tol));
#	local($ins);
#	foreach $ins ( @inst ) {
#		push(@dat, SOAP::Data -> name('instrumentTypes' => $ins));
#	}
#	push(@dat, SOAP::Data -> name('ionMode' => $ion));
#	push(@dat, SOAP::Data -> name('maxNumResults' => $max));
#	local($data) = SOAP::Data -> value(@dat);
#	local($som) = $soap -> searchPeak($data);
#	local($num) = $som -> valueof('/Envelope/Body/[1]/[>0]/numResults');
#	local(@res) = $som -> valueof('/Envelope/Body/[1]/[>0]/results/[>0]');
#	local($i);
#	local(@ret) = ();
#	for ( $i = 0; $i < $num; $i ++ ) {
#		local($mw, $form, $id, $score, $title) = @res[($i * 5) .. ($i * 5 + 4)];
#		local(%val) = ('id', $id, 'title', $title, 'formula', $form, 'exactMass', $mw);
#		push(@ret, { %val });
#	}
#	return @ret;
#}
#
#=head2 METHOD new
#
#	## Description : new
#	## Input : $self
#	## Ouput : bless $self ;
#	## Usage : new() ;
#
#=cut
#
#sub searchPeakDiff() { local($soap, $mz, $max, $ion, $rel, $inst, $tol) = @_;
#	$ion = 'both' if ( $ion eq '' );
#	$rel += 0;
#	$max += 0;
#	local(@inst) = @$inst;
#	@inst = ('all') if ( scalar(@inst) == 0 );
#	$tol = 0.3 if ( $tol eq '' );
#	local(@mz) = @$mz;
#	local(@dat) = ();
#	local($mzv);
#	foreach $mzv ( @mz ) {
#		push(@dat, SOAP::Data -> name('mzs' => $mzv));
#	}
#	push(@dat, SOAP::Data -> name('relativeIntensity' => $rel));
#	push(@dat, SOAP::Data -> name('tolerance' => $tol));
#	local($ins);
#	foreach $ins ( @inst ) {
#		push(@dat, SOAP::Data -> name('instrumentTypes' => $ins));
#	}
#	push(@dat, SOAP::Data -> name('ionMode' => $ion));
#	push(@dat, SOAP::Data -> name('maxNumResults' => $max));
#	local($data) = SOAP::Data -> value(@dat);
#	local($som) = $soap -> searchPeakDiff($data);
#	local($num) = $som -> valueof('/Envelope/Body/[1]/[>0]/numResults');
#	local(@res) = $som -> valueof('/Envelope/Body/[1]/[>0]/results/[>0]');
#	local($i);
#	local(@ret) = ();
#	for ( $i = 0; $i < $num; $i ++ ) {
#		local($mw, $form, $id, $score, $title) = @res[($i * 5) .. ($i * 5 + 4)];
#		local(%val) = ('id', $id, 'title', $title, 'formula', $form, 'exactMass', $mw);
#		push(@ret, { %val });
#	}
#	return @ret;
#}
#
#=head2 METHOD new
#
#	## Description : new
#	## Input : $self
#	## Ouput : bless $self ;
#	## Usage : new() ;
#
#=cut
#
#sub execBatchJob() { local($soap, $spectra, $ion, $inst, $mail) = @_;
#	$ion = 'both' if ( $ion eq '' );
#	local(@inst) = @$inst;
#	@inst = ('all') if ( scalar(@inst) == 0 );
#	local(%spectra) = %$spectra;
#	local($name);
#	local(@query) = ();
#	foreach $name ( keys %spectra ) {
#		local(@q) = ("Name:$name");
#		local(%peak) = %{$spectra{$name}};
#		local($mz, $inte);
#		foreach $mz ( keys %peak ) {
#			$inte = $peak{$mz};
#			push(@q, "$mz,$inte");
#		}
#		push(@query, join(';', @q));
#	}
#	local(@dat) = ();
#	local($q);
#	push(@dat, SOAP::Data -> name('type' => 1));
#	push(@dat, SOAP::Data -> name('mailAddress' => $mail));
#	foreach $q ( @query ) {
#		push(@dat, SOAP::Data -> name('queryStrings' => $q));
#	}
#	local($ins);
#	foreach $ins ( @inst ) {
#		push(@dat, SOAP::Data -> name('instrumentTypes' => $ins));
#	}
#	push(@dat, SOAP::Data -> name('ionMode' => $ion));
#	local($data) = SOAP::Data -> value(@dat);
#	local($som) = $soap -> execBatchJob($data);
#	local($res) = $som -> valueof('/Envelope/Body/[1]');
#	return ${$res}{'return'};
#}
#
#=head2 METHOD new
#
#	## Description : new
#	## Input : $self
#	## Ouput : bless $self ;
#	## Usage : new() ;
#
#=cut
#
#sub getJobStatus() { local($soap, $job) = @_;
#	local(@dat) = ();
#	push(@dat, SOAP::Data -> name('jobId' => $job));
#	local($data) = SOAP::Data -> value(@dat);
#	local($som) = $soap -> getJobStatus($data);
#	local($res) = $som -> valueof('/Envelope/Body/[1]/[1]');
#	local(%res) = %{$res};
#	local($status) = $res{'status'};
#	local($code) = $res{'statusCode'};
#	local($date) = $res{'requestDate'};
#	return ($status, $code, $date);
#}
#
#=head2 METHOD new
#
#	## Description : new
#	## Input : $self
#	## Ouput : bless $self ;
#	## Usage : new() ;
#
#=cut
#
#sub getJobResult() { local($soap, $job) = @_;
#	local(@dat) = ();
#	push(@dat, SOAP::Data -> name('jobId' => $job));
#	local($data) = SOAP::Data -> value(@dat);
#	local($som) = $soap -> getJobResult($data);
#	local(@res) = $som -> valueof('/Envelope/Body/[1]/[>0]');
#	local($n) = scalar(@res);
#	local(@ret) = ();
#	local($i);
#	for ( $i = 0; $i < $n; $i ++ ) {
#		local(%res) = %{$res[$i]};
#		local(@res1) = $som -> valueof('/Envelope/Body/[1]/['.($i+1).']/results/[>0]');
#		local(%ret) = ();
#		local($qname) = $res{'queryName'};
#		$ret{'qname'} = $qname;
#		local($num) = $res{'numResults'};
#		$ret{'num'} = $num;
#		local(@ret1) = ();
#		local($j);
#		for ( $j = 0; $j < $num; $j ++ ) {
#			local($mw, $form, $id, $score, $title) = @res1[($j * 5) .. ($j * 5 + 4)];
#			local(%val) = ('id', $id, 'title', $title, 'formula', $form, 'exactMass', $mw, 'score', $score);
#			push(@ret1, { %val });
#		}
#		$ret{'list'} = [ @ret1 ];
#		push(@ret, { %ret });
#	}
#	return @ret;
#}


1 ;


__END__

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

 perldoc massbank_api.pm

=head1 Exports

=over 4

=item :ALL is ...

=back

=head1 AUTHOR

Franck Giacomoni E<lt>franck.giacomoni@clermont.inra.frE<gt> and marion Landi E<lt>marion.landi@clermont.inra.frE<gt>

=head1 LICENSE

This script is fully inspired by MassBank SOAP API Client Package Ver-2.0 with :
	Author: Hisayuki Horail (MassBank Group, IAB, Keio U. and JST-BIRD)
	Home page: http://www.massbank.jp/
	Date: 25 May 2010
	This software is licensed
	under a Creative Commons Attribution License 2.1 Japan License (CC-BY)
	(http://creativecommons.org/licensesby/2.1/jp/).
	
This new version of this program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.	

=head1 VERSION

version 1 : 25 / 05 / 2010

version 2 : 04 / 06 / 2015

=cut