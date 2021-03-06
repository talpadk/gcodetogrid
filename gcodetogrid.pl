#!/usr/bin/perl

use strict;
use Getopt::Long;

my $nX = undef;
my $nY = undef;
my $gridX = undef;
my $gridY = undef;
my $help = 0;
my $leftBottomCorner = 0;
my $safeHeight = undef;
my $feedRate = undef;
my $gcode;

my %argumentHash = (
    "nx=i"               => \$nX,
    "ny=i"               => \$nY,
    "gridx=i"            => \$gridX,
    "gridy=i"            => \$gridY,
    "zsafe|z=i"          => \$safeHeight,
    "help|h"             => \$help,
    "feed|f=i"               => \$feedRate,
    "left-bottom-corner" => \$leftBottomCorner
);

sub printHelp{
    print STDERR "gcodetogrid.pl help message.\n";
    print STDERR "This script reads a g-code file from stdin and outputs it as a grid on stdout\n";
    print STDERR "\n";
    print STDERR "Options:\n";
    print STDERR "--feed, -f\t\tthe feed rate to use for the in between grid point moves generated by this script\n";
    print STDERR "--gridx\t\t\tthe number of grid points in the x direction, defaults to the value of --gridy if not given.\n";
    print STDERR "--gridy\t\t\tthe number of grid points in the y direction, defaults to the value of --gridx if not given.\n";
    print STDERR "--help, -h\t\tprints this help message.\n";
    print STDERR "--left-bottom-corner\tspecifies that the start position (0,0) is to be the lower left corner in the grid, if not specified (0,0) will be at the center of the grid.\n";
    print STDERR "--nx\t\t\tthe distance between grid points in the x direction, defaults to the value of --ny if not given.\n";
    print STDERR "--ny\t\t\tthe distance between grid points in the y direction, defaults to the value of --nx if not given.\n";
    print STDERR "--zsafe, -z\t\tthe safe height that the tool should be moved to prior to moving to a new grid point.\n";
    print STDERR "\n";
    print STDERR "Example usage: ./gcodetogrid.pl --nx=50 --gridx=3 --feed=100 -z=4 <my_code.g >grid_version.g\n\n";
}


#Option validation
if ((!GetOptions(%argumentHash)) or $help){
    printHelp();
    exit(1);
}

if ((!defined($nX)) and (!defined($nY))){
    printHelp();
    die("You must specify at least one of nx or ny\n");
}
if (!defined($nX)){
    $nX = $nY;
}
if (!defined($nY)){
    $nY = $nX;
}

if ((!defined($gridX)) and (!defined($gridY))){
    printHelp();
    die("You must specify at least one of gridx or gridy\n");
}
if (!defined($gridX)){
    $gridX = $gridY;
}
if (!defined($gridY)){
    $gridY = $gridX;
}

if (!defined($safeHeight)){
    printHelp();
    die("You must specify the safe height\n");
}

sub offsetGCode{
    my $dX=$_[0];
    my $dY=$_[1];

    print "G1 Z$safeHeight";
    if (defined($feedRate)){
	print " F$feedRate";
    }
    print "\n";

    print "G1 X$dX Y$dY";
    if (defined($feedRate)){
	print " F$feedRate";
    }
    print "\n";

    print "G92 X0 Y0 Z$safeHeight\n";

    print $gcode;    
}

#Generate gcode
$/ = undef;
$gcode = <STDIN>;

if (!$leftBottomCorner){
    offsetGCode(-(($nX/2.0-0.5)*$gridX), -(($nY/2.0-0.5)*$gridY));
}
else {
    print $gcode;
}

my $skipNext=1;
my $direction = $gridX;
for (my $y=0; $y<$nY; $y++){
    for (my $x=0; $x<$nX; $x++){
	if (!$skipNext){
	    offsetGCode($direction, 0);
	}
	$skipNext = 0;	    
    }
    if ($y<$nY-1){
	$direction = -$direction;
	$skipNext = 1;
	offsetGCode(0, $gridY);
    }
}
