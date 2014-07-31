package Business::Tax::VAT;

$VERSION = '1.01';

use strict;
use warnings;

=head1 NAME

Business::Tax::VAT - perform European VAT calculations

=head1 SYNOPSIS

  use Business::Tax::VAT;

  my $vat = Business::Tax::VAT->new(qw/uk ie/);

  my $price = $vat->item(120 => 'ie');
  my $price_to_customer = $price->full;     # 120
  my $vat_charged       = $price->vat;      #  20
  my $net_price_to_me   = $price->net;      # 100

  my $price = $vat->business_item(100 => 'uk');
  my $price_to_customer = $price->full;     # 117.5
  my $vat_charged       = $price->vat;      #  17.5
  my $net_price_to_me   = $price->net;      # 100

=cut

sub new {
	my $class = shift;
	my %countries = map { $_ => 1 } @_;
	bless {
		default   => $_[0],
		countries => \%countries,
	}, $class;
}

sub _is_vat_country { $_[0]->{countries}->{ lc $_[1] } || 0 }
sub _default_country { $_[0]->{default} }

sub item          { my $self = shift; $self->_item(1, @_) }
sub business_item { my $self = shift; $self->_item(0, @_) }

sub _item {
	my $self    = shift;
	my $incl    = shift;
	my $price   = shift or die "items need a price";
	my $country = shift || $self->_default_country;
	return Business::Tax::VAT::Price->new($self, $price, $country, $incl);
}

package Business::Tax::VAT::Price;

our %RATE = (
	at   => 20,
	be   => 21,
	cy   => 15,
	cz   => 19,
	dk   => 25,
	ee   => 18,
	fi   => 22,
	fr   => 19.6,
	de   => 19,
	gr   => 17.5,
	hu   => 25,
	ie   => 21,
	it   => 22,
	lv   => 18,
	'lt' => 17.5,
	lu   => 15,
	mt   => 18,
	nl   => 19,
	pl   => 22,
	pt   => 21,
	sk   => 19,
	si   => 20,
	es   => 16,
	se   => 25,
	uk   => 20,
);

sub new {
	my ($class, $vat_obj, $price, $country, $incl) = @_;
	my $self = {};

	my $rate = ($RATE{ lc $country } || 0) / 100;
	$rate = 0 unless $vat_obj->_is_vat_country($country);

	if ($incl == 0) {
		$self->{net}  = $price;
		$self->{vat}  = $self->{net} * $rate;
		$self->{full} = $self->{net} + $self->{vat};
	} else {
		$self->{full} = $price;
		$self->{net}  = $self->{full} / (1 + $rate);
		$self->{vat}  = $self->{full} - $self->{net};
	}
	bless $self, $class;
}

sub full { $_[0]->{full} }
sub vat  { $_[0]->{vat} }
sub net  { $_[0]->{net} }

=head1 DESCRIPTION

Charging VAT across the European Union is quite complex. The rate of tax
you have to charge depends on whether you're dealing with consumers or
corporations, what types of goods you're selling, whether you've crossed
thresholds in certain countries, etc.

This module aims to make some of this simpler.

There are several key processes:

=head1 CONSTRUCTING A VAT OBJECT

=head2 new

  my $vat = Business::Tax::VAT->new(@country_codes);

First of all you have to construct a VAT object, providing it with
a list of countries for which you have to charge VAT. This may only
be the country in which you are trading, or it may be any of the
15 EC territories in which VAT is collected.

The full list of territories, and their abbreviations, is documented
below.

=head1 PRICING AN ITEM

=head2 item / business_item

  my $price = $vat->item($unit_price => $country_code);
  my $price = $vat->business_item($unit_price => $country_code);

You create a Price object by calling either the 'item' or 'business_item'
constructor, with the unit price, and the country to which you are
supplying the goods. This operates on the priciple that prices to
consumers are quoted with VAT included, but prices to business are
quoted ex-VAT.

If you do not supply a country code, it will default to the first country
in the country list passed to VAT->new;

=head1 CALCULATING THE COMPONENT PRICES

=head2 full / vat / net

  my $price_to_customer = $price->full;
  my $vat_charged       = $price->vat;
  my $net_price_to_me   = $price->net;

Once we have our price, we can query it for either the 'full' price
that will be charged (including VAT), the 'net' price (excluding VAT),
and the 'vat' portion itself.

=head1 NON-VATABLE COUNTRIES

If you send goods to many countries, some of which are in your VAT
territory and others not, you can avoid surrounding this code in
conditionals by calling $vat->item on all items anyway, listing the
country to which you are supplying the goods.

If the country in question is not one of the territories in which you
should charge VAT then the 'full' and 'net' values will be the same,
and 'vat' will be zero.

=head1 NON-VATABLE, ZERO-RATED, REDUCED-RATE GOODS

This module does not cope with goods which are not at the 'standard'
rate of VAT for a country (as detailed below).

Patches welcomed!

=head1 COUNTRIES AND RATES

This module uses the following rates and codes:

  at, Austria, 20%
  be, Belgium, 21%
  cy, Cyprus, 15%
  cz, Czech Republic, 19%
  dk, Denmark, 25%
  ee, Estonia, 18%
  fi, Finland, 22%
  fr, France, 19.6%
  de, Germany, 19%
  gr, Greece, 17.5%
  hu, Hungary, 25%
  ie, Ireland, 21%
  it, Italy, 22%
  lv, Latvia, 18%
  lt, Lithuania, 17.5%
  lu, Luxembourg, 15%
  mt, Malta, 18%
  nl, The Netherlands, 19%
  pl, Poland, 22%
  pt, Portugal, 21%
  sk, Slovak Republic, 19%
  si, Slovenia, 20%
  es, Spain, 16%
  se, Sweden, 25%
  uk, United Kingdom, 20%

If any of these rates become incorrect, or if you wish to use
different rates due to the nature of the product (e.g. books are 0%
VAT in the UK), then you can (locally) set the rate by assigning to
%Business::Tax::VAT::Price::RATE.  e.g.:

  local $Business::Tax::VAT::Price::RATE{uk} = 0 
    if ($product_type eq 'book' and $country eq 'uk');

=head1 AUTHOR

Tony Bowden

=head1 BUGS and QUERIES

Please direct all correspondence regarding this module to:
  bug-Business-Tax-VAT@rt.cpan.org

=head1 COPYRIGHT

  Copyright (C) 2001-2014 Tony Bowden.

  This program is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License; either version 2 of the License,
  or (at your option) any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.

=cut

1;
