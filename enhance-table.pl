#!/usr/bin/perl

use strict;
use warnings;

# ANSI color escape codes
my $G = "\e[48;2;28;28;28m"; # Dark gray color, same as TaskWarrior (1c1c1c)
my $R = "\e[0m";        # Reset color
my $Y = "\e[1;33m";     # Yellow color for the header

# Read the table from stdin
my @table;
while (<STDIN>) {
    chomp;
    push @table, $_;
}

if (@table > 3){
    print $Y.$table[0].$R."\n";  # Print only the header (first row) of the table with color
    print $table[1]."\n";         # Print the second line
    # Print the rest of the table
    for (my $i = 2; $i < @table; $i++) {
        # Print the row with color
        if ($i % 2 == 0) {
            print $table[$i] . "\n";
        } else {
            print $G . $table[$i] . $R . "\n";
        }
    }
} else {  # If table size is less than 4 rows, skip coloring
    foreach my $row (@table) {
        print "$row\n";
    }
}
