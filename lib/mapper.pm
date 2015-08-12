package lib::mapper ;

use strict;
use warnings ;
use Exporter ;
use Carp ;

use Data::Dumper ;

use vars qw($VERSION @ISA @EXPORT %EXPORT_TAGS);

our $VERSION = "1.0";
our @ISA = qw(Exporter);
our @EXPORT = qw( get_pcgroup_list get_pcgroups);
our %EXPORT_TAGS = ( ALL => [qw( get_pcgroup_list get_pcgroups )] );

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
    my ( $pcs, $mzs, $ints, $names ) = @_;
    
    my %pcgroups = () ;
    my $i = 0 ;
    
    ## Warn diff matrix dimension :
    my $num_pcs = scalar(@{$pcs}) ;
    my $num_mzs = scalar(@{$mzs}) ;
    my $num_ints = scalar(@{$ints}) ;
    my $num_names = scalar(@{$names}) ;
    
    if ( ($num_pcs == $num_mzs ) and ( $num_mzs == $num_ints ) and  ( $num_ints== $num_names ) ) {
		my @pcs = @{$pcs} ;
    	
    	foreach my $pc (@{$pcs}) {
	    	
	    	if ( ! $pcgroups{$pc} ) { $pcgroups{$pc}->{'id'} = 'pcgroup'.$pc ;	$pcgroups{$pc}->{'annotation'} = {} ; $pcgroups{$pc}->{'massbank_ids'} = [] ; }
	    	
	    	push (@{$pcgroups{$pc}->{'mzmed'}}, $mzs->[$i]) if ($mzs->[$i]) ; ## map mzs by pcgroup
	    	push (@{$pcgroups{$pc}->{'into'}}, $ints->[$i]) if ($ints->[$i]) ; ## map into by pcgroup
	    	push (@{$pcgroups{$pc}->{'names'}}, $names->[$i]) if ($names->[$i]) ; ## map name by pcgroup

	    	$i++ ;
	    }
    }
    else {
    	warn "The different ARRAYS (pcs, mzs, ints, names) doesn't have the same size : mapping is not possible \n!!"
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