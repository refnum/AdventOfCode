#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		Day3.rb
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






SPARSE_HASH=true;


def getPoint(x, y)
	return { :x => x, :y => y };
end


def addPoint(thePoint, theVector)
	return getPoint(thePoint[:x] + theVector[:x],
					thePoint[:y] + theVector[:y]);
end


def getDistance(point1, point2)

	theDistance = 0;
	
	if (point1[:x] < point2[:x])
		theDistance += point2[:x] - point1[:x];
	else
		theDistance += point1[:x] - point2[:x];
	end

	if (point1[:y] < point2[:y])
		theDistance += point2[:y] - point1[:y];
	else
		theDistance += point1[:y] - point2[:y];
	end
	
	return theDistance;

end


def getVector(theDirection)

	case theDirection
	when 'U'
		return getPoint(0, 1);
	
	when 'D'
		return getPoint(0, -1);
	
	when 'L'
		return getPoint(-1, 0);
	
	when 'R'
		return getPoint(1, 0);
	
	else
		abort("Unknown direction '#{theDirection}'");
	end
	
end



def pointToLocation(thePoint)
	return "#{thePoint[:x]}:#{thePoint[:y]}";
end


def locationToPoint(theLocation)

	theCoords = theLocation.split(":");
	if (theCoords.size != 2)
		abort("Unknown location '#{theLocation}'");
	end
	
	return getPoint(theCoords[0].to_i, theCoords[1].to_i);

end


def getMarks(theBoard, x, y)

	if (SPARSE_HASH)
		theMarks = [];

		if (theBoard.has_key?(y))
			if (theBoard[y].has_key?(x))
				theMarks = theBoard[y][x];
			end
		end


	else
		theLocation = pointToLocation(makePoint(x, y));
		theMarks    = theBoard.fetch(theLocation, []);

	end	
	
	return theMarks;

end


def addMark(theBoard, theCursor, theColour)

	if (SPARSE_HASH)
		x = theCursor[:point][:x];
		y = theCursor[:point][:y];
	
		if (!theBoard.has_key?(y))
			theBoard[y] = Hash.new();
		end
	
		if (!theBoard[y].has_key?(x))
			theBoard[y][x] = Hash.new();
		end

		if (!theBoard[y][x].has_key?(theColour))
			theBoard[y][x][theColour] = theCursor[:steps];
		end
		

	else
		theLocation = pointToLocation(theCursor[:point]);
		
		if (!theBoard.has_key?(theLocation))
			theBoard[theLocation] = Hash.new();
		end
		
		if (!theBoard[theLocation].has_key?(theColour))
			theBoard[theLocation][theColour] = theCursor[:steps];
		end
		
	end

end


def getTiming(theBoard, thePoint)

	theMarks  = getMarks(theBoard, thePoint[:x], thePoint[:y]);
	
	if (theMarks.size != 2)
		abort("Not an intersection!");
	end
	
	return theMarks.values.inject(:+);
	
end


def addSegment(theBoard, theCursor, theSegment, theColour)
	
	if (theSegment =~ /(.)(\d+)/)
	
		theVector = getVector($1);
		theLength = $2.to_i;

		theLength.times do
		
			theCursor[:point] = addPoint(theCursor[:point], theVector);
			theCursor[:steps] += 1;
			
			addMark(theBoard, theCursor, theColour);
		end
	
	else
		abort("Unable to parse '#{theSegment}'");
	end

end


def addWire(theBoard, theWire, theColour)

	theCursor = { :point => getPoint(0, 0), :steps => 0 };

	theWire.split(",").each do |theSegment|
		addSegment(theBoard, theCursor, theSegment, theColour)
	end

end


def getBounds(theBoard)

	theRect = {}

	if (SPARSE_HASH)
		pointsX = [];
		pointsY = [];
	
		theBoard.each_pair do |theRow, theColumns|
			pointsY << theRow
			pointsX.concat(theColumns.keys);
		end
	
		pointsX.sort!;
		pointsY.sort!;
	
		theRect[:minX] = pointsX.min;
		theRect[:maxX] = pointsX.max;
		theRect[:minY] = pointsY.min;
		theRect[:maxY] = pointsY.max;


	else
		theRect[:minX] = 0;
		theRect[:maxX] = 0;
		theRect[:minY] = 0;
		theRect[:maxY] = 0;
	
		theBoard.keys.each do |theLocation|
	
			thePoint = locationToPoint(theLocation);
	
			theRect[:minX] = (thePoint[:x] < theRect[:minX]) ? thePoint[:x] : theRect[:minX];
			theRect[:maxX] = (thePoint[:x] > theRect[:maxX]) ? thePoint[:x] : theRect[:maxX];

			theRect[:minY] = (thePoint[:y] < theRect[:minY]) ? thePoint[:y] : theRect[:minY];
			theRect[:maxY] = (thePoint[:y] > theRect[:maxY]) ? thePoint[:y] : theRect[:maxY];
	
		end
	end

	return theRect;

end


def processBoard(theBoard)

	# Get the state we need
	theBounds    = getBounds(theBoard)
	theCrossings = [];

	minX = theBounds[:minX] - 1;
	maxX = theBounds[:maxX] + 1;
	minY = theBounds[:minY] - 1;
	maxY = theBounds[:maxY] + 1;

	showBoard = (maxX - minX) < 1000;



	# Process the board	
	if showBoard
	
		maxY.downto(minY) do |y|
			theLine = "";
	
			minX.upto(maxX) do |x|
		
				theToken = '.';

				if (x == 0 && y == 0)
					theToken = 'O';
			
				else
					theMarks = getMarks(theBoard, x, y);
					
					if (theMarks.empty?)
						theToken = ".";
					
					else
						theColours = theMarks.keys;
						if (theColours.size == 1)
							theToken = theColours.include?(:red) ? "r" : "b";

						elsif (theColours.size == 2)
							theToken = "X";
							theCrossings << getPoint(x, y);

						else
							abort("Unexpected marks '#{theMarks}' at (#{x}, #{y})");
						end
					end
				end

				theLine += theToken;
			end
		
			puts theLine;
		end

		puts "";

	else
	
		puts "Processing board...";

		theBoard.each_pair do |y, theRows|
			theRows.each_key do |x|
			
				theMarks = getMarks(theBoard, x, y);
				
				if (theMarks.keys.size == 2)
					theCrossings << getPoint(x, y);
				end

			end
		end

	end



	# Calculate the intersections
	bestDistance = 0;
	bestPoint    = getPoint(0, 0);
	theOrigin    = getPoint(0, 0);

	theCrossings.each do |thePoint|
	
		theDistance = getDistance(theOrigin, thePoint);

		puts "Intersection #{thePoint} is at distance #{theDistance}";

		if (bestDistance == 0 || theDistance < bestDistance)
			bestDistance = theDistance;
			bestPoint    = thePoint;
		end
	
	end
	
	puts "Closest intersection is #{bestPoint}, at distance #{bestDistance}";
	puts "";



	# Calculate the timings
	bestTime  = 0;
	bestPoint = getPoint(0, 0);
	
	theCrossings.each do |thePoint|
	
		theTime = getTiming(theBoard, thePoint);
		
		puts "Intersection #{thePoint} takes time #{theTime}";

		if (bestTime == 0 || theTime < bestTime)
			bestTime  = theTime;
			bestPoint = thePoint;
		end
	
	end

	puts "Quickest intersection is #{bestPoint}, at time #{bestTime}";
	puts "";


end




redWire  = "R8,U5,L5,D3";
blueWire = "U7,R6,D4,L4";

redWire  = "R75,D30,R83,U83,L12,D49,R71,U7,L72";
blueWire = "U62,R66,U55,R34,D71,R55,D58,R83";

redWire  = "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51";
blueWire = "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7";

redWire  = "R1003,U741,L919,U341,L204,U723,L113,D340,L810,D238,R750,U409,L104,U65,R119,U58,R94,D738,L543,U702,R612,D998,L580,U887,R664,D988,R232,D575,R462,U130,L386,U386,L217,U155,L68,U798,R792,U149,L573,D448,R76,U896,L745,D640,L783,D19,R567,D271,R618,U677,L449,D651,L843,D117,L636,U329,R484,U853,L523,U815,L765,U834,L500,U321,R874,U90,R473,U31,R846,U549,L70,U848,R677,D557,L702,U90,R78,U234,R282,D289,L952,D514,R308,U255,R752,D338,L134,D335,L207,U167,R746,U328,L65,D579,R894,U716,R510,D932,L396,U766,L981,D115,L668,U197,R773,U898,L22,U294,L548,D634,L31,U626,R596,U442,L103,U448,R826,U511,R732,U680,L279,D693,R292,U641,R253,U977,R699,U861,R534,D482,L481,U929,L244,U863,L951,D744,R775,U198,L658,U700,L740,U725,R286,D105,L629,D117,L991,D778,L627,D389,R942,D17,L791,D515,R231,U418,L497,D421,L508,U91,R841,D823,L88,U265,L223,D393,L399,D390,L431,D553,R40,U724,L566,U121,L436,U797,L42,U13,R19,D858,R912,D571,L207,D5,L981,D996,R814,D918,L16,U872,L5,U281,R706,U596,R827,D19,R976,D664,L930,U56,R168,D892,R661,D751,R219,U343,R120,U21,L659,U976,R498,U282,R1,U721,R475,D798,L5,U396,R268,D454,R118,U260,L709,D369,R96,D232,L320,D763,R548,U670,R102,D253,L947,U845,R888,D645,L734,D734,L459,D638,L82,U933,L485,U235,R181,D51,L45,D979,L74,D186,L513,U974,R283,D493,R128,U909,L96,D861,L291,U640,R793,D712,R421,D315,L152,U220,L252,U642,R126,D417,R137,D73,R1,D711,R880,U718,R104,U444,L36,D974,L360,U12,L890,D337,R184,D745,R164,D931,R915,D999,R452,U221,L399,D761,L987,U562,R25,D642,R411,D605,R964";
blueWire = "L1010,U302,L697,D105,R618,U591,R185,U931,R595,D881,L50,D744,L320,D342,L221,D201,L862,D959,R553,D135,L238,U719,L418,U798,R861,U80,L571,U774,L896,U772,L960,U368,R415,D560,R276,U33,L532,U957,R621,D137,R373,U53,L842,U118,L299,U203,L352,D531,R118,U816,R355,U678,L983,D175,R652,U230,R190,D402,R111,D842,R756,D961,L82,U206,L576,U910,R622,D494,R630,D893,L200,U943,L696,D573,L143,D640,L885,D184,L52,D96,L580,U204,L793,D806,R477,D651,L348,D318,L924,D700,R675,D689,L723,D418,L156,D215,L943,D397,L301,U350,R922,D721,R14,U399,L774,U326,L14,D465,L65,U697,R564,D4,L40,D250,R914,U901,R316,U366,R877,D222,L672,D329,L560,U882,R321,D169,R161,U891,L552,U86,L194,D274,L567,D669,L682,U60,L985,U401,R587,U569,L1,D325,L73,U814,L338,U618,L49,U67,L258,D596,R493,D249,L310,D603,R810,D735,L829,D378,R65,U85,L765,D854,L863,U989,L595,U564,L373,U76,R923,U760,L965,U458,L610,U461,R900,U151,L650,D437,L1,U464,L65,D349,R256,D376,L686,U183,L403,D354,R867,U993,R819,D333,L249,U466,L39,D878,R855,U166,L254,D532,L909,U48,L980,U652,R393,D291,L502,U230,L738,U681,L393,U935,L333,D139,L499,D813,R302,D415,L693,D404,L308,D603,R968,U753,L510,D356,L356,U620,R386,D205,R587,U212,R715,U360,L603,U792,R58,U619,R73,D958,L53,D666,L756,U71,L621,D576,L174,U779,L382,U977,R890,D830,R822,U312,R716,U767,R36,U340,R322,D175,L417,U710,L313,D526,L573,D90,L493,D257,L918,U425,R93,D552,L691,U792,R189,U43,L633,U934,L953,U817,L404,D904,L384,D15,L670,D889,L648,U751,L928,D744,L932,U761,R879,D229,R491,U902,R134,D219,L634,U423,L241";



theBoard = Hash.new();

addWire(theBoard, redWire,  :red);
addWire(theBoard, blueWire, :blue);

processBoard(theBoard)

