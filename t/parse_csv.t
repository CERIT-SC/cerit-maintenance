use strict;
use warnings;

use Test::More;
use Text::CSV;

open( my $fh, '<:encoding(utf8)', 'maintenance.csv') or die;
my $csv = Text::CSV->new()
	or die 'Cannot use CSV: '.Text::CSV->error_diag();

while (my $row = $csv->getline($fh)) {
	# each row contains 5 columns
	isa_ok( $row, 'ARRAY' );
	is( scalar(@$row), 5 );

	if ($.>1) {
		# 1. start datetime:
		# YYYY-MM-DD or YYYY-MM-DD HH:MM
		like( $row->[0], qr/^\d{4}-\d{1,2}-\d{1,2}( \d{1,2}:\d{1,2})?$/ );

		# 2. end datetime:
		# YYYY-MM-DD or YYYY-MM-DD or empty
		like( $row->[1], qr/^(\d{4}-\d{1,2}-\d{1,2}( \d{1,2}:\d{1,2})?)?$/ );

		# 3. maintenance type:
		# planned-maintenance, maintenance, reserved or empty
		like( $row->[2], qr/^((planned-)?(maintenance|reserved))?$/ );

		# 5. resources:
		my @resources = split(' ', $row->[4]);
		ok( scalar(@resources) > 0 );
	}
}

$csv->eof or $csv->error_diag();
close($fh);
done_testing();
