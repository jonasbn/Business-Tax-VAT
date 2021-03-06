[![CPAN version](https://badge.fury.io/pl/Business-Tax-VAT.svg)](http://badge.fury.io/pl/Business-Tax-VAT)
[![Build Status](https://travis-ci.org/jonasbn/Business-Tax-VAT.svg?branch=master)](https://travis-ci.org/jonasbn/Business-Tax-VAT)
[![Coverage Status](https://coveralls.io/repos/jonasbn/Business-Tax-VAT/badge.png)](https://coveralls.io/r/jonasbn/Business-Tax-VAT)

# NAME

Business::Tax::VAT - perform European VAT calculations

# VERSION

This pod describes version 1.12

# SYNOPSIS

    use Business::Tax::VAT;

    my $vat = Business::Tax::VAT->new(qw/at ie/);

    my $price = $vat->item(120 => 'ie');
    my $price_to_customer = $price->full;     # 120
    my $vat_charged       = $price->vat;      #  20
    my $net_price_to_me   = $price->net;      # 100

    my $price = $vat->business_item(102 => 'at');
    my $price_to_customer = $price->full;     # 102
    my $vat_charged       = $price->vat;      #  17
    my $net_price_to_me   = $price->net;      #  85

# DESCRIPTION

Charging VAT across the European Union is quite complex. The rate of tax
you have to charge depends on whether you're dealing with consumers or
corporations, what types of goods you're selling, whether you've crossed
thresholds in certain countries, etc.

This module aims to make some of this simpler.

There are several key processes:

# CONSTRUCTING A VAT OBJECT

## new

    my $vat = Business::Tax::VAT->new(@country_codes);

First of all you have to construct a VAT object, providing it with
a list of countries for which you have to charge VAT. This may only
be the country in which you are trading, or it may be any of the
15 EC territories in which VAT is collected.

The full list of territories, and their abbreviations, is documented
below.

# PRICING AN ITEM

## item / business\_item

    my $price = $vat->item($unit_price => $country_code);
    my $price = $vat->business_item($unit_price => $country_code);

You create a Price object by calling either the 'item' or 'business\_item'
constructor, with the unit price, and the country to which you are
supplying the goods. This operates on the priciple that prices to
consumers are quoted with VAT included, but prices to business are
quoted ex-VAT.

If you do not supply a country code, it will default to the first country
in the country list passed to VAT->new;

# CALCULATING THE COMPONENT PRICES

## full / vat / net

    my $price_to_customer = $price->full;
    my $vat_charged       = $price->vat;
    my $net_price_to_me   = $price->net;

Once we have our price, we can query it for either the 'full' price
that will be charged (including VAT), the 'net' price (excluding VAT),
and the 'vat' portion itself.

# NON-VATABLE COUNTRIES

If you send goods to many countries, some of which are in your VAT
territory and others not, you can avoid surrounding this code in
conditionals by calling $vat->item on all items anyway, listing the
country to which you are supplying the goods.

If the country in question is not one of the territories in which you
should charge VAT then the 'full' and 'net' values will be the same,
and 'vat' will be zero.

# NON-VATABLE, ZERO-RATED, REDUCED-RATE GOODS

This module does not cope with goods which are not at the 'standard'
rate of VAT for a country (as detailed below).

Patches welcomed!

# COUNTRIES AND RATES

This module uses the following rates and codes:

    at, Austria, 20%
    be, Belgium, 21%
    bg, Bulgaria 20%
    hr, Croatia 25%
    cy, Cyprus, 19%
    cz, Czech Republic, 21%
    dk, Denmark, 25%
    ee, Estonia, 20%
    fi, Finland, 24%
    fr, France, 20%
    de, Germany, 19%
    gr, Greece, 24%
    hu, Hungary, 27%
    ie, Ireland, 23%
    it, Italy, 22%
    lv, Latvia, 21%
    lt, Lithuania, 21%
    lu, Luxembourg, 17%
    mt, Malta, 18%
    nl, The Netherlands, 21%
    pl, Poland, 23%
    pt, Portugal, 23%
    ro, Romania 19%
    sk, Slovak Republic, 20%
    si, Slovenia, 22%
    es, Spain, 21%
    se, Sweden, 25%

If any of these rates become incorrect, or if you wish to use
different rates due to the nature of the product (e.g. transport is 0%
VAT in Austria), then you can (locally) set the rate by assigning to
%Business::Tax::VAT::Price::RATE.  e.g.:

    local $Business::Tax::VAT::Price::RATE{at} = 0
      if ($product_type eq 'book' and $country eq 'at');

# DYNAMICALLY ADDING A COUNTRY

If you want to add your own country, do the following:

    my $vat = Business::Tax::VAT->new(qw/gb/);

    $Business::Tax::VAT::Price::RATE{'gb'} = 20;

    my $price = $vat->item(102 => 'gb');

# SEE ALSO

- [European Commission Taxes database, search engine](https://ec.europa.eu/taxation_customs/tedb/splSearchForm.html)
- [Resource for current and historic VAT rates](http://www.vatlive.com/)

# AUTHOR

- Tony Bowden
- Jonas B. (jonasbn), current maintainer

# BUGS and QUERIES

Please direct all correspondence regarding this distribution to:

- [GitHub](https://github.com/jonasbn/Business-Tax-VAT/issues)

# ACKNOWLEDGEMENTS

- Documentation added in release 1.10 based on question from Tom Kirkpatrick
- Sam Kington, patches leading to release of 1.07 and 1.08

# COPYRIGHT

    Copyright (C) 2001-2021 Tony Bowden.

    This program is free software; you can redistribute it and/or modify it under
    the terms of the GNU General Public License; either version 2 of the License,
    or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.
