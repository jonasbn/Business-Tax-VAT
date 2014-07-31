#!/usr/bin/perl -w

use Test::More tests => 21;

use strict;
use Business::Tax::VAT;

my $vat = Business::Tax::VAT->new(qw/uk ie/);

{
  my $price = $vat->item(117.5 => 'uk');
  is $price->full, 117.5, "Full price correct - UK consumer";
  is $price->vat,  19.5833333333333,  "VAT correct - UK consumer";
  is $price->net,  97.9166666666667,   "Net price correct - UK consumer";
}

{
  my $price = $vat->item(117.5);
  is $price->full, 117.5, "Full price correct - implied UK consumer";
  is $price->vat,  19.5833333333333, "VAT correct - implied UK consumer";
  is $price->net,  97.9166666666667,   "Net price correct - implied UK consumer";
}

{
  my $price = $vat->item(121 => 'ie');
  is $price->full, 121, "Full price correct - ie consumer";
  is $price->vat,   21, "VAT correct - ie consumer";
  is $price->net,  100, "Net price correct - ie consumer";
}

{
  my $price = $vat->item(121 => 'IE');
  is $price->full, 121, "Full price correct - IE consumer";
  is $price->vat,   21, "VAT correct - IE consumer";
  is $price->net,  100, "Net price correct - IE consumer";
}

{
  my $price = $vat->business_item(100 => 'IE');
  is $price->full, 121, "Full price correct - IE business";
  is $price->vat,   21, "VAT correct - IE business";
  is $price->net,  100, "Net price correct - IE business";
}

{
  my $price = $vat->item(100 => 'de');
  is $price->full, 100, "Full price correct - de consumer";
  is $price->vat,    0, "No VAT - de consumer";
  is $price->net,  100, "Net price correct - de consumer";
}

{
	local $Business::Tax::VAT::Price::RATE{uk} = 0;
  my $price = $vat->item(100 => 'uk');
  is $price->full, 100, "Full price correct - uk book";
  is $price->vat,    0, "No VAT - uk book";
  is $price->net,  100, "Net price correct - uk book";
}

