#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		Day10.rb
#
#	DESCRIPTION:
#		Advent of Code 2019.
#
#	COPYRIGHT:
#		Copyright (c) 2019, refNum Software
#		All rights reserved.
#
#		Redistribution and use in source and binary forms, with or without
#		modification, are permitted provided that the following conditions
#		are met:
#		
#		1. Redistributions of source code must retain the above copyright
#		notice, this list of conditions and the following disclaimer.
#		
#		2. Redistributions in binary form must reproduce the above copyright
#		notice, this list of conditions and the following disclaimer in the
#		documentation and/or other materials provided with the distribution.
#		
#		3. Neither the name of the copyright holder nor the names of its
#		contributors may be used to endorse or promote products derived from
#		this software without specific prior written permission.
#		
#		THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#		"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#		LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#		A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#		HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#		SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#		LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#		DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#		THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#		(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#		OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#==============================================================================
#		Imports
#------------------------------------------------------------------------------
require "matrix"





#==============================================================================
#		Inputs
#------------------------------------------------------------------------------
# Part One
#mapText = <<MAP
#.#..#
#.....
######
#....#
#...##
#MAP
 
#mapText = <<MAP
#......#.#.
##..#.#....
#..#######.
#.#.#.###..
#.#..#.....
#..#....#.#
##..#....#.
#.##.#..###
###...#..#.
#.#....####
#MAP
#
#mapText = <<MAP
##.#...#.#.
#.###....#.
#.#....#...
###.#.#.#.#
#....#.#.#.
#.##..###.#
#..#...##..
#..##....##
#......#...
#.####.###.
#MAP
#
#mapText = <<MAP
#.#..#..###
#####.###.#
#....###.#.
#..###.##.#
###.##.#.#.
#....###..#
#..#.#..#.#
##..#.#.###
#.##...##.#
#.....#.#..
#MAP
#
#mapText = <<MAP
#.#..##.###...#######
###.############..##.
#.#.######.########.#
#.###.#######.####.#.
######.##.#.##.###.##
#..#####..#.#########
#####################
##.####....###.#.#.##
###.#################
######.##.###..####..
#..######..##.#######
#####.##.####...##..#
#.#####..#.######.###
###...#.##########...
##.##########.#######
#.####.#.###.###.#.##
#....##.##.###..#####
#.#.#.###########.###
##.#.#.#####.####.###
####.##.####.##.#..##
#MAP



# Part Two
#mapText = <<MAP
#.#....#####...#..
###...##.#####..##
###...#...#.#####.
#..#.....X...###..
#..#.#.....#....##
#MAP



## Puzzle input
mapText = <<MAP
...###.#########.####
.######.###.###.##...
####.########.#####.#
########.####.##.###.
####..#.####.#.#.##..
#.################.##
..######.##.##.#####.
#.####.#####.###.#.##
#####.#########.#####
#####.##..##..#.#####
##.######....########
.#######.#.#########.
.#.##.#.#.#.##.###.##
######...####.#.#.###
###############.#.###
#.#####.##..###.##.#.
##..##..###.#.#######
#..#..########.#.##..
#.#.######.##.##...##
.#.##.#####.#..#####.
#.#.##########..#.##.
MAP





#==============================================================================
#		PolarPoint : Polar coordinate point class.
#------------------------------------------------------------------------------
class PolarPoint
	attr_accessor :magnitude, :bearing

	def initialize
		@magnitude = 0;
		@bearing   = 0;
	end
	
	def to_s
		return "(#{@magnitude}, #{@bearing})";
	end

end





#==============================================================================
#		Point : Point class.
#------------------------------------------------------------------------------
class Point
	attr_accessor :x, :y

	def initialize(x=0, y=0)
		@x = x;
		@y = y;
	end
	
	def to_s
		return "(#{@x}, #{@y})";
	end
 	
	def getBearing(otherPoint)

		# Y axis is flipped
		deltaX =   otherPoint.x - @x;
		deltaY = -(otherPoint.y - @y);


		# Convert to polar coordinates
		polarPoint           = PolarPoint.new;
		polarPoint.magnitude = Math.hypot(deltaY, deltaX);
		polarPoint.bearing     = Math.atan2(deltaY, deltaX);


		# To Degrees
		polarPoint.bearing *= 180.0 / Math::PI;


		# To 0..360
		if (polarPoint.bearing < 0.0)
			polarPoint.bearing = 360.0 - -polarPoint.bearing;
		end		


		# Rotate origin to Y axis
		polarPoint.bearing -= 90.0

		if (polarPoint.bearing < 0.0)
			polarPoint.bearing = 360.0 + polarPoint.bearing;
		end


		# Flip CCW to CW
		polarPoint.bearing = 360.0 - polarPoint.bearing;
		
		if (polarPoint.bearing == 360.0)
			polarPoint.bearing = 0.0;
		end

		return polarPoint;

	end
	
end





#==============================================================================
#		decodeMap : Decode the map.
#------------------------------------------------------------------------------
def decodeMap(mapText)

	# Get the state we need
	theMap          = Hash.new();
	theMap[:points] = Array.new();
	theMap[:text]   = Array.new();



	# Decode the map
	mapText.lines.each_with_index do |theLine, y|
		
		
		# Build the line
		theChars = theLine.chomp.split(//);
		theMap[:text] << theChars;

		theChars.each_with_index do |theChar, x|


			# Save the asteroids / base		
			if (theChar == '#' || theChar == 'X')
				
				thePoint = Point.new(x, y);
				theMap[:points] << thePoint;
				
				if (theChar == 'X')
					theMap[:base] = thePoint;
				end

			end

		end
	
	end

	return theMap;

end





#==============================================================================
#		printMap : Print the map.
#------------------------------------------------------------------------------
def printMap(theMap)

	theMap[:text].each do |theLine|
		puts theLine.join;
	end
	
	puts "";

end





#==============================================================================
#		printTargets : Print the targets.
#------------------------------------------------------------------------------
def printTargets(targetTable)

	targetTable.each_pair do |theBearing, theTargets|
	
		puts "Bearing: #{theBearing}";
		puts "Targets:"
		
		theTargets.each do |theTarget|
			puts "  Range: #{theTarget[:range]}, Point: #{theTarget[:point]}";
		end
		puts "";

	end

end





#==============================================================================
#		countVisible : Count the number of visible asteroids.
#------------------------------------------------------------------------------
def countVisible(theMap, fromPoint)

	distanceTo = Hash.new();
	
	theMap[:points].each do |thePoint|
	
		if (thePoint != fromPoint)

			# Get the state we need
			polarPoint  = fromPoint.getBearing(thePoint);
			theDistance = polarPoint.magnitude;
			theKey      = polarPoint.bearing.round(10);


			# Save the best
			bestDistance = distanceTo.fetch(theKey, theDistance + 1.0);
			if (theDistance < bestDistance)
				distanceTo[theKey] = theDistance;
			end
		
		end

	end
	
	return distanceTo.size;

end





#==============================================================================
#		findBest : Find the best asteroid.
#------------------------------------------------------------------------------
def findBest(theMap)

	# Find the best asteroid
	bestVisible = 0;
	bestPoint   = Point.new();
	
	theMap[:points].each do |thePoint|
	
		numVisible = countVisible(theMap, thePoint);

		if (numVisible > bestVisible)
			bestVisible = numVisible;
			bestPoint   = thePoint;
		end

	end



	# Save the base
	puts "The best point is #{bestPoint}, which can see #{bestVisible} asteroids";

	theMap[:base] = bestPoint;
	theMap[:text][bestPoint.y][bestPoint.x] = 'X';
	
end





#==============================================================================
#		fireLaser : Fire the laser.
#------------------------------------------------------------------------------
def fireLaser(theMap)

	# Find the targets
	targetTable = Hash.new();

	theMap[:points].each do |thePoint|

		if (thePoint != theMap[:base])
		
			polarPoint = theMap[:base].getBearing(thePoint);
			theKey     = polarPoint.bearing.round(10);

			theTarget = {	:point   => thePoint,
							:bearing => polarPoint.bearing,
							:range   => polarPoint.magnitude };

			if (!targetTable.has_key?(theKey))
				targetTable[theKey] = [theTarget];
			else
				targetTable[theKey] << theTarget;
			end
		
		end

	end



	# Prepare the target list
	#
	# Sort by bearing, then by distance.
	targetList = targetTable.sort.to_h;

	targetList.each_pair do |theKey, theTargets|
		targetList[theKey] = theTargets.sort_by { |theTarget| theTarget[:range] };
	end

#	printMap(theMap);
#	printTargets(targetList);



	# Fire the laser
	hitList = Array.new();
	gotHit	= true;
	n       = 1;

	while gotHit do
		gotHit = false;
		
		targetList.each_pair do |theBearing, theTargets|

			if (!theTargets.empty?)
				gotHit    = true;
				theTarget = theTargets.shift;
				hitList   << theTarget;
				
				y = theTarget[:point].y;
				x = theTarget[:point].x;
				
				theMap[:text][y][x] = n;
				n += 1;

#				printMap(theMap);
			end

		end
	end



	# Report the hits
	hitList.each_with_index do |theTarget, theIndex|
	
		theIndex = theIndex + 1;
		puts "Target #{theIndex} is at #{theTarget[:point]}";
		
		if (theIndex == 200)
			puts "  => answer is #{(theTarget[:point].x * 100) + theTarget[:point].y}";
		end
	
	end

end








theMap = decodeMap(mapText);

findBest( theMap);
fireLaser(theMap);






