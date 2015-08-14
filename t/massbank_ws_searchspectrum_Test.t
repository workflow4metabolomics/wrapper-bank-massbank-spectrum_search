#! perl
use diagnostics;
use warnings;
no warnings qw/void/;
use strict;
no strict "refs" ;
use Test::More qw( no_plan );
#use Test::More tests => 8 ; ## with MAPPER SEQUENCE
use FindBin ;
use Carp ;

## Specific Modules
use lib $FindBin::Bin ;
my $binPath = $FindBin::Bin ;
use lib::massbank_api_Test qw( :ALL ) ;
use lib::massbank_mapper_Test qw( :ALL ) ;


## To launch the right sequence : API, MAPPER, THREADER, ...
my $sequence = 'MAPPER' ; 
my $current_test = 1 ;





if ($sequence eq "MAPPER") {
	
	## testing mapper module of massbank wrapper.
	## 		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	print "\n\t\t\t\t  * * * * * * \n" ;
	print "\t  * * * - - - Test MassBank Mapper module - - - * * * \n\n" ;

	##		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# ARGVTS : $pcs, $mzs, $ints
	sleep 1 ; print "\n** Test $current_test get_pcgroup_list with pcs array **\n" ; $current_test++ ; 
	is_deeply( get_pcgroup_listTest (
		[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,5,5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,6,6,6,7,8,8,8,8,8,9,9,10,10,10,10,11,12,13,13,13,14,14,14] ),
		['1', '2','3','4','5','6','7','8','9','10','11','12','13','14'] ,
	'Method \'getPcgroupList\' works with various and multiple pcgroups and return the attended uniq pcgroups array');
	
	
	##		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# ARGVTS : $pcs, $mzs, $ints, $names
	print "\n** Test $current_test get_pcgroups with pcs, mzs, ints, names arrays **\n" ; $current_test++ ;
	is_deeply( get_pcgroupsTest (
		[1, 2, 1, 2, 1, 2, 1], ['273.096', '289.086', '290.118', '291.096', '292.113', '579.169', '580.179'], ['300', '300', '300', '300', '300', '300', '300'], ['name1', 'name2', 'name3', 'name4', 'name5', 'name6', 'name7'] ), 
		{ '1' => {   'id' => '1',
	                   'mzmed' => ['273.096','290.118','292.113','580.179'],
	                   'into' => ['300','300','300','300'],
	                   'annotation' => {},
	                   'massbank_ids' => []    },
	      '2' => { 'annotation' => {},
	                   'into' => ['300','300','300'],
	                   'mzmed' => ['289.086','291.096','579.169'],
	                   'id' => '2',
	                   'massbank_ids' => [],   }
		},  
	'Method \'getPcgroups\' works with two pcgroups and return the attended pcgroups object');
	
	##		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	## ARGVTS : $header, $init_pcs, $pcgroups
	sleep 1 ; print "\n** Test $current_test set_massbank_matrix_object with pc array and pcgroups object **\n" ; $current_test++ ; 
	is_deeply( set_massbank_matrix_objectTest ( 'massbank', [1,1,2,2,1], 
		{ '1' => {   'id' => '1',
		                   'mzmed' => ['273.096','290.118','292.113','580.179'],
		                   'into' => ['300','300','300','300'],
		                   'annotation' => {'num_res' => 3},
		                   'massbank_ids' => ['CA0001', 'CA0011', 'CA0111']    },
		      '2' => { 'annotation' => {'num_res' => 3},
		                   'into' => ['300','300','300'],
		                   'mzmed' => ['289.086','291.096','579.169'],
		                   'id' => '2',
		                   'massbank_ids' => ['CA0002', 'CA0022', 'CA0222'],   }
		} ), ## end argvts
		[ [ 'massbank' ], ['CA0001|CA0011|CA0111'],['CA0001|CA0011|CA0111'],  ['CA0002|CA0022|CA0222'], ['CA0002|CA0022|CA0222'],  ['CA0001|CA0011|CA0111'] ], 
	'Method \'set_massbank_matrix_object\' works with header, pcs list, pcgroups and return the attended massbank matrix');
	
	##		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	## ARGVTS : $header, $init_pcs, $pcgroups
	sleep 1 ; print "\n** Test $current_test set_massbank_matrix_object with undef hearder, pc array and pcgroups object **\n" ; $current_test++ ; 
	is_deeply( set_massbank_matrix_objectTest ( undef, [1,1,2,2,1], 
		{ '1' => {   'id' => '1',
		                   'mzmed' => ['273.096','290.118','292.113','580.179'],
		                   'into' => ['300','300','300','300'],
		                   'annotation' => {'num_res' => 3},
		                   'massbank_ids' => ['CA0001', 'CA0011', 'CA0111']    },
		      '2' => { 'annotation' => {'num_res' => 3},
		                   'into' => ['300','300','300'],
		                   'mzmed' => ['289.086','291.096','579.169'],
		                   'id' => '2',
		                   'massbank_ids' => ['CA0002', 'CA0022', 'CA0222'],   }
		} ), ## end argvts
		[ ['CA0001|CA0011|CA0111'],['CA0001|CA0011|CA0111'],  ['CA0002|CA0022|CA0222'], ['CA0002|CA0022|CA0222'],  ['CA0001|CA0011|CA0111'] ],
	'Method \'set_massbank_matrix_object\' works with undef header and return the attended massbank matrix');
	
	##		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	## ARGVTS : $header, $init_pcs, $pcgroups
	sleep 1 ; print "\n** Test $current_test set_massbank_matrix_object with empty massbankIds **\n" ; $current_test++ ; 
	is_deeply( set_massbank_matrix_objectTest ( 'massbank', [1,1,2,2,1], 
		{ '1' => {   'id' => '1',
		                   'mzmed' => ['273.096','290.118','292.113','580.179'],
		                   'into' => ['300','300','300','300'],
		                   'annotation' => {'num_res' => 3},
		                   'massbank_ids' => ['CA0001', 'CA0011', 'CA0111']    },
		      '2' => { 'annotation' => {'num_res' => 0},
		                   'into' => ['300','300','300'],
		                   'mzmed' => ['289.086','291.096','579.169'],
		                   'id' => '2',
		                   'massbank_ids' => [],   }
		} ), ## end argvts
		[ [ 'massbank' ], ['CA0001|CA0011|CA0111'],['CA0001|CA0011|CA0111'],  ['No_result_found_on_MassBank'], ['No_result_found_on_MassBank'],  ['CA0001|CA0011|CA0111'] ], 
	'Method \'set_massbank_matrix_object\' works with empty massbank_ids and return the attended massbank matrix');
	
	##		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	## ARGVTS : $input_matrix_object, $massbank_matrix_object
	sleep 1 ; print "\n** Test $current_test add_massbank_matrix_to_input_matrix with two matrix **\n" ; $current_test++ ; 
	is_deeply( add_massbank_matrix_to_input_matrixTest ( 
		[[ 'pcgroup' ],[1],[1],[2],[2],[1]],
		[ [ 'massbank' ], ['CA0001|CA0011|CA0111'],['CA0001|CA0011|CA0111'],  ['CA0002|CA0022|CA0222'], ['CA0002|CA0022|CA0222'],  ['CA0001|CA0011|CA0111'] ],
	), ## end argvts
		[ ['pcgroup','massbank'],[1,'CA0001|CA0011|CA0111'],[1,'CA0001|CA0011|CA0111'],[2,'CA0002|CA0022|CA0222'],[2,'CA0002|CA0022|CA0222'],[1,'CA0001|CA0011|CA0111'] 
	], ## end results
	'Method \'add_massbank_matrix_to_input_matrix\' works with two wel formatted matrix and return the right csv matrix');
	
	
	
	
#### #### ##### ###### ################################################ ###### ##### ##### ###### ######

								## END of MAPPER SEQUENCE ## 
							
#### #### ##### ###### ################################################ ###### ##### ##### ###### ######
}

#### #### ##### ###### ################################################ ###### ##### ##### ###### ######

								## START of API SEQUENCE ## 
							
#### #### ##### ###### ################################################ ###### ##### ##### ###### ######
elsif ($sequence eq "API") {
	
	## testing connectMassBank on Japan and DE servers.
	## 		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	print "\n\t\t\t\t  * * * * * * \n" ;
	print "\t  * * * - - - Test MassBank API from SOAP - - - * * * \n\n" ;
	


## 		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n** Test 03 connectMassBankJP with real uri and proxy **\n" ;
isa_ok( connectMassBankJPTest(), 'SOAP::Lite' );

## 		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n** Test 04 connectMassBankDE with real uri and proxy **\n" ;
isa_ok( connectMassBankDETest(), 'SOAP::Lite' );

## 		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n** Test 05 getInstrumentTypes with the JP server **\n" ;
#is_deeply( getInstrumentTypesTest('JP'), ['APCI-ITFT', 'APCI-ITTOF','CE-ESI-TOF', 'CI-B', 'EI-B', 'EI-EBEB', 'ESI-ITFT', 'ESI-ITTOF', 'FAB-B', 'FAB-EB', 'FAB-EBEB', 'FD-B', 'FI-B', 'GC-EI-QQ', 'GC-EI-TOF', 'LC-APCI-QTOF', 'LC-APPI-QQ', 'LC-ESI-IT', 'LC-ESI-ITFT', 'LC-ESI-ITTOF', 'LC-ESI-Q', 'LC-ESI-QFT', 'LC-ESI-QIT', 'LC-ESI-QQ', 'LC-ESI-QTOF', 'LC-ESI-TOF', 'MALDI-QIT', 'MALDI-TOF', 'MALDI-TOFTOF'], 'Works with \'JP server\' and return a list of instrument types');
#print "-- no test -- skipped because JP method is down" ;
## 		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n** Test 06 getInstrumentTypes with the DE server **\n" ;
is_deeply( getInstrumentTypesTest('DE'), ['APCI-ITFT', 'APCI-ITTOF', 'CE-ESI-TOF', 'CI-B', 'EI-B', 'EI-EBEB', 'ESI-FTICR', 'ESI-ITFT', 'ESI-ITTOF', 'FAB-B', 'FAB-EB', 'FAB-EBEB', 'FD-B', 'FI-B', 'GC-EI-QQ', 'GC-EI-TOF', 'HPLC-ESI-TOF', 'LC-APCI-Q', 'LC-APCI-QTOF', 'LC-APPI-QQ', 'LC-ESI-IT', 'LC-ESI-ITFT', 'LC-ESI-ITTOF', 'LC-ESI-Q', 'LC-ESI-QFT', 'LC-ESI-QIT', 'LC-ESI-QQ', 'LC-ESI-QTOF', 'LC-ESI-TOF', 'MALDI-QIT', 'MALDI-TOF', 'MALDI-TOFTOF', 'UPLC-ESI-QTOF'], 'Works with \'DE server\' and return a list of instrument types');

## 		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n** Test 07 getRecord on JP server with a true ID **\n" ; 
is_deeply( getRecordInfoTest('DE', ['KOX00001']), 
['ACCESSION: KOX00001
RECORD_TITLE: GABA; LC-ESI-QTOF; MS2; MERGED; [M-H]-
DATE: 2011.08.24 (Created 2008.11.28)
AUTHORS: Institute for Advanced Biosciences, Keio Univ.
LICENSE: Copyright 2006-2011 Keio
COMMENT: Peak data in the following records are not open to the public as requested by their authors.
COMMENT: Instead MassBank provides the merged spectra for the public.
COMMENT: This record was generated by merging the following three MassBank records.
COMMENT: [Merging] KO004290 GABA; LC-ESI-QTOF; MS2; CE:10 V [M-H]-
COMMENT: [Merging] KO004291 GABA; LC-ESI-QTOF; MS2; CE:20 V [M-H]-
COMMENT: [Merging] KO004292 GABA; LC-ESI-QTOF; MS2; CE:30 V [M-H]-
CH$NAME: GABA
CH$NAME: 4-Aminobutanoate
CH$NAME: 4-Aminobutanoic acid
CH$NAME: 4-Aminobutylate
CH$NAME: 4-Aminobutyrate
CH$NAME: 4-Aminobutyric acid
CH$NAME: gamma-Aminobutyric acid
CH$COMPOUND_CLASS: N/A
CH$FORMULA: C4H9NO2
CH$EXACT_MASS: 103.06333
CH$SMILES: NCCCC(O)=O
CH$IUPAC: InChI=1S/C4H9NO2/c5-3-1-2-4(6)7/h1-3,5H2,(H,6,7)
CH$LINK: CAS 56-12-2
CH$LINK: CHEBI 30566
CH$LINK: KEGG C00334
CH$LINK: NIKKAJI J1.375G
CH$LINK: PUBCHEM SID:3628
AC$INSTRUMENT: Qstar, Applied Biosystems
AC$INSTRUMENT_TYPE: LC-ESI-QTOF
AC$MASS_SPECTROMETRY: MS_TYPE MS2
AC$MASS_SPECTROMETRY: ION_MODE NEGATIVE
MS$FOCUSED_ION: PRECURSOR_M/Z 102
MS$FOCUSED_ION: PRECURSOR_TYPE [M-H]-
PK$ANNOTATION: 41.9979886273 84.0449388199 102.0555035062
PK$NUM_PEAK: N/A
PK$PEAK: m/z int. rel.int.
  N/A
'], 
'Works with \'DE server\' and return one record from "KOX00001" id');

## 	test a false massbank ID	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n** Test 08 getRecord with a false ID **\n" ;
is_deeply( getRecordInfoTest('DE', ['KOX100101']), [undef], 'Method \'getRecordInfo\' works with \'JP server\' and manage no sended record from "KOX100101" a false id');

## 	test a false massbank ID	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n** Test 09 getRecord with a false ID into a real list **\n" ;
is_deeply( getRecordInfoTest('DE', ['KOX100101', 'KOX00001']), ['ACCESSION: KOX00001
RECORD_TITLE: GABA; LC-ESI-QTOF; MS2; MERGED; [M-H]-
DATE: 2011.08.24 (Created 2008.11.28)
AUTHORS: Institute for Advanced Biosciences, Keio Univ.
LICENSE: Copyright 2006-2011 Keio
COMMENT: Peak data in the following records are not open to the public as requested by their authors.
COMMENT: Instead MassBank provides the merged spectra for the public.
COMMENT: This record was generated by merging the following three MassBank records.
COMMENT: [Merging] KO004290 GABA; LC-ESI-QTOF; MS2; CE:10 V [M-H]-
COMMENT: [Merging] KO004291 GABA; LC-ESI-QTOF; MS2; CE:20 V [M-H]-
COMMENT: [Merging] KO004292 GABA; LC-ESI-QTOF; MS2; CE:30 V [M-H]-
CH$NAME: GABA
CH$NAME: 4-Aminobutanoate
CH$NAME: 4-Aminobutanoic acid
CH$NAME: 4-Aminobutylate
CH$NAME: 4-Aminobutyrate
CH$NAME: 4-Aminobutyric acid
CH$NAME: gamma-Aminobutyric acid
CH$COMPOUND_CLASS: N/A
CH$FORMULA: C4H9NO2
CH$EXACT_MASS: 103.06333
CH$SMILES: NCCCC(O)=O
CH$IUPAC: InChI=1S/C4H9NO2/c5-3-1-2-4(6)7/h1-3,5H2,(H,6,7)
CH$LINK: CAS 56-12-2
CH$LINK: CHEBI 30566
CH$LINK: KEGG C00334
CH$LINK: NIKKAJI J1.375G
CH$LINK: PUBCHEM SID:3628
AC$INSTRUMENT: Qstar, Applied Biosystems
AC$INSTRUMENT_TYPE: LC-ESI-QTOF
AC$MASS_SPECTROMETRY: MS_TYPE MS2
AC$MASS_SPECTROMETRY: ION_MODE NEGATIVE
MS$FOCUSED_ION: PRECURSOR_M/Z 102
MS$FOCUSED_ION: PRECURSOR_TYPE [M-H]-
PK$ANNOTATION: 41.9979886273 84.0449388199 102.0555035062
PK$NUM_PEAK: N/A
PK$PEAK: m/z int. rel.int.
  N/A
'], 'Method \'getRecordInfo\' works with \'DE server\' and don\'t send record from "KOX100101" a false id into a list');


## 	test an undef massbank IDs list	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n** Test 10 getRecord with a undef list of IDs **\n" ;
is_deeply( getRecordInfoTest('DE', undef), [], 'Method \'getRecordInfo\' works with \'DE server\' and manage undef massbank ids list');

##	test an empty massbank IDs list	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n** Test 11 getRecord with a void list of IDs **\n" ;
is_deeply( getRecordInfoTest('DE', [] ), [], 'Method \'getRecordInfo\' works with \'DE server\' and manage empty massbank ids list');

##		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n** Test 12 getRecord on DE server with only one real ID **\n" ;
is_deeply( getRecordInfoTest('DE', ['KOX00001']), 
['ACCESSION: KOX00001
RECORD_TITLE: GABA; LC-ESI-QTOF; MS2; MERGED; [M-H]-
DATE: 2011.08.24 (Created 2008.11.28)
AUTHORS: Institute for Advanced Biosciences, Keio Univ.
LICENSE: Copyright 2006-2011 Keio
COMMENT: Peak data in the following records are not open to the public as requested by their authors.
COMMENT: Instead MassBank provides the merged spectra for the public.
COMMENT: This record was generated by merging the following three MassBank records.
COMMENT: [Merging] KO004290 GABA; LC-ESI-QTOF; MS2; CE:10 V [M-H]-
COMMENT: [Merging] KO004291 GABA; LC-ESI-QTOF; MS2; CE:20 V [M-H]-
COMMENT: [Merging] KO004292 GABA; LC-ESI-QTOF; MS2; CE:30 V [M-H]-
CH$NAME: GABA
CH$NAME: 4-Aminobutanoate
CH$NAME: 4-Aminobutanoic acid
CH$NAME: 4-Aminobutylate
CH$NAME: 4-Aminobutyrate
CH$NAME: 4-Aminobutyric acid
CH$NAME: gamma-Aminobutyric acid
CH$COMPOUND_CLASS: N/A
CH$FORMULA: C4H9NO2
CH$EXACT_MASS: 103.06333
CH$SMILES: NCCCC(O)=O
CH$IUPAC: InChI=1S/C4H9NO2/c5-3-1-2-4(6)7/h1-3,5H2,(H,6,7)
CH$LINK: CAS 56-12-2
CH$LINK: CHEBI 30566
CH$LINK: KEGG C00334
CH$LINK: NIKKAJI J1.375G
CH$LINK: PUBCHEM SID:3628
AC$INSTRUMENT: Qstar, Applied Biosystems
AC$INSTRUMENT_TYPE: LC-ESI-QTOF
AC$MASS_SPECTROMETRY: MS_TYPE MS2
AC$MASS_SPECTROMETRY: ION_MODE NEGATIVE
MS$FOCUSED_ION: PRECURSOR_M/Z 102
MS$FOCUSED_ION: PRECURSOR_TYPE [M-H]-
PK$ANNOTATION: 41.9979886273 84.0449388199 102.0555035062
PK$NUM_PEAK: N/A
PK$PEAK: m/z int. rel.int.
  N/A
'], 
'Method \'getRecordInfo\' works with \'DE server\' and return one record from "KOX00001" id');

##		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
print "\n** Test 13 getRecord with a real list of IDs **\n" ;

is_deeply( getRecordInfoTest('DE',['KOX00002', 'KOX00003', 'FU000001', 'TY000040', 'TY000041', 'FU000002']),
[
          'ACCESSION: KOX00002
RECORD_TITLE: GABA; LC-ESI-QTOF; MS2; MERGED; [M+H]+
DATE: 2011.08.24 (Created 2008.11.28)
AUTHORS: Institute for Advanced Biosciences, Keio Univ.
LICENSE: Copyright 2006-2011 Keio
COMMENT: Peak data in the following records are not open to the public as requested by their authors.
COMMENT: Instead MassBank provides the merged spectra for the public.
COMMENT: This record was generated by merging the following three MassBank records.
COMMENT: [Merging] KO006374 GABA; LC-ESI-QTOF; MS2; CE:10 V [M+H]+
COMMENT: [Merging] KO006375 GABA; LC-ESI-QTOF; MS2; CE:20 V [M+H]+
COMMENT: [Merging] KO006376 GABA; LC-ESI-QTOF; MS2; CE:30 V [M+H]+
COMMENT: [Merging] KO006377 GABA; LC-ESI-QTOF; MS2; CE:40 V [M+H]+
COMMENT: [Merging] KO006378 GABA; LC-ESI-QTOF; MS2; CE:50 V [M+H]+
CH$NAME: GABA
CH$NAME: 4-Aminobutanoate
CH$NAME: 4-Aminobutanoic acid
CH$NAME: 4-Aminobutylate
CH$NAME: 4-Aminobutyrate
CH$NAME: 4-Aminobutyric acid
CH$NAME: gamma-Aminobutyric acid
CH$COMPOUND_CLASS: N/A
CH$FORMULA: C4H9NO2
CH$EXACT_MASS: 103.06333
CH$SMILES: NCCCC(O)=O
CH$IUPAC: InChI=1S/C4H9NO2/c5-3-1-2-4(6)7/h1-3,5H2,(H,6,7)
CH$LINK: CAS 56-12-2
CH$LINK: CHEBI 30566
CH$LINK: KEGG C00334
CH$LINK: NIKKAJI J1.375G
CH$LINK: PUBCHEM SID:3628
AC$INSTRUMENT: Qstar, Applied Biosystems
AC$INSTRUMENT_TYPE: LC-ESI-QTOF
AC$MASS_SPECTROMETRY: MS_TYPE MS2
AC$MASS_SPECTROMETRY: ION_MODE POSITIVE
MS$FOCUSED_ION: PRECURSOR_M/Z 104
MS$FOCUSED_ION: PRECURSOR_TYPE [M+H]+
PK$ANNOTATION: 39.0234750963 45.0340397826 68.0500241978 69.0340397826 86.0605888841 87.0446044689 104.0711535704
PK$NUM_PEAK: N/A
PK$PEAK: m/z int. rel.int.
  N/A
',
          'ACCESSION: KOX00003
RECORD_TITLE: Adenosine; LC-ESI-QTOF; MS2; MERGED; [M-H]-
DATE: 2012.05.21 (Created 2008.11.28)
AUTHORS: Institute for Advanced Biosciences, Keio Univ.
LICENSE: Copyright 2006-2011 Keio
COMMENT: Peak data in the following records are not open to the public as requested by their authors.
COMMENT: Instead MassBank provides the merged spectra for the public.
COMMENT: This record was generated by merging the following three MassBank records.
COMMENT: [Merging] KO004298 Adenosine; LC-ESI-QTOF; MS2; CE:10 V [M-H]-
COMMENT: [Merging] KO004299 Adenosine; LC-ESI-QTOF; MS2; CE:20 V [M-H]-
COMMENT: [Merging] KO004301 Adenosine; LC-ESI-QTOF; MS2; CE:40 V [M-H]-
COMMENT: [Merging] KO004302 Adenosine; LC-ESI-QTOF; MS2; CE:50 V [M-H]-
CH$NAME: Adenosine
CH$COMPOUND_CLASS: N/A
CH$FORMULA: C10H13N5O4
CH$EXACT_MASS: 267.09675
CH$SMILES: OC[C@@H](O1)[C@@H](O)[C@@H](O)[C@@H]1n(c3)c(n2)c(n3)c(N)nc2
CH$IUPAC: InChI=1S/C10H13N5O4/c11-8-5-9(13-2-12-8)15(3-14-5)10-7(18)6(17)4(1-16)19-10/h2-4,6-7,10,16-18H,1H2,(H2,11,12,13)/t4-,6-,7-,10-/m1/s1
CH$LINK: CAS 58-61-7
CH$LINK: CHEBI 16335
CH$LINK: CHEMPDB ADN
CH$LINK: KEGG C00212
CH$LINK: NIKKAJI J4.501B
CH$LINK: PUBCHEM SID:3512
AC$INSTRUMENT: Qstar, Applied Biosystems
AC$INSTRUMENT_TYPE: LC-ESI-QTOF
AC$MASS_SPECTROMETRY: MS_TYPE MS2
AC$MASS_SPECTROMETRY: ION_MODE NEGATIVE
MS$FOCUSED_ION: PRECURSOR_M/Z 266
MS$FOCUSED_ION: PRECURSOR_TYPE [M-H]-
PK$ANNOTATION: 107.0357711171 134.0466701544 136.0623202186 266.0889288996
PK$NUM_PEAK: N/A
PK$PEAK: m/z int. rel.int.
  N/A
',
          'ACCESSION: FU000001
RECORD_TITLE: 3-Man2GlcNAc; LC-ESI-QQ; MS2; CE:15V; Amide
DATE: 2011.05.06 (Created 2009.02.18)
AUTHORS: Matsuura F, Ohta M, Kittaka M, Faculty of Life Science and Biotechnology, Fukuyama University
LICENSE: CC BY-SA
CH$NAME: 3-Man2GlcNAc
CH$NAME: Man-alpha-1-3Man-beta-1-4GlcNac
CH$COMPOUND_CLASS: Natural Product; Oligosaccharide; N-linked glycan; High-mannose type
CH$FORMULA: C20H35NO16
CH$EXACT_MASS: 545.19558
CH$SMILES: CC(=O)NC(C(O)1)C(O)C(OC(O2)C(O)C(OC(O3)C(O)C(O)C(O)C(CO)3)C(O)C(CO)2)C(CO)O1
CH$IUPAC: InChI=1/C20H35NO16/c1-5(25)21-9-12(28)16(8(4-24)33-18(9)32)36-20-15(31)17(11(27)7(3-23)35-20)37-19-14(30)13(29)10(26)6(2-22)34-19/h6-20,22-24,26-32H,2-4H2,1H3,(H,21,25)/t6-,7-,8-,9-,10-,11-,12-,13+,14-,15+,16-,17+,18+,19-,20+/m1/s1/f/h21H
CH$LINK: CHEMSPIDER 24606097
CH$LINK: KEGG G00319
CH$LINK: OligosaccharideDataBase man 547428
CH$LINK: OligosaccharideDataBase2D map5 ODS=1.21 Amide=2.85
AC$INSTRUMENT: 2695 HPLC Quadro Micro API, Waters
AC$INSTRUMENT_TYPE: LC-ESI-QQ
AC$MASS_SPECTROMETRY: MS_TYPE MS2
AC$MASS_SPECTROMETRY: ION_MODE POSITIVE
AC$MASS_SPECTROMETRY: COLLISION_ENERGY 15.0 V
AC$MASS_SPECTROMETRY: DATAFORMAT Centroid
AC$MASS_SPECTROMETRY: DESOLVATION_GAS_FLOW 897 L/Hr
AC$MASS_SPECTROMETRY: DESOLVATION_TEMPERATURE 399 C
AC$MASS_SPECTROMETRY: FRAGMENTATION_METHOD LOW-ENERGY CID
AC$MASS_SPECTROMETRY: IONIZATION ESI
AC$MASS_SPECTROMETRY: SCANNING 1 amu/sec (m/z = 20-2040)
AC$MASS_SPECTROMETRY: SOURCE_TEMPERATURE 100C
AC$CHROMATOGRAPHY: COLUMN_NAME TSK-GEL Amide-80 2.0 mm X 250 mm (TOSOH)
AC$CHROMATOGRAPHY: COLUMN_TEMPERATURE 40 C
AC$CHROMATOGRAPHY: FLOW_GRADIENT 74/26 at 0 min, 50/50 at 60 min.
AC$CHROMATOGRAPHY: FLOW_RATE 0.2 ml/min
AC$CHROMATOGRAPHY: RETENTION_TIME 7.080 min
AC$CHROMATOGRAPHY: SAMPLING_CONE 43.10 V
AC$CHROMATOGRAPHY: SOLVENT CH3CN/H2O
MS$FOCUSED_ION: DERIVATIVE_FORM C29H46N2O17
MS$FOCUSED_ION: DERIVATIVE_MASS 694.27965
MS$FOCUSED_ION: DERIVATIVE_TYPE ABEE (p-Aminobenzoic acid ethyl ester)
MS$FOCUSED_ION: PRECURSOR_M/Z 695.00
MS$FOCUSED_ION: PRECURSOR_TYPE [M+H]+
PK$NUM_PEAK: 8
PK$PEAK: m/z int. rel.int.
  370.8 3.277e5 366
  371.4 3.036e4 34
  532.0 5.812e4 65
  532.6 2.982e5 333
  533.3 5.196e4 58
  694.1 4.564e5 510
  694.8 8.939e5 999
  695.4 5.537e4 62
',
          'ACCESSION: FU000002
RECORD_TITLE: 3-Man2GlcNAc; LC-ESI-QQ; MS2; CE:20V; Amide
DATE: 2011.05.06 (Created 2009.02.18)
AUTHORS: Matsuura F, Ohta M, Kittaka M, Faculty of Life Science and Biotechnology, Fukuyama University
LICENSE: CC BY-SA
CH$NAME: 3-Man2GlcNAc
CH$NAME: Man-alpha-1-3Man-beta-1-5GlcNac
CH$COMPOUND_CLASS: Natural Product; Oligosaccharide; N-linked glycan; High-mannose type
CH$FORMULA: C20H35NO16
CH$EXACT_MASS: 545.19558
CH$SMILES: CC(=O)NC(C(O)1)C(O)C(OC(O2)C(O)C(OC(O3)C(O)C(O)C(O)C(CO)3)C(O)C(CO)2)C(CO)O1
CH$IUPAC: InChI=1/C20H35NO16/c1-5(25)21-9-12(28)16(8(4-24)33-18(9)32)36-20-15(31)17(11(27)7(3-23)35-20)37-19-14(30)13(29)10(26)6(2-22)34-19/h6-20,22-24,26-32H,2-4H2,1H3,(H,21,25)/t6-,7-,8-,9-,10-,11-,12-,13+,14-,15+,16-,17+,18+,19-,20+/m1/s1/f/h21H
CH$LINK: CHEMSPIDER 24606097
CH$LINK: KEGG G00319
CH$LINK: OligosaccharideDataBase man 547428
CH$LINK: OligosaccharideDataBase2D map5 ODS=1.21 Amide=2.85
AC$INSTRUMENT: 2695 HPLC Quadro Micro API, Waters
AC$INSTRUMENT_TYPE: LC-ESI-QQ
AC$MASS_SPECTROMETRY: MS_TYPE MS2
AC$MASS_SPECTROMETRY: ION_MODE POSITIVE
AC$MASS_SPECTROMETRY: COLLISION_ENERGY 20.0 V
AC$MASS_SPECTROMETRY: DATAFORMAT Centroid
AC$MASS_SPECTROMETRY: DESOLVATION_GAS_FLOW 897 L/Hr
AC$MASS_SPECTROMETRY: DESOLVATION_TEMPERATURE 399 C
AC$MASS_SPECTROMETRY: FRAGMENTATION_METHOD LOW-ENERGY CID
AC$MASS_SPECTROMETRY: IONIZATION ESI
AC$MASS_SPECTROMETRY: SCANNING 1 amu/sec (m/z = 20-2040)
AC$MASS_SPECTROMETRY: SOURCE_TEMPERATURE 100C
AC$CHROMATOGRAPHY: COLUMN_NAME TSK-GEL Amide-80 2.0 mm X 250 mm (TOSOH)
AC$CHROMATOGRAPHY: COLUMN_TEMPERATURE 40 C
AC$CHROMATOGRAPHY: FLOW_GRADIENT 74/26 at 0 min, 50/50 at 60 min.
AC$CHROMATOGRAPHY: FLOW_RATE 0.2 ml/min
AC$CHROMATOGRAPHY: RETENTION_TIME 7.088 min
AC$CHROMATOGRAPHY: SAMPLING_CONE 43.10 V
AC$CHROMATOGRAPHY: SOLVENT CH3CN/H2O
MS$FOCUSED_ION: DERIVATIVE_FORM C29H46N2O17
MS$FOCUSED_ION: DERIVATIVE_MASS 694.27965
MS$FOCUSED_ION: DERIVATIVE_TYPE ABEE (p-Aminobenzoic acid ethyl ester)
MS$FOCUSED_ION: PRECURSOR_M/Z 695.00
MS$FOCUSED_ION: PRECURSOR_TYPE [M+H]+
PK$NUM_PEAK: 10
PK$PEAK: m/z int. rel.int.
  324.9 5.549e4 65
  370.8 8.511e5 999
  371.3 8.989e4 106
  486.8 2.622e4 31
  532.0 5.832e4 68
  532.7 3.515e5 413
  533.3 3.910e4 46
  693.9 4.249e4 50
  694.5 1.979e5 232
  695.3 9.682e4 114
',
          'ACCESSION: TY000040
RECORD_TITLE: Aconitine; LC-ESI-ITTOF; MS; [M+H]+
DATE: 2011.05.06 (Created 2008.10.10)
AUTHORS: Ken Tanaka
LICENSE: CC BY-SA
CH$NAME: Aconitine
CH$NAME: NSC56464
CH$NAME: 16-Ethyl-1alpha,6alpha,19beta-trimethoxy-4-(methoxymethyl)-aconitane-3alpha,8,10alpha,11,18alpha-pentol, 8-acetate 10-benzoate
CH$NAME: 20-ethyl-3alpha,13,15alpha-trihydroxy-1alpha,6alpha,16beta-trimethoxy-4-(methoxymethyl)aconitane-8,14alpha-diyl 8-acetate 14-benzoate
CH$COMPOUND_CLASS: Natural Product; Alkaloid
CH$FORMULA: C34H47NO11
CH$EXACT_MASS: 645.31491
CH$SMILES: COC(C7)C(C61[H])(C5([H])2)C(N(CC(COC)6C7O)CC)([H])C(C(C5([H])3)(C(C(OC)C(O)(C(OC(=O)c(c4)cccc4)3)C2)O)OC(C)=O)([H])C1OC
CH$IUPAC: InChI=1S/C34H47NO11/c1-7-35-15-31(16-41-3)20(37)13-21(42-4)33-19-14-32(40)28(45-30(39)18-11-9-8-10-12-18)22(19)34(46-17(2)36,27(38)29(32)44-6)23(26(33)35)24(43-5)25(31)33/h8-12,19-29,37-38,40H,7,13-16H2,1-6H3/t19-,20-,21+,22-,23+,24+,25-,26+,27+,28-,29+,31+,32-,33+,34-/m1/s1
CH$LINK: CAS 302-27-2
CH$LINK: NIKKAJI J9.871J 
CH$LINK: PUBCHEM 245005
AC$INSTRUMENT: Shimadzu LC20A-IT-TOFMS
AC$INSTRUMENT_TYPE: LC-ESI-ITTOF
AC$MASS_SPECTROMETRY: MS_TYPE MS
AC$MASS_SPECTROMETRY: ION_MODE POSITIVE
AC$MASS_SPECTROMETRY: CDL_TEMPERATURE 200 C
AC$MASS_SPECTROMETRY: INTERFACE_VOLTAGE +4.50 kV
AC$MASS_SPECTROMETRY: SCANNING_RANGE 100-2000
AC$CHROMATOGRAPHY: COLUMN_NAME Waters Atlantis T3 (2.1 x 150 mm, 5 um)
AC$CHROMATOGRAPHY: COLUMN_TEMPERATURE 40 C
AC$CHROMATOGRAPHY: FLOW_GRADIENT 10 % B to 100 % B/40 min
AC$CHROMATOGRAPHY: FLOW_RATE 0.2 ml/min
AC$CHROMATOGRAPHY: RETENTION_TIME 1197.701
AC$CHROMATOGRAPHY: SOLVENT (A)5 mM ammonium acetate, (B)CH3CN
MS$FOCUSED_ION: ION_TYPE [M+H]+
PK$NUM_PEAK: 3
PK$PEAK: m/z int. rel.int.
  646.3223 64380108 999
  647.3252 26819201 416
  648.3309 7305831 113
',
          'ACCESSION: TY000041
RECORD_TITLE: Atropine; LC-ESI-ITTOF; MS; [M+H]+
DATE: 2011.05.06 (Created 2008.10.10)
AUTHORS: Ken Tanaka
LICENSE: CC BY-SA
CH$NAME: Atropine
CH$NAME: Benzeneacetic acid, alpha-(hydroxymethyl)- (3-endo)-8-methyl-8-azabicyclo[3.2.1]oct-3-yl ester
CH$NAME: 1alphaH,5alphaH-Tropan-3alpha-ol (+-)-tropate (ester)
CH$NAME: Benzeneacetic acid, alpha-(hydroxymethyl)-, 8-methyl-8-azabicyclo[3.2.1]oct-3-yl ester, endo-
CH$NAME: (+-)-Atropine
CH$NAME: (+-)-Hyoscyamine
CH$NAME: Tropine (+-)-tropate
CH$NAME: dl-Tropyl tropate
CH$NAME: dl-Hyoscyamine
CH$NAME: Tropine tropate
CH$NAME: Atropinol
CH$NAME: Eyesules
CH$NAME: Atropen
CH$NAME: Isopto-atropine
CH$NAME: Troyl tropate
CH$NAME: Belladenal
CH$NAME: Atropina
CH$NAME: Cytospaz
CH$NAME: Donnagel
CH$NAME: Anaspaz
CH$NAME: Atnaa
CH$NAME: Lonox
CH$NAME: Neo-Diophen
CH$NAME: DL-Tropanyl 2-hydroxy-1-phenylpropionate
CH$NAME: 2-Phenylhydracrylic acid 3-alpha-tropanyl ester
CH$NAME: tropan-3alpha-yl 3-hydroxy-2-phenylpropanoate
CH$NAME: 8-Methyl-8-azabicyclo[3.2.1]oct-3-yl tropate
CH$NAME: 8-Methyl-8-azabicyclo[3.2.1]oct-3-yl 3-hydroxy-2-phenylpropanoate
CH$NAME: alpha-(Hydroxymethyl)benzeneacetic acid 8-methyl-8-azabicyclo(3.2.1)oct-3-yl ester
CH$NAME: Benzeneacetic acid, alpha-(hydroxymethyl)-, (3-endo)-8-methyl-8-azabicyclo(3.2.1)oct-3-yl ester
CH$NAME: (3-endo)-8-methyl-8-azabicyclo[3.2.1]oct-3-yl (2S)-3-hydroxy-2-phenylpropanoate
CH$NAME: [(1R,5S)-8-methyl-8-azabicyclo[3.2.1]octan-3-yl] 3-hydroxy-2-phenylpropanoate
CH$NAME: beta-(Hydroxymethyl)benzeneacetic acid 8-methyl-8-azabicyclo[3.2.1]oct-3-yl ester
CH$NAME: endo-(+/-)-alpha-(Hydroxymethyl)benzeneacetic acid 8-methyl-8-azabicyclo[3.2.1]oct-3-yl ester
CH$COMPOUND_CLASS: Natural Product; Alkaloid
CH$FORMULA: C17H23NO3
CH$EXACT_MASS: 289.16779
CH$SMILES: OCC(C(=O)OC(C2)CC(C3)N(C)C(C3)2)c(c1)cccc1
CH$IUPAC: InChI=1S/C17H23NO3/c1-18-13-7-8-14(18)10-15(9-13)21-17(20)16(11-19)12-5-3-2-4-6-12/h2-6,13-16,19H,7-11H2,1H3/t13-,14+,15+,16?
CH$LINK: CAS 51-55-8
CH$LINK: NIKKAJI J237.402A 
CH$LINK: PUBCHEM 174174
AC$INSTRUMENT: Shimadzu LC20A-IT-TOFMS
AC$INSTRUMENT_TYPE: LC-ESI-ITTOF
AC$MASS_SPECTROMETRY: MS_TYPE MS
AC$MASS_SPECTROMETRY: ION_MODE POSITIVE
AC$MASS_SPECTROMETRY: CDL_TEMPERATURE 200 C
AC$MASS_SPECTROMETRY: INTERFACE_VOLTAGE +4.50 kV
AC$MASS_SPECTROMETRY: SCANNING_RANGE 100-2000
AC$CHROMATOGRAPHY: COLUMN_NAME Waters Atlantis T3 (2.1 x 150 mm, 5 um)
AC$CHROMATOGRAPHY: COLUMN_TEMPERATURE 40 C
AC$CHROMATOGRAPHY: FLOW_GRADIENT 10 % B to 100 % B/40 min
AC$CHROMATOGRAPHY: FLOW_RATE 0.2 ml/min
AC$CHROMATOGRAPHY: RETENTION_TIME 641.701
AC$CHROMATOGRAPHY: SOLVENT (A)5 mM ammonium acetate, (B)CH3CN
MS$FOCUSED_ION: ION_TYPE [M+H]+
PK$NUM_PEAK: 2
PK$PEAK: m/z int. rel.int.
  290.1754 109188681 999
  291.1762 21571851 197
'
        ], 
'Method \'getRecordInfo\' works with \'DE server\' and return a list of records from "KOX00002, TY000040, FU000001, KOX00002, TY000040, FU000001" ids');


##		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ARGVTS : $mzs, $intensities, $ion, $instruments, $max, $unit, $tol, $cutoff
print "\n** Test 14 searchSpectrum with a list of mzs, intensities and real search parameters **\n" ;
is_deeply( searchSpectrumTest(
		['273.096', '289.086', '290.118', '291.096', '292.113', '579.169', '580.179'], 
		['300', '300', '300', '300', '300', '300', '300'],
		'Positive', # mode
		['all'],		# instrument
		'2',		# max return / only 2 for test
		'unit',		# unit (unit or ppm)
		0.3, 		# tol with unit = unit / can be also 50 with unit = ppm
		50			# cutoff
	), 
	[
		{
			'title' => 'Lormetazepam; LC-ESI-Q; MS; POS; 60 V',
			'exactMass' => '334.02758',
			'score' => '0.428034082411',
			'id' => 'WA001260',
			'formula' => 'C16H12Cl2N2O2'
		},
		{
			'formula' => 'C16H12Cl2N2O2',
			'exactMass' => '334.02758',
			'score' => '0.385859601865',
			'id' => 'WA001261',
			'title' => 'Lormetazepam; LC-ESI-Q; MS; POS; 45 V'
		}
	], 
'Method \'searchSpectrum\' works with \'DE server\' and return a list of entries from given mzs list with no intensity (very low in true)');

##		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ARGVTS : $mzs, $intensities, $ion, $instruments, $max, $unit, $tol, $cutoff
print "\n** Test 15 searchSpectrum with a list of mzs, intensities and real search parameters **\n" ;
is_deeply( searchSpectrumTest(
		['273.096', '289.086', '290.118', '291.096', '292.113', '579.169', '580.179'], 
		['5', '5', '5', '5', '5', '5', '5'],
		'Positive', # mode
		['all'],		# instrument
		'2',		# max return / only 2 for test
		'unit',		# unit (unit or ppm)
		0.3, 		# tol with unit = unit / can be also 50 with unit = ppm
		50			# cutoff
	), 
	[
		{
			'title' => 'Lormetazepam; LC-ESI-Q; MS; POS; 60 V',
			'exactMass' => '334.02758',
			'score' => '0.428034082411',
			'id' => 'WA001260',
			'formula' => 'C16H12Cl2N2O2'
		},
		{
			'formula' => 'C16H12Cl2N2O2',
			'exactMass' => '334.02758',
			'score' => '0.385859601865',
			'id' => 'WA001261',
			'title' => 'Lormetazepam; LC-ESI-Q; MS; POS; 45 V'
		}
	], 
'Method \'searchSpectrum\' works with \'DE server\' and return a list of entries from given mzs list');


##		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ARGVTS : $mzs, $intensities, $ion, $instruments, $max, $unit, $tol, $cutoff
print "\n** Test 16 searchSpectrum with a list of mzs, intensities and max = 2 **\n" ;
is_deeply( searchSpectrumNBTest(
		['273.096', '289.086', '290.118', '291.096', '292.113', '579.169', '580.179'], 
		['300', '300', '300', '300', '300', '300', '300'],
		'Positive', # mode
		['all'],	# instrument
		'2',		# max return / only 2 for test
		'unit',		# unit (unit or ppm)
		0.3, 		# tol with unit = unit / can be also 50 with unit = ppm
		50			# cutoff
	), 
	2, 
'Method \'searchSpectrum\' works with \'DE server\' and return the right number of entries from given mzs list and parameters (max)');

##		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ARGVTS : $mzs, $intensities, $ion, $instruments, $max, $unit, $tol, $cutoff
print "\n** Test 17 searchSpectrum with a list of mzs, but no intensity (in true very low) and max = 2 **\n" ;
is_deeply( searchSpectrumNBTest(
		['273.096', '289.086', '290.118', '291.096', '292.113', '579.169', '580.179'], 
		[10, 10, 10, 10, 10, 10, 10 ],
		'Positive', # mode
		['all'],	# instrument
		'2',		# max return / only 2 for test
		'unit',		# unit (unit or ppm)
		0.3, 		# tol with unit = unit / can be also 50 with unit = ppm
		50			# cutoff
	), 
	2, 
'Method \'searchSpectrum\' works with \'DE server\' and return the right number of entries from given mzs list and no intensity');

##		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ARGVTS : $mzs, $intensities, $ion, $instruments, $max, $unit, $tol, $cutoff
print "\n** Test 18 searchSpectrum with a list of mzs, intensities and no optionnal parameter like instrument, unit, tolerance and cutoff **\n" ;
is_deeply( searchSpectrumNBTest(
		['273.096', '289.086', '290.118', '291.096', '292.113', '579.169', '580.179'], 
		['300', '300', '300', '300', '300', '300', '300'],
		'Positive', # mode
		undef,		# instrument
		'2',		# max return / only 2 for test
		undef,		# unit (unit or ppm)
		undef, 		# tol with unit = unit / can be also 50 with unit = ppm
		undef		# cutoff
	), 
	2, 
'Method \'searchSpectrum\' works with \'DE server\' and return the right number of entries from def parameters (instrument, unit, tolerance, cutoff )');

##		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ARGVTS : $mzs, $intensities, $ion, $instruments, $max, $unit, $tol, $cutoff, $max
print "\n** Test 19 searchSpectrum with a list of mzs, intensities and no conf parameters for instrument, unit, tolerance and cutoff (value by default) **\n" ;
is_deeply( searchSpectrumNBTest(
		['273.096', '289.086', '290.118', '291.096', '292.113', '579.169', '580.179'], 
		['300', '300', '300', '300', '300', '300', '300'],
		'Positive', # mode
		undef,		# instrument - ['all'] by default
		undef,		# max return - 0 by default
		undef,		# unit - unit by default
		undef, 		# tol - 0.3  (by default) with unit = unit / can be also 50  (by default) with unit = ppm
		undef		# cutoff - 5 by default
	), 
	369, 
'Method \'searchSpectrum\' works with \'DE server\' and return the right number of entries (363) with undef parameters (instrument, unit, tolerance, cutoff, max )');

##		- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ARGVTS : $ids
print "\n** Test 20 getPeak with a list ids **\n" ;
is_deeply( getPeakTest( ['PR020003', 'FU000001']), 
	[
		{
			'numPeaks' => '9',
			'mzs' => ['207.0897','210.0499','224.5345','225.2768','226.0377','226.9938','227.9228','243.1025','410.0056'],
			'intensities' => ['8.488e2','9.442e2','1.093e3','5.294e4','2.896e4','7.015e3','7.870e2','4.024e3','5.620e2'],
			'id' => 'PR020003'
		},
		{
			'id' => 'FU000001',
			'intensities' => ['3.277e5', '3.036e4', '5.812e4', '2.982e5', '5.196e4','4.564e5', '8.939e5','5.537e4'],
			'mzs' => ['370.8', '371.4', '532.0', '532.6', '533.3', '694.1', '694.8','695.4'],
			'numPeaks' => '8'
		}
	],
'Method \'getPeak\' works with \'DE server\' and return the peak lists from given ids list');




print "\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n" ;

}
else {
	croak "Can\'t launch any test : no sequence clearly defined !!!!\n" ;
}

