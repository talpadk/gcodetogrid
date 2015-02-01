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
    "feed=i"               => \$feedRate,
    "left-bottom-corner" => \$leftBottomCorner
);

sub printHelp{
    print "help\n";
}


#Option validation
if ((!GetOptions(%argumentHash)) or $help){
    printHelp();
    die();
}

if ((!defined($nX)) and (!defined($nY))){
    printHelp();
    die("You must specify atleast one of nx or ny\n");
}
if (!defined($nX)){
    $nX = $nY;
}
if (!defined($nY)){
    $nY = $nX;
}

if ((!defined($gridX)) and (!defined($gridY))){
    printHelp();
    die("You must specify atleast one of gridx or gridy\n");
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
