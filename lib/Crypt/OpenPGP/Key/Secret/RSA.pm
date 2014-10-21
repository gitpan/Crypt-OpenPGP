# $Id: RSA.pm,v 1.8 2001/07/26 02:34:41 btrott Exp $

package Crypt::OpenPGP::Key::Secret::RSA;
use strict;

use Crypt::RSA::Key::Private;
use Crypt::OpenPGP::Key::Public::RSA;
use Crypt::OpenPGP::Key::Secret;
use Crypt::OpenPGP::Util qw( bin2mp );
use Crypt::OpenPGP::ErrorHandler;
use base qw( Crypt::OpenPGP::Key::Secret Crypt::OpenPGP::ErrorHandler );

sub secret_props { qw( d p q u ) }
sub sig_props { qw( c ) }
*public_props = \&Crypt::OpenPGP::Key::Public::RSA::public_props;
*crypt_props = \&Crypt::OpenPGP::Key::Public::RSA::crypt_props;
*size = \&Crypt::OpenPGP::Key::Public::RSA::size;
*encode = \&Crypt::OpenPGP::Key::Public::RSA::encode;
*keygen = \&Crypt::OpenPGP::Key::Public::RSA::keygen;

sub init {
    my $key = shift;
    $key->{key_data} = shift ||
        Crypt::RSA::Key::Private->new( Password => 'pgp' );
    $key;
}

*encrypt = \&Crypt::OpenPGP::Key::Public::RSA::encrypt;

sub decrypt {
    my $key = shift;
    my($C) = @_;
    require Crypt::RSA::Primitives;
    my $prim = Crypt::RSA::Primitives->new;
    $prim->core_decrypt( Key => $key->{key_data}, Cyphertext => $C->{c} );
}

sub sign {
    my $key = shift;
    my($dgst, $hash_alg) = @_;
    my $m = encode($dgst, $hash_alg, $key->bytesize - 1);
    require Crypt::RSA::Primitives;
    my $prim = Crypt::RSA::Primitives->new;
    $m = bin2mp($m);
    my $c = $prim->core_sign( Key => $key->{key_data}, Message => $m );
    { c => $c }
}

1;
