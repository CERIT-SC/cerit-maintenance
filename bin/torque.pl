#!/usr/bin/perl -w
# 
# Read CERIT-SC's CSV maintenance list and apply changes
# to Torque nodes (set or unset maintenance or reserved state).
# This script should be regularly executed via cron.
#

use strict;
use LWP::Simple;
use Text::CSV;
use Date::Parse;
use XML::Simple;
use Getopt::Std;

my $url = 'https://raw.github.com/CERIT-SC/cerit-maintenance/master/maintenance.csv';

my %opts;
getopts('d',\%opts);

=item get_maintenances($url);

Fetch CSV maintenance list and return ARRAY of active maintenances.

=cut
sub get_maintenances($) {
	my $c = get($_[0]);
	die('Could not fetch CSV')
		unless $c;

	my $csv = Text::CSV->new()
		or die('Could not use CSV: '.Text::CSV->error_diag());

	my @rtn;
	my $rn = 0;
	for my $r (split(/\n/, $c)) {
		next if $rn++ == 0;
		die('Parse error: '.$r)
			unless $csv->parse($r);
		my @columns = $csv->fields();

		$columns[1] .= ' 23:59:99'
			if $columns[1] =~ /^\d{4}-\d{1,2}-\d{1,2}$/;
		my $t_e = str2time($columns[1]);
		my $t_s = str2time($columns[0]);
		my $t = time();

		# check if still under maintenance
		if (($t>=$t_s) and ((! defined $t_e) or ($t<=$t_e))) {
			push(@rtn, {
				from	=> $t_s,
				to		=> $t_e,
				type	=> $columns[2],
				note	=> $columns[3],
				nodes	=> [split(/ /,$columns[4])],
			});
		}
	}

	return(\@rtn);
}

=item get_nodes();

Get HASH of all Torque nodes with thier queue and notes.

=cut
sub get_nodes() {
	open(my $fh, '-|', 'pbsnodes -x') or die $!;
	my @x = <$fh>;
	close($fh);

	my %rtn;
	my $xml = XMLin(join("\n", @x));
	for my $node (keys %{$xml->{Node}}) {
		my $d = $xml->{Node}->{$node};
		$rtn{$node} = {
			queue	=> $d->{queue} ? $d->{queue} : '',
			note	=> $d->{note} ? $d->{note} : '',
		}
	}

	return(\%rtn);
}


=item set_node($name, $current_data, $maintenance_data);

Compare current and required node state and apply change.

=cut
sub set_node($$$) {
	my ($name,$data,$maint) = @_;
	my ($new_queue,$new_note) = ('','');
	my ($old_queue,$old_note) = ('','');

	# maintenance state
	if ($maint) {
		$maint->{type} =~ /(maintenance|reserved)$/;
		$new_queue = $1;
		$new_note = $maint->{note};
	}

	# current state
	if ($data) {
		$old_queue = $data->{queue};
		$old_note = $data->{note};
	}

	if ($old_queue ne $new_queue) {
		print(<<EOF);
Torque node: ${name}
- set queue '${old_queue}' -> '${new_queue}'
- set note '${old_note}' -> '${new_note}'

EOF

		# change node settings unles '-d' (dry) specified
		unless (exists $opts{'d'}) {
			system('qmgr','-c',"set node ${name} queue = '${new_queue}'");
			system('qmgr','-c',"set node ${name} note = '${new_note}'");
		}
	}
}

#####

my $maints	= get_maintenances($url);
my $nodes	= get_nodes();

for my $name (keys %$nodes) {
	$name =~ /^(\D+)\d+(\..*)$/;
	my $cluster="$1$2";
	my $current_maint;

	# first search for cluster wide maintenances
	for my $maint (@$maints) {
		for my $maint_node (@{$maint->{nodes}}) {
			if ($cluster eq $maint_node) {
				$current_maint = $maint;
				last;
			}
		}

		last if $current_maint;
	}

	# than for particular node maintenance
	if (! $current_maint) {
		for my $maint (@$maints) {
			for my $maint_node (@{$maint->{nodes}}) {
				if ($name eq $maint_node) {
					$current_maint = $maint;
					last;
				}
			}

			last if $current_maint;
		}
	}

	# apply changes
	set_node($name,
		$nodes->{$name},
		$current_maint);
}

# vim: ts=4
