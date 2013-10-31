use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME      => 'cerit-maintenance',
  PREREQ_PM => {
    'Text::CSV' => 0,
  },
);
