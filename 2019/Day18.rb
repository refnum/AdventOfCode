#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		Day18.rb
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





#==============================================================================
#		Constants
#------------------------------------------------------------------------------
theInput = <<MAP
#########
#b.A.@.a#
#########
MAP


#theInput = <<MAP
#########################
##f.D.E.e.C.b.A.@.a.B.c.#
#######################.#
##d.....................#
#########################
#MAP
#
#
#theInput = <<MAP
#########################
##...............b.C.D.f#
##.######################
##.....@.a.B.c.d.A.e.F.g#
#########################
#MAP
#
#
#theInput = <<MAP
##################
##i.G..c...e..H.p#
#########.########
##j.A..b...f..D.o#
#########@########
##k.E..a...g..B.n#
#########.########
##l.F..d...h..C.m#
##################
#MAP
#
#
#theInput = <<MAP
#########################
##@..............ac.GI.b#
####d#e#f################
####A#B#C################
####g#h#i################
#########################
#MAP
#
#
#theInput = <<MAP
##################################################################################
##.................#...#.#...............#...#.........#.......#.......#.....#...#
########.#.#######.#.#.#.#.#######.#######.#.#.###.#####.#####.#.#.###C###.#.#.#.#
##.E...#.#.#.....#...#...#.#.....#.......#.#.#t#.#.....#.#...#...#.#.#.#...#.#.#.#
##.###.###.#.###.#######.#.#.###.#######.#.###.#.#####.#.#.#.#####.#.#.#.###.#.#.#
##.#.......#...#...#...#.#.#.#.......#...#.#.........#...#.#.....#f#.....#...#a#.#
##.#########.#.#####.#.#.#.###.#####.#.###.#.#######.#####.#.###.#.#######.###.###
##...#.....#.#.....#.#...#...#.#.....#...#...#...#.#.....#.#...#.#...#h..#...#...#
##.#.#.###.#####.#.#.#######.#.#.#######.#.###.#.#.#####.###.#.#####.#.#.###.###.#
##.#.#...#.....#.#...#...#...#.#...#...#.#...#.#.#.....#...#.#.#.....#.#...#.L.#.#
####.#.#######.#.#####.#.#.###.###.###.#.#####.#.#.###.###.###.#.#####.###.###.#.#
##...#.#...#...#...#...#.#...#...#.....#.#...#.#.#...#.........#.#.......#...#...#
##.###.#.#.#.#####.#.###.###.#.#.#####.#.#.#.#.#.###.###########.#.#####.###.###.#
##.....#.#...#.....#...#...#.#.#.#.....#.#.#...#.#.....#.....#...#...#.#.#...#...#
##.#####.###.#####.###.###.#.###.#.#####.#.#####.#.#####.###.#.#####.#.#.###.#.###
##...#.#...#.#...#.#...#.#.#.#...#.....#.#.#.....#.#.....#...#...#.#.#.#...#.#...#
####.#.###.###.#.###.###.#.#.#.#.#######.#.#.#######.#####.#####.#.#.#.###.#####.#
##.#.....#.....#.....#...#.#...#.#.......#.#.......#...#.#.#.....#.#.#...#.......#
##.#####.#############.#.#.#.#####.#####.#.#######.###.#.#.###.###.#.#.###########
##.....#.#.#...........#.#...#.....#.....#.#...#...#...#.#.....#...#.#...........#
##.#.###.#.#.#.#####.#########.#####.#####.#.#.#.###.###.#.#####.#.#.###.#########
##.#.#...#...#.....#.#.......#.#.........#...#.#.....#.....#.X.#.#.#...#.#...#...#
####.#.###########.#########.#.#########.#.###.#######.#####.###.#####D#.#.#.#.#.#
##...#.#...........#.......#.#.....#.....#...#...#...#...#.#...#.......#...#...#.#
##.#.#.###.#######.#.#.#.###.#.###.#####.#.#####.###.###.#.###.#######.###.#####.#
##.#.#....k#...#...#.#.#.#...#...#.....#.#.#.....#.....#.#...#.#...V.#...#...#...#
##.#.#########.#.###.#.#.#.#####.#####.###.#.#####.#####.###.#.#.###.###.###.#.###
##.#...#.......#.#...#.#.#...#.......#...#.#.#.....#.....#...#...#...#.#.#.#.#...#
##.###.#.#######.#.###.#####.#.#########.#.#.###.#.#.#####.#######.###.#.#.#.###.#
##...#...#.......#.#.#.....#.#.#.#.......#.#.#...#.#.#.#...#.......#...R.#...#...#
##.#.#####.#######.#.#####.#.#.#.#.#####.###.#.#####.#.#.#.#W#######.#####S###.#.#
##.#......j#...#...#...I.#...#...#.#.....#...#.......#...#.#.#.....#...#.#.#.#.#.#
##.#########.###.###.###.#########.#####.#.#######.#######.#.#.###.###.#.#.#.#.#.#
##.......#.....#.....#.#.#...#.....#...#.#.......#.........#...#.#.#.#.#.#.#.#.#.#
########.###.#.#######U#.#.#.#.#####.#.#########.###.###########.#.#.#.#.#.#.#.###
##...Y.#...#.#.........#...#.#.......#...#.#...#.#...#.............#.#.#.....#...#
##.#######.#.###.#####.#####.#########.#.#.#.#.#.#####.#############.#.#########B#
##...#.Q...#.#...#.#...#...#.#...#...#.#.#...#.#.......#i..#.....#...#.........#.#
##.#.#.#######.###.#.#####.#.#.#.#.#.###.#.###.#########.#.#.#.###.#.#########.#.#
##.#...........#p..........#...#...#.........#...........#...#.....#...N.........#
########################################.@.#######################################
##.#.....#.#.........#.........#.....#.......#...#.......#...#.....#...G.....#...#
##.#.#.#.#.#.#####.#.#######.#.#.###.#.###.#.#.#.#.#####.#.###.###.#.#####.#.#.#.#
##...#r#.#.#.#...#n#.........#...#.#.#...#.#.#.#.#...#...#...#.#.#...#...#.#...#.#
##.###.#.#.#.#.###.###############.#.###.#.#.#.#.#.#.#.#####.#.#.#######.#.#####.#
##.#d#.#.#.....#...#.........#.....#.....#.#..m#.#.#.#.....#.#.#.....#...#...#...#
##.#.#.#.#######.#########.###.#.#######.#.#####.#.#.#####.#.#.###.#.#.#####.#.###
##...#.#.#..b....#.....#...#...#.#.....#.#.#...#.#.#.#.......#.....#...#.....#...#
##.###.#.#.#######.###.#.###.###.#.###.#.#.#.#.#.#.#.#################.#.#######.#
##.#...#...#.......#...#.#...#.#...#.#...#.#.#.#.#.#.#.....#.......#...#...#.K.#.#
####.#######.###.###.###.#.###.#####.#####.#.#.#.#.#.#.###.#.#####.#.#####.#.#.#.#
##...#.......#.#...#.....#...#.......#...#.#.#...#.#.#.#.#...#...#.....#...#.#.#.#
##.#####.#####.###.#####.###.###.#.#.###.#.###.#####.#.#.#####.#########.###.###.#
##.#...#..z#.....#...#.#.#.#...#.#.#.....#...#.#.....#.....#...#.........#.....#.#
##.#.#.###.###.#.###.#.#.#.###.###.#####.###.#.#.#.#######.###.#.#########.###.#.#
##.#.#..s#.....#.#...#.......#...#.#.#...#...#...#.#.....#.....#...#.#.....#.#.#.#
##.#.###.#######.#.#############.#.#.#.###.#########.#.#######.###.#.#.#####.#.#.#
##.....#.#.....#.#.............#...#...#.#.M...#.....#...#...#.#...#...#.....#...#
########.#.###.#######.#####.#.#####.###.#####.#.#######.#.#.#.#.#####.###.#.#####
##...#...#.#.#.......#.....#.#...#...#...#.....#.#.....#.#.#...#.....#.....#...#.#
##O###.###.#.#######.###.###.#####.#####.#.#####.#.###.#.#.#####.###.#########.#.#
##...#.....#.....#...#.#.#...#.....#.....#.....#...#.#.#.#...#.#...#......o#...#.#
####.#########.#.#.#.#.#.#.#.#.#######.#.#####.#####.#.#.###.#.###.#######.#.###J#
##...#.........#.#.#.#.#.#.#.#.#.......#.#.......#.....#.#...#..x#.#.....#.#.....#
##.#.#.#########.#.###.#.#.###.###.#.#####.#####.#.#####.#.#####.#.#.#####.#.#####
##.#...#....g#.#.#.....#.#...#...#.#.....#.....#.#.#...#.....#...#...#.....#.#...#
##.###.#.###.#.#.###########.###.#######.#.###.###.#.#######.#.#####.#.###.###.#.#
##.#.#.#...#.#.................#.#...#...#.#.#.....#.#....v#.#.#.....#.#.#.#...#.#
##.#.#.###.#.###########.#####.#.#.#.#.#.#.#.#######.#.###.###.#.#####.#.#.#.###.#
##.#.#...#.#...F...#.....#...#.#.#.#...#.#.#.....#...#...#.....#.....#.#...#q#.#.#
##.#.###.#.#######.#.#####.#.###.#.#######.###.#.#.#.###.###########.#.#####.#.#.#
##.#...#.#.#...#...#.#...#.#.....#.......#.....#...#.#.#w#.........#.#.....#.#.#.#
##.#.#.#.#.#.#.#.#.###.#.#.#########.###.###########.#.#.#.#.#####.#######.#.#.#.#
##.#.#...#.#.#...#.#...#.#...#.....#...#.#...#.......#.#.#.#.#...#.P.#...#.#...#y#
##.#######.#.#.#####.###.###.#.###.#####.#.###.#######.#.###.#.#.###.#.#.#.#.###.#
##.#.....#.#c#.#...#.#l..#...#...#.#.A.#.#.....#.......#...Z.#.#...#.#.#.#...#...#
##.#.###T#.#.###.#.#.#.###.###.#.#.#.#.#.#.#########.#.###########.#.#.#.#####.###
##.#...#.#.#.....#...#...#.H.#.#.#.#.#...#...#.......#.....#.......#...#.....#..u#
##.###.#.#.#############.###.###.#.#.###.###.###.#########.###.###.#########.###.#
##.....#..........e....#.........#...#...#.......#.............#...........#.....#
##################################################################################
#MAP





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

	def ==(otherPoint)
		return (@x == otherPoint.x && @y == otherPoint.y);
	end

	def eql?(otherPoint)
		return (@x == otherPoint.x && @y == otherPoint.y);
	end
	
	def hash
		return [@x, @y].hash;
	end

end





#==============================================================================
#		Map : Map class.
#------------------------------------------------------------------------------
class Map

	#==========================================================================
	#		Constants
	#--------------------------------------------------------------------------
	# Map
	TILE_EMPTY      = '.';
	TILE_WALL       = '#';
	TILE_ENTRANCE   = '@';
	
	TILE_KEY_FIRST  = 'a';
	TILE_KEY_LAST   = 'z';

	TILE_DOOR_FIRST = 'A';
	TILE_DOOR_LAST  = 'Z';



	#==========================================================================
	#		initialize : Initialiser.
	#--------------------------------------------------------------------------
	def initialize(mapText)

		@map      = Hash.new();
		@keys     = Hash.new();
		@doors    = Hash.new();
		@entrance = Point.new();

		loadMap(mapText);

	end



	#==========================================================================
	#		solveMap : Solve the map.
	#--------------------------------------------------------------------------
	def solveMap
	
#		puts @map;
#		
#		puts @entrance;
#		puts @keys;
#		puts @doors;
	
	

		numSteps = countSteps(@entrance, 'a');
		puts "Was #{numSteps} from @ to a";

		numSteps = countSteps(@keys['a'], @doors['A']);
		puts "Was #{numSteps} from a to A";

		numSteps = countSteps(@doors['A'], @keys['b']);
		puts "Was #{numSteps} from A to b";

	end



private
	#==========================================================================
	#		loadMap : Load the map.
	#--------------------------------------------------------------------------
	def loadMap(mapText)

		x = 0;
		y = 0;

		mapText.lines.each do |theLine|
		
			theLine.chars.each do |theTile|
			
				thePoint = Point.new(x, y);
				setTile(thePoint, theTile);
				
				if (theTile == TILE_ENTRANCE)
					@entrance = thePoint;
				
				elsif (theTile >= TILE_KEY_FIRST && theTile <= TILE_KEY_LAST)
					@keys[theTile] = thePoint;
				
				elsif (theTile >= TILE_DOOR_FIRST && theTile <= TILE_DOOR_LAST)
					@doors[theTile] = thePoint;
				end
				
				x += 1;
			
			end
			
			y += 1;
			x  = 0;
		
		end

	end



	#==========================================================================
	#		findTarget : Find a target.
	#--------------------------------------------------------------------------
	def findTarget(theSteps, thePoint, theTarget, numSteps)
	
		theTile = getTile(thePoint);
		
		if (theTile == TILE_WALL)
			return;
		end
		
		if (theSteps.has_key?(thePoint))
			return;
		end


		# Search from the tile
		if (theTile != '.')
			theSteps[thePoint] = {:tile => theTile, :steps => numSteps};
		end

		if (theTile != theTarget)
			findTarget(theSteps, Point.new(thePoint.x + 1, thePoint.y),     theTarget, numSteps + 1);
			findTarget(theSteps, Point.new(thePoint.x - 1, thePoint.y),     theTarget, numSteps + 1);
			findTarget(theSteps, Point.new(thePoint.x,     thePoint.y + 1), theTarget, numSteps + 1);
			findTarget(theSteps, Point.new(thePoint.x,     thePoint.y - 1), theTarget, numSteps + 1);
		end

	end



	#==========================================================================
	#		countSteps : Count the steps to a target.
	#--------------------------------------------------------------------------
	def countSteps(theStart, theTarget)

		theSteps = Hash.new();
		findTarget(theSteps, @entrance, theTarget, 0);
		
		
		theSteps.each_pair do |thePoint, theInfo|
			puts "#{thePoint} => #{theInfo}";
		end
		exit;
		
		return theSteps.values.min;

	end



	#==========================================================================
	#		getTile : Get the tile at a point.
	#--------------------------------------------------------------------------
	def getTile(thePoint)

		if (@map.has_key?(thePoint))
			theTile = @map[thePoint];
		else
			theTile = TILE_WALL;
		end

		return theTile;

	end



	#==========================================================================
	#		setTile : Set the Tile at a point.
	#--------------------------------------------------------------------------
	def setTile(thePoint, theTile)

		@map[thePoint.dup] = theTile;

	end

end







# Part One
theMap = Map.new(theInput);

theMap.solveMap();




