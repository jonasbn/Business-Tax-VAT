use ExtUtils::MakeMaker;

WriteMakefile(
    NAME		=> 'Business::Tax::VAT',
    VERSION_FROM	=> 'lib/Business/Tax/VAT.pm', 
    PREREQ_PM		=> { 
                              Test::More => 0.17,
                           }, 
    ($] > 5.005 ? () : (
      ABSTRACT_FROM => 'lib/Business/Tax/VAT.pm', 
      AUTHOR        => 'Tony Bowden <kasei@tmtm.com>',
    )),
);
