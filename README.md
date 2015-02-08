## A simple perl script for copying a g-code program to a grid

![Just a sample screen shot](https://github.com/talpadk/gcodetogrid/blob/master/image_for_readme.png)

A simple perl script that reads a g-code file on stdin and outputs multiple copies distributed on a grid.

The the grid size, number of elements, safe move height and more can be customized using options to the script.

<pre>
This script reads a g-code file from stdin and outputs it as a grid on stdout

Options:
--feed, -f		the feed rate to use for the in between grid point moves generated by this script
--gridx			the number of grid points in the x direction, defaults to the value of --gridy if not given.
--gridy			the number of grid points in the y direction, defaults to the value of --gridx if not given.
--help, -h		prints this help message.
--left-bottom-corner	specifies that the start position (0,0) is to be the lower left corner in the grid, if not specified (0,0) will be at the center of the grid.
--nx			the distance between grid points in the x direction, defaults to the value of --ny if not given.
--ny			the distance between grid points in the y direction, defaults to the value of --nx if not given.
--zsafe, -z		the safe height that the tool should be moved to prior to moving to a new grid point.

Example usage: ./gcodetogrid.pl --nx=50 --gridx=3 --feed=100 -z=4 &lt;my_code.g &gt;grid_version.g
</pre>