#!/usr/bin/perl -w

use Test::More;

use strict;
BEGIN {
    eval {
        require Test::MockTime;
    };
    require Business::Tax::VAT;
}

my $vat = Business::Tax::VAT->new(qw/uk ie/);

{
  my $price = $vat->item(102 => 'uk');
  is $price->full, 102, "Full price correct - UK consumer";
  is $price->vat,  17,  "VAT correct - UK consumer";
  is $price->net,  85,   "Net price correct - UK consumer";
}

{
  my $price = $vat->item(102);
  is $price->full, 102, "Full price correct - implied UK consumer";
  is $price->vat,  17, "VAT correct - implied UK consumer";
  is $price->net,  85,   "Net price correct - implied UK consumer";
}

{
  my $price = $vat->item(123 => 'ie');
  is $price->full, 123, "Full price correct - ie consumer";
  is $price->vat,   23, "VAT correct - ie consumer";
  is $price->net,  100, "Net price correct - ie consumer";
}

{
  my $price = $vat->item(123 => 'IE');
  is $price->full, 123, "Full price correct - IE consumer";
  is $price->vat,   23, "VAT correct - IE consumer";
  is $price->net,  100, "Net price correct - IE consumer";
}

{
  my $price = $vat->business_item(100 => 'IE');
  is $price->full, 123, "Full price correct - IE business";
  is $price->vat,   23, "VAT correct - IE business";
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

_test_luxembourg_vat();

if ($INC{'Test/MockTime.pm'}) {
    subtest(
        'Before 2015, Luxembourg VAT is correct',
        sub {
            Test::MockTime::set_fixed_time('2014-12-31T23:59:00Z');
            _test_luxembourg_vat();
        }
    );
    subtest(
        'After 2015, Luxembourg VAT is correct',
        sub {
            Test::MockTime::set_fixed_time('2015-01-01T01:00:00Z');
            _test_luxembourg_vat();
        }
    );
} elsif ($ENV{AUTHOR_TESTING}) {
    fail(q{Test::MockTime not loaded, cannot check Luxembourg VAT});
}

done_testing();

sub _test_luxembourg_vat {
    my $vat_lu = Business::Tax::VAT->new('lu');
    Business::Tax::VAT::Price->_calculate_vat_rates;
    my $price = $vat_lu->business_item(100);
    my ($year) = (gmtime time)[5] + 1900;
    if ($year == 2015) {
        is $price->vat, 17, 'This is 2015 - Luxembourg has 17% VAT';
    } elsif ($year < 2015) {
        is $price->vat, 15, 'Before 2015, Luxembourgh has 15% VAT';
    } else {
        fail "Luxembourg could have done anything by $year";
    }
}

