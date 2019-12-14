#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		Day12.rb
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
require 'prime'





#==============================================================================
#		Inputs
#------------------------------------------------------------------------------
#theInput = <<INPUT
#<x=-1, y=0, z=2>
#<x=2, y=-10, z=-7>
#<x=4, y=-8, z=8>
#<x=3, y=5, z=-1>
#INPUT
#
#theInput = <<INPUT
#<x=-8, y=-10, z=0>
#<x=5, y=5, z=10>
#<x=2, y=-7, z=3>
#<x=9, y=-8, z=-3>
#INPUT
##
# Puzzle input
theInput = <<INPUT
<x=-7, y=-1, z=6>
<x=6, y=-9, z=-9>
<x=-12, y=2, z=-7>
<x=4, y=-17, z=-12>
INPUT






#==============================================================================
#		rightJust : Right-justify a value.
#------------------------------------------------------------------------------
def rightJust(theValue)

	return theValue.to_s.rjust(3);
end





#==============================================================================
#		Point : Point class.
#------------------------------------------------------------------------------
class Point
	attr_accessor :x, :y, :z

	def initialize(x=0, y=0, z=0)
		@x = x;
		@y = y;
		@z = z;
	end
	
	def to_s
		return "<#{rightJust(@x)}, #{rightJust(@y)}, #{rightJust(@z)}>";
	end
	
	def eql?(otherPoint)
		return (@x == otherPoint.x &&
				@y == otherPoint.y &&
				@z == otherPoint.z);
	end
	
	def hash
		return [@x, @y, @z].hash;
	end

	def set(x, y, z)
		@x = x;
		@y = y;
		@z = z;
	end

	def add(otherPoint)
		@x += otherPoint.x;
		@y += otherPoint.y;
		@z += otherPoint.z;
	end
	
end





#==============================================================================
#		attractMoons : Attract two moons.
#------------------------------------------------------------------------------
def attractMoons(thisMoon, thatMoon)

	if (thisMoon[:pos].x < thatMoon[:pos].x)
		thisMoon[:vel].x += 1;
		thatMoon[:vel].x -= 1;

	elsif (thisMoon[:pos].x > thatMoon[:pos].x)
		thisMoon[:vel].x -= 1;
		thatMoon[:vel].x += 1;
	end

	if (thisMoon[:pos].y < thatMoon[:pos].y)
		thisMoon[:vel].y += 1;
		thatMoon[:vel].y -= 1;

	elsif (thisMoon[:pos].y > thatMoon[:pos].y)
		thisMoon[:vel].y -= 1;
		thatMoon[:vel].y += 1;
	end

	if (thisMoon[:pos].z < thatMoon[:pos].z)
		thisMoon[:vel].z += 1;
		thatMoon[:vel].z -= 1;

	elsif (thisMoon[:pos].z > thatMoon[:pos].z)
		thisMoon[:vel].z -= 1;
		thatMoon[:vel].z += 1;
	end

end





#==============================================================================
#		applyGravity : Apply gravity.
#------------------------------------------------------------------------------
def applyGravity(theSystem)

	lastIndex  = theSystem.size - 1;

	0.upto(lastIndex) do |startIndex|
		(startIndex+1).upto(lastIndex) do |otherIndex|
		
			attractMoons(theSystem[startIndex], theSystem[otherIndex]);

		end	
	end

end





#==============================================================================
#		applyVelocity : Apply velocity.
#------------------------------------------------------------------------------
def applyVelocity(theSystem)

	theSystem.each do |theMoon|
		theMoon[:pos].add(theMoon[:vel]);
	end		

end





#==============================================================================
#		getSystemState : Get the system state.
#------------------------------------------------------------------------------
def getSystemState(theSystem)

	stateX = Array.new();
	stateY = Array.new();
	stateZ = Array.new();
	
	theSystem.each do |theMoon|

		stateX <<= theMoon[:pos].x;
		stateX <<= theMoon[:vel].x;

		stateY <<= theMoon[:pos].y;
		stateY <<= theMoon[:vel].y;

		stateZ <<= theMoon[:pos].z;
		stateZ <<= theMoon[:vel].z;
	
	end
	
	return { :x => stateX.hash, :y => stateY.hash, :z => stateZ.hash };

end





#==============================================================================
#		putSystem : Print the system.
#------------------------------------------------------------------------------
def putSystem(theSystem, theStep)

	if false then
		puts "After #{theStep} steps:"

		theSystem.each do |theMoon|
			puts "pos=#{theMoon[:pos]}, vel=#{theMoon[:vel]}";
		end

		puts theSystem.hash;	
		puts "";
	end

end





#==============================================================================
#		putEnergy : Print the system energy.
#------------------------------------------------------------------------------
def putEnergy(theSystem, theStep)

	puts "Energy after #{theStep} steps:"

	totalEnergy = [];

	theSystem.each do |theMoon|
	
		posX = theMoon[:pos].x.abs;
		posY = theMoon[:pos].y.abs;
		posZ = theMoon[:pos].z.abs;

		velX = theMoon[:vel].x.abs;
		velY = theMoon[:vel].y.abs;
		velZ = theMoon[:vel].z.abs;
		
		potEnergy = posX + posY + posZ;
		kinEnergy = velX + velY + velZ;
		totEnergy = potEnergy * kinEnergy;

		print "pot: #{rightJust(posX)} + #{rightJust(posY)} + #{rightJust(posZ)} = #{rightJust(potEnergy)};    ";
		print "kin: #{rightJust(velX)} + #{rightJust(velY)} + #{rightJust(velZ)} = #{rightJust(kinEnergy)};    ";
		puts  "tot: #{rightJust(potEnergy)} * #{rightJust(kinEnergy)} = #{rightJust(totEnergy)}";
		
		totalEnergy << totEnergy;
	end

	sumEnergy = totalEnergy.inject(0, :+);
	
	print "Sum of total energy: "
	print totalEnergy.join(" + ");
	puts " = #{rightJust(sumEnergy)}";
	puts "";

end





#==============================================================================
#		putLoop : Print a loop.
#------------------------------------------------------------------------------
def putLoop(numSteps, theLoop, theDimension);

	puts "#{theDimension} has repeated after #{numSteps} steps, loop is #{theLoop}";
	if ((numSteps % theLoop) != 0)
		puts "  => MISMSATCH!";
	end

end





#==============================================================================
#		stepSystem : Step the system.
#------------------------------------------------------------------------------
def stepSystem(theSystem, numSteps)

	putSystem(theSystem, 0);

	1.upto(numSteps) do |n|
		applyGravity( theSystem);
		applyVelocity(theSystem);
		
		putSystem(theSystem, n);
	end
	
	putEnergy(theSystem, numSteps);

end





#==============================================================================
#		loopSystem  : Loop the system.
#------------------------------------------------------------------------------
def loopSystem(theSystem)

	initialState = getSystemState(theSystem);
	numSteps     = 0;

	loop do
		applyGravity( theSystem);
		applyVelocity(theSystem);

		currentState = getSystemState(theSystem);
		numSteps    += 1;

		if (currentState[:x] == initialState[:x] &&
			currentState[:y] == initialState[:y] &&
			currentState[:z] == initialState[:z])
		
			puts "System loops after #{numSteps} steps (brute-force)";
			break;
		end
	end

end





#==============================================================================
#		findDimensionLoop : Find the loop in each dimension.
#------------------------------------------------------------------------------
def findDimensionLoop(theSystem)

	initialState = getSystemState(theSystem);
	numSteps     = 0;
	
	loopX = 0;
	loopY = 0;
	loopZ = 0;

	loop do
		applyGravity( theSystem);
		applyVelocity(theSystem);

		currentState = getSystemState(theSystem);
		numSteps    += 1;


		if (currentState[:x] == initialState[:x])
			if (loopX == 0)
				loopX = numSteps;
				putLoop(numSteps, loopX, "X");
			end
		end

		if (currentState[:y] == initialState[:y])
			if (loopY == 0)
				loopY = numSteps;
				putLoop(numSteps, loopY, "Y");
			end
		end

		if (currentState[:z] == initialState[:z])
			if (loopZ == 0)
				loopZ = numSteps;
				putLoop(numSteps, loopZ, "Z");
			end
		end
		
		
		if (loopX != 0 && loopY != 0 && loopZ != 0)
			break;
		end
	end

	return { :x => loopX, :y => loopY, :z => loopZ };

end





#==============================================================================
#		findSystemLoop : Find the overall system loop.
#------------------------------------------------------------------------------
def findSystemLoop(theLoops)

	loopX = theLoops[:x];
	loopY = theLoops[:y];
	loopZ = theLoops[:z];

	numSteps = loopX.lcm(loopY).lcm(loopZ);

	puts "State repeats after #{numSteps} loops (dimension loop)";

end





#==============================================================================
#		getSystem : Get the system.
#------------------------------------------------------------------------------
def getSystem(theInput)

	theSystem = Array.new();
	
	theInput.lines.each do |theLine|
		if (theLine =~ /<x=(.+), y=(.+), z=(.+)>/)

			theMoon = {	:pos => Point.new($1.to_i, $2.to_i, $3.to_i),
						:vel => Point.new(0, 0, 0) };

			theSystem << theMoon;
		
		end
	end
	
	return theSystem;

end



# Part One
theSystem = getSystem(theInput)

#stepSystem(theSystem, 10000);



# Part Two
#

#loopSystem(theSystem);

theLoops = findDimensionLoop(theSystem);
findSystemLoop(theLoops);



