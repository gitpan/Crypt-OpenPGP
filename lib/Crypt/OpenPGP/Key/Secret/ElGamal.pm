# $Id: ElGamal.pm,v 1.6 2001/07/26 02:34:41 btrott Exp $

package Crypt::OpenPGP::Key::Secret::ElGamal;
use strict;

use Crypt::OpenPGP::Key::Public::ElGamal;
use Crypt::OpenPGP::Key::Secret;
use Crypt::OpenPGP::ErrorHandler;
use base qw( Crypt::OpenPGP::Key::Secret Crypt::OpenPGP::ErrorHandler );

sub secret_props { qw( x ) }
*public_props = \&Crypt::OpenPGP::Key::Public::ElGamal::public_props;
*crypt_props = \&Crypt::OpenPGP::Key::Public::ElGamal::crypt_props;
*size = \&Crypt::OpenPGP::Key::Public::ElGamal::size;
*keygen = \&Crypt::OpenPGP::Key::Public::ElGamal::keygen;

sub init {
    my $key = shift;
    $key->{key_data} = shift || Crypt::OpenPGP::ElGamal::Private->new;
    $key;
}

sub decrypt { $_[0]->{key_data}->decrypt(@_[1..$#_]) }

package Crypt::OpenPGP::ElGamal::Private;
use strict;

use Crypt::OpenPGP::Util qw( mod_exp mod_inverse );
use Math::Pari qw( Mod lift );

sub new { bless {}, $_[0] }

sub decrypt {
    my $key = shift;
    my($C) = @_;
    my $p = $key->p;
    my $t1 = mod_exp($C->{a}, $key->x, $p);
    $t1 = mod_inverse($t1, $p);
    my $output = Mod($C->{b}, $p);
    lift($output * $t1);
}

sub _getset {
    my $e = shift;
    sub {
        my $key = shift;
        $key->{$e} = shift if @_;
        $key->{$e};
    }
}

*p = _getset('p');
*g = _getset('g');
*y = _getset('y');
*x = _getset('x');

1;
