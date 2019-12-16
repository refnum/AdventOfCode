#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		Day15.rb
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
#		IntcodeVM : Intcode virtual machine.
#------------------------------------------------------------------------------
class IntcodeVM

	#==========================================================================
	#		Constants
	#--------------------------------------------------------------------------
	OP_CODES =
	{
		1  => :OP_ADD,
		2  => :OP_MULTIPLY,
		3  => :OP_INPUT,
		4  => :OP_OUTPUT,
		5  => :OP_JUMP_IF_TRUE,
		6  => :OP_JUMP_IF_FALSE,
		7  => :OP_LESS_THAN,
		8  => :OP_EQUALS,
		9  => :OP_SET_REL_BASE,
		99 => :OP_HALT
	};

	OP_SIZE =
	{
		:OP_ADD				=> 4,
		:OP_MULTIPLY		=> 4,
		:OP_INPUT			=> 2,
		:OP_OUTPUT			=> 2,
		:OP_JUMP_IF_TRUE	=> 3,
		:OP_JUMP_IF_FALSE	=> 3,
		:OP_LESS_THAN		=> 4,
		:OP_EQUALS			=> 4,
		:OP_SET_REL_BASE	=> 2,
		:OP_HALT			=> 0
	};

	OP_MODES =
	{
		0 => :MODE_POSITION,
		1 => :MODE_IMMEDIATE,
		2 => :MODE_RELATIVE
	}



	#==========================================================================
	#		initialize : Initialiser.
	#--------------------------------------------------------------------------
	def initialize(theName, theProgram, theInputs=[])

		@name			= theName.dup;
		@logging		= false;

		@memory			= theProgram.dup;
		@inputMethod	= nil;
		@outputMethod	= nil;
		@inputBuffer	= theInputs.dup;
		@outputBuffer	= [];

		@pc				= 0;
		@reg_rel		= 0;

	end



	#==========================================================================
	#		setInputOutput : Set input / output callbacks.
	#--------------------------------------------------------------------------
	def setInputOutput(inputMethod, outputMethod)
	
		@inputMethod  = inputMethod;
		@outputMethod = outputMethod;

	end



	#==========================================================================
	#		addInput : Add an input.
	#--------------------------------------------------------------------------
	def addInput(theValue)

		putLog("addInput(#{theValue})");
		@inputBuffer << theValue;

	end



	#==========================================================================
	#		getOutput : Get the last output.
	#--------------------------------------------------------------------------
	def getOutput

		putLog("getOutput() -> (#{@outputs.last})");
	
		if (@outputBuffer.empty?)
			abort("Can't get output from empty #{@name}!");
		else
			return @outputBuffer.shift;
		end

	end



	#==========================================================================
	#		getOutputs : Get the outputs.
	#--------------------------------------------------------------------------
	def getOutputs

		putLog("getOutputs() -> (#{@outputs})");
	
		return @outputBuffer;

	end



	#==========================================================================
	#		execute : Execute the VM.
	#--------------------------------------------------------------------------
	def execute

		putLog("execute...");
		areDone = false;
		
		while (!areDone) do

			# Get the state we need
			theInstruction = loadMem(@pc);

			opCode   = getOpCode(  theInstruction);
			opParams = getOpParams(theInstruction, opCode);



			# Execute the instruction
			case opCode
			when :OP_ADD
				executeAdd(opCode, opParams);

			when :OP_MULTIPLY
				executeMultiply(opCode, opParams, theInstruction);

			when :OP_INPUT
				executeInput(opCode, opParams, theInstruction);

			when :OP_OUTPUT
				executeOutput(opCode, opParams);

			when :OP_JUMP_IF_TRUE
				executeJumpIfTrue(opCode, opParams);

			when :OP_JUMP_IF_FALSE
				executeJumpIfFalse(opCode, opParams);

			when :OP_LESS_THAN
				executeLessThan(opCode, opParams);

			when :OP_EQUALS
				executeEquals(opCode, opParams);

			when :OP_SET_REL_BASE
				executeSetRelativeBase(opCode, opParams);

			when :OP_HALT
				executeHalt(opCode, opParams);
				areDone = true;
			end
		
			@pc += getOpSize(opCode);

		end

	end



private
	#==========================================================================
	#		putLog : Log some text.
	#--------------------------------------------------------------------------
	def putLog(theText)

		if (@logging)
			puts "[#{@name}] #{theText}";
		end

	end



	#==========================================================================
	#		getOpCode : Decode an instruction's opcode.
	#--------------------------------------------------------------------------
	def getOpCode(theInstruction)

		theCode = theInstruction - ((theInstruction / 100) * 100);

		if (OP_CODES.has_key?(theCode))
			return OP_CODES[theCode];
		else
			abort("Unknown opCode #{theCode}, when decoding #{theInstruction} at #{@pc}");
		end

	end



	#==========================================================================
	#		getOpCode : Get an opcode's size.
	#--------------------------------------------------------------------------
	def getOpSize(opCode)

		return OP_SIZE[opCode];

	end



	#==========================================================================
	#		getOpParamMode : Get an opcode parameter's mode.
	#--------------------------------------------------------------------------
	def getOpParamMode(theInstruction, theIndex)

		theMode = theInstruction / 10;

		(1..theIndex).each do 
			theMode = theMode / 10;
		end

		theMode = theMode - ((theMode / 10) * 10);

		if (OP_MODES.has_key?(theMode))
			return OP_MODES[theMode];
		else
			abort("Unknown param mode #{theMode}, when decoding #{theInstruction} at #{@pc}");
		end

	end



	#==========================================================================
	#		getOpParamValue : Get an opcode parameter as a value.
	#--------------------------------------------------------------------------
	def getOpParamValue(theParam, theMode)

		case theMode
		when :MODE_POSITION
			return loadMem(theParam);
	
		when :MODE_IMMEDIATE
			return theParam;
			
		when :MODE_RELATIVE
			return loadMem(@reg_rel + theParam);
		end

	end



	#==========================================================================
	#		getOpParamAddress : Get an opcode parameter as an address.
	#--------------------------------------------------------------------------
	def getOpParamAddress(theParam, theMode)

		case theMode
		when :MODE_POSITION
			return theParam;
	
		when :MODE_IMMEDIATE
			return -1;
			
		when :MODE_RELATIVE
			return @reg_rel + theParam;
		end

	end



	#==========================================================================
	#		getOpParams : Get an opcode's parameters.
	#--------------------------------------------------------------------------
	def getOpParams(theInstruction, opCode)

		opSize    = getOpSize(opCode);
		numParams = (opSize >= 1) ? (opSize - 1) : 0;
		opParams  = { :numParams => numParams };

		for n in (1..numParams) do
			paramSym = "param#{n}".to_sym;
			modeSym  = "mode#{n}".to_sym;
			valueSym = "value#{n}".to_sym;
			addrSym  = "addrs#{n}".to_sym;
			
			paramN = loadMem(@pc + n);
			modeN  = getOpParamMode(theInstruction, n);

			opParams[paramSym] = paramN;
			opParams[modeSym]  = modeN;
			opParams[valueSym] = getOpParamValue(  paramN, modeN);
			opParams[addrSym]  = getOpParamAddress(paramN, modeN);
		end

		return opParams;
	end



	#==========================================================================
	#		traceOp : Trace an opcode.
	#--------------------------------------------------------------------------
	def traceOp(opCode, opParams, theText)
	
		if (@logging)
			# Print the instruction
			theInstruction = loadMem(@pc);
			opCode   = getOpCode(  theInstruction);
			opParams = getOpParams(theInstruction, opCode);
			opSize   = getOpSize(  opCode);
			
			print "[#{theInstruction}] ";
			
			for n in (1..opSize-1) do
				print "[#{loadMem(@pc + n)}]";
			end
			
			puts "";
			puts "    opCode   : #{opCode}";
			puts "    opParams : #{opParams}";



			# Print the operation
			numParams = opParams[:numParams];
			
			print("    #{opCode}(")
		
			for n in (1..numParams) do
				print(opParams["param#{n}".to_sym]);
				print(n == numParams ? ")" : ", ");
			end
		
			puts(") => #{theText}");
			puts "";
			
		end
								
	end



	#==========================================================================
	#		loadMem : Load from memory.
	#--------------------------------------------------------------------------
	def loadMem(theOffset)
	
		if (theOffset >= @memory.size || @memory[theOffset] == nil)
			return 0;
		else
			return @memory[theOffset];
		end

	end



	#==========================================================================
	#		storeMem : Store to memory.
	#--------------------------------------------------------------------------
	def storeMem(theOffset, theValue)
	
		return @memory[theOffset] = theValue;

	end



	#==========================================================================
	#		loadInput : Load an input.
	#--------------------------------------------------------------------------
	def loadInput

		if (@inputMethod != nil)
			return @inputMethod.call();
		
		elsif (!@inputMethods.empty?)
			return @inputBuffer.shift;
		
		else
			print "Input: ";
			return gets.chomp.to_i;
		end

	end



	#==========================================================================
	#		storeOutput : Store an output.
	#--------------------------------------------------------------------------
	def storeOutput(theValue)

		if (@outputMethod != nil)
			@outputMethod.call(theValue);
		else
			@outputBuffer << theValue;
		end

	end



	#==========================================================================
	#		executeAdd : Execute an OP_ADD instruction.
	#--------------------------------------------------------------------------
	def executeAdd(opCode, opParams)

		value1 = opParams[:value1];
		value2 = opParams[:value2];
		dst    = opParams[:addrs3];

		result = value1 + value2;
		traceOp(opCode, opParams, "#{value1} + #{value2}, storeMem(#{dst}, #{result})");

		storeMem(dst, result);

	end



	#==========================================================================
	#		executeMultiply : Execute an OP_MULTIPLY instruction.
	#--------------------------------------------------------------------------
	def executeMultiply(opCode, opParams, theInstruction)

		value1 = opParams[:value1];
		value2 = opParams[:value2];
		dst    = opParams[:addrs3];

		result = value1 * value2;
		traceOp(opCode, opParams, "#{value1} * #{value2}, storeMem(#{dst}, #{result})");

		storeMem(dst, result);

	end



	#==========================================================================
	#		executeInput : Execute an OP_INPUT instruction.
	#--------------------------------------------------------------------------
	def executeInput(opCode, opParams, theInstruction)

		value1 = loadInput();
		dst    = opParams[:addrs1];

		result = value1;
		traceOp(opCode, opParams, "#{value1}, storeMem(#{dst}, #{result})");

		storeMem(dst, result);

	end



	#==========================================================================
	#		executeOutput : Execute an OP_OUTPUT instruction.
	#--------------------------------------------------------------------------
	def executeOutput(opCode, opParams)

		value1 = opParams[:value1];

		result = value1;
		traceOp(opCode, opParams, "#{value1}, storeOutput(#{result})");

		storeOutput(result);

	end



	#==========================================================================
	#		executeJumpIfTrue : Execute an OP_JUMP_IF_TRUE instruction.
	#--------------------------------------------------------------------------
	def executeJumpIfTrue(opCode, opParams)

		value1 = opParams[:value1];
		value2 = opParams[:value2];

		if (value1 != 0)
			traceOp(opCode, opParams, "#{value1} != 0, @pc = #{value2})");
			@pc = value2 - getOpSize(opCode);

		else
			traceOp(opCode, opParams, "#{value1} == 0, @pc unchanged");
		end

	end



	#==========================================================================
	#		executeJumpIfFalse : Execute an OP_JUMP_IF_FALSE instruction.
	#--------------------------------------------------------------------------
	def executeJumpIfFalse(opCode, opParams)

		value1 = opParams[:value1];
		value2 = opParams[:value2];

		if (value1 == 0)
			traceOp(opCode, opParams, "#{value1} == 0, @pc = #{value2})");
			@pc = value2 - getOpSize(opCode);

		else
			traceOp(opCode, opParams, "#{value1} != 0, @pc unchanged");
		end

	end



	#==========================================================================
	#		executeLessThan : Execute an OP_LESS_THAN instruction.
	#--------------------------------------------------------------------------
	def executeLessThan(opCode, opParams)

		value1 = opParams[:value1];
		value2 = opParams[:value2];
		dst    = opParams[:addrs3];

		result = (value1 < value2) ? 1 : 0;
		traceOp(opCode, opParams, "(#{value1} < #{value2}) -> #{result}, storeMem(#{dst}, #{result})");

		storeMem(dst, result);

	end



	#==========================================================================
	#		executeEquals : Execute an OP_EQUALS instruction.
	#--------------------------------------------------------------------------
	def executeEquals(opCode, opParams)

		value1 = opParams[:value1];
		value2 = opParams[:value2];
		dst    = opParams[:addrs3];

		result = (value1 == value2) ? 1 : 0;
		traceOp(opCode, opParams, "(#{value1} == #{value2}) -> #{result}, storeMem(#{dst}, #{result})");

		storeMem(dst, result);

	end



	#==========================================================================
	#		executeSetRelativeBase : Execute an OP_SET_REL_BASE instruction.
	#--------------------------------------------------------------------------
	def executeSetRelativeBase(opCode, opParams)

		value1 = opParams[:value1];

		result = @reg_rel + value1;
		traceOp(opCode, opParams, "#{value1}, @reg_rel = #{result}");

		@reg_rel = result;

	end



	#==========================================================================
	#		executeHalt : Execute an OP_HALT instruction.
	#--------------------------------------------------------------------------
	def executeHalt(opCode, opParams)

		traceOp(opCode, opParams, "halting");

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
#		Robot : Robot painter virtual machine.
#------------------------------------------------------------------------------
class Robot

	#==========================================================================
	#		Constants
	#--------------------------------------------------------------------------
	# Robot
	NORTH = 1;
	SOUTH = 2;
	WEST  = 3;
	EAST  = 4;

	WALL    = 0;
	MOVED   = 1;
	OXYGEN  = 2;


	# Map
	TILE_UNKNOWN = -5;
	TILE_OXYGEN  = -4;
	TILE_ROBOT   = -3;
	TILE_WALL    = -2;
	TILE_EMPTY   = -1;
	TILE_START   = 0;


	# Names
	NAME_MOVEMENT = { NORTH => "NORTH", SOUTH => "SOUTH", WEST => "WEST", EAST => "EAST" };
	NAME_RESULT   = { WALL => "WALL", MOVED => "MOVED", OXYGEN => "OXYGEN" };

	ANSI_CLEAR = "\e[2J\e[f";
	ANSI_RED   = "\e[31m";
	ANSI_GREEN = "\e[32m";
	ANSI_BLUE  = "\e[34m";
	ANSI_OFF   = "\e[0m";



	#==========================================================================
	#		initialize : Initialiser.
	#--------------------------------------------------------------------------
	def initialize(theProgram)

		@vm      = IntcodeVM.new("Robot", theProgram);
		@logging = false;

		@movement   = NORTH;
		@position   = Point.new();
		@pos_start  = Point.new();
		@pos_oxygen = Point.new();

		@map   = Hash.new();
		@moves = Hash.new();

		setTile(@position, TILE_ROBOT);
		setMove(@position, 0);

	end



	#==========================================================================
	#		run : Run the robot.
	#--------------------------------------------------------------------------
	def run
	
		@vm.setInputOutput(method(:robotInput), method(:robotOutput));
		@vm.execute();
		
		putMap();
	
	end



	#==========================================================================
	#		putMap : Print the map.
	#--------------------------------------------------------------------------
	def putMap
	
		# Find the bounds
		boundsMin = Point.new;
		boundsMax = Point.new;
				
		@map.each_key do |thePoint|
		
			if ( thePoint.x < boundsMin.x)
				boundsMin.x =  thePoint.x;
			end

			if ( thePoint.x > boundsMax.x)
				boundsMax.x =  thePoint.x;
			end

			if ( thePoint.y < boundsMin.y)
				boundsMin.y =  thePoint.y;
			end

			if ( thePoint.y > boundsMax.y)
				boundsMax.y =  thePoint.y;
			end
		
		end
		
		boundsMin.x -= 1;
		boundsMax.x += 1;

		boundsMin.y -= 1;
		boundsMax.y += 1;



		# Print the map
		puts ANSI_CLEAR;
	
		boundsMax.y.downto(boundsMin.y) do |y|
			boundsMin.x.upto(boundsMax.x) do |x|
			
				theTile = getTile(Point.new(x, y), TILE_UNKNOWN);

				case theTile
				when TILE_UNKNOWN
					print '#';

				when TILE_OXYGEN
					print ANSI_GREEN + 'O' + ANSI_OFF;
				
				when TILE_ROBOT
					print ANSI_BLUE + 'D' + ANSI_OFF;

				when TILE_WALL
					print '+';

				when TILE_EMPTY
					print ' ';
				
				when TILE_START
					print ANSI_RED + 'S' + ANSI_OFF;
				
				else
					print '?'
				end
			end
			
			puts "";
		end
		
		puts "";

	end



private
	#==========================================================================
	#		trace : Emit a log trace.
	#--------------------------------------------------------------------------
	def trace(theText)
	
		if (@logging)
			puts theText;
		end

	end



	#==========================================================================
	#		robotInput : Provide input for the robot.
	#--------------------------------------------------------------------------
	def robotInput

#		putMap();
		trace("robotInput: at #{@position}, moving #{NAME_MOVEMENT[@movement]}");

		return @movement;
	
	end



	#==========================================================================
	#		robotOutput : Receive output from the robot.
	#--------------------------------------------------------------------------
	def robotOutput(theValue)

		trace("robotOutput: moving #{NAME_MOVEMENT[@movement]} resulted in #{NAME_RESULT[theValue]}");

		case theValue
		when WALL
			handleWALL();

		when MOVED, OXYGEN
			handleMOVE(theValue);

		else
			abort("Unknown output #{theValue}");
		end

	end



	#==========================================================================
	#		handleWALL : Handle a WALL result.
	#--------------------------------------------------------------------------
	def handleWALL

		# Update our state
		#
		# The position we would have moved to is a wall, so
		# mark it and choose an appropriate movement.
		setTile(positionAfterMove(), TILE_WALL);
		nextMovement(true);

	end
	

	#==========================================================================
	#		handleMOVE : Handle a MOVED / OXYGEN result.
	#--------------------------------------------------------------------------
	def handleMOVE(theType)

		# Get the state we need
		oldPosition = @position;
		@position   = positionAfterMove();

		if (theType == OXYGEN)
			@pos_oxygen = @position;
			theTile = TILE_OXYGEN;
		else
			theTile = TILE_ROBOT;
		end


		# Update the previous tile
		if (oldPosition == @pos_start)
			setTile(oldPosition, TILE_START);

		elsif (oldPosition == @pos_oxygen)
			setTile(oldPosition, TILE_OXYGEN);

		else
			setTile(oldPosition, TILE_EMPTY);
		end


		# Update the current tile
		setTile(@position, theTile);
		setMove(@position, getMove(oldPosition) + 1);

		nextMovement(false);


		# Returned to start
		if (oldPosition == @pos_start)

			numMoves = getMove(@pos_oxygen);
			if (numMoves != 0)
				# Part One
				putMap();
				puts "Returned to start, oxygen found at #{@pos_oxygen} after #{getMove(@pos_oxygen)}";


				# Part Two
				releaseOxygen();
				exit;
			end
		end

	end



	#==========================================================================
	#		fillOxygen : Fill with oxygen.
	#--------------------------------------------------------------------------
	def fillOxygen(theTimes, thePoint, theTime)
	
		# Check the current tile
		theTile = getTile(thePoint);
		
		if (theTile == TILE_WALL)
			return;
		end

		if (theTimes.has_key?(thePoint) && theTimes[thePoint] <= theTime)
			return;
		end


		# Fill the tile		
		theTimes[thePoint] = theTime;

		fillOxygen(theTimes, Point.new(thePoint.x + 1, thePoint.y),     theTime + 1);
		fillOxygen(theTimes, Point.new(thePoint.x - 1, thePoint.y),     theTime + 1);
		fillOxygen(theTimes, Point.new(thePoint.x,     thePoint.y + 1), theTime + 1);
		fillOxygen(theTimes, Point.new(thePoint.x,     thePoint.y - 1), theTime + 1);

	end



	#==========================================================================
	#		releaseOxygen : Release the oxygen onto the map.
	#--------------------------------------------------------------------------
	def releaseOxygen
	
		# Release the oxygen
		theTimes = Hash.new();
		fillOxygen(theTimes, @pos_oxygen, 0);


		# Print the largest
		maxTime = theTimes.values.max;
		puts "Time to fill from start is #{maxTime}";

	end



	#==========================================================================
	#		getTile : Get the tile at a point.
	#--------------------------------------------------------------------------
	def getTile(thePoint, defaultValue=0)

		if (thePoint == @pos_start)
			theTile = TILE_START;
		
		elsif (@map.has_key?(thePoint))
			theTile = @map[thePoint];

		else
			theTile = defaultValue;
		end

		return theTile;

	end



	#==========================================================================
	#		setTile : Set the Tile at a point.
	#--------------------------------------------------------------------------
	def setTile(thePoint, theTile)

		@map[thePoint.dup] = theTile;

	end



	#==========================================================================
	#		getMove : Get the moves at a point.
	#--------------------------------------------------------------------------
	def getMove(thePoint)

		numMoves = @moves.fetch(thePoint, 0);
		
		return numMoves;

	end



	#==========================================================================
	#		setMove : Set the moves at a point.
	#--------------------------------------------------------------------------
	def setMove(thePoint, numMoves)

		if (!@moves.has_key?(thePoint) || numMoves < @moves[thePoint])
			@moves[thePoint] = numMoves;
		end

	end



	#==========================================================================
	#		nextMovement : Choose the next movement.
	#--------------------------------------------------------------------------
	def nextMovement(hitWall)
	
		# Turn to put wall on right
		if (hitWall)
			case @movement
			when NORTH
				@movement = WEST;

			when SOUTH
				@movement = EAST;

			when WEST
				@movement = SOUTH;

			when EAST
				@movement = NORTH;
		
			else
				abort("Unknown movement #{@movement}");
			end

		# Turn to put wall ahead
		else
			case @movement
			when NORTH
				@movement = EAST;

			when SOUTH
				@movement = WEST;

			when WEST
				@movement = NORTH;

			when EAST
				@movement = SOUTH;
		
			else
				abort("Unknown movement #{@movement}");
			end
		end
		

	end



	#==========================================================================
	#		positionAfterMove : Get a position after a movement.
	#--------------------------------------------------------------------------
	def positionAfterMove
	
		thePosition = @position.dup;

		case @movement
		when NORTH
			thePosition.y += 1;

		when SOUTH
			thePosition.y -= 1;

		when WEST
			thePosition.x -= 1;

		when EAST
			thePosition.x += 1;
		
		else
			abort("Unknown movement #{@movement}");
		end
		
		return thePosition;

	end

end







# Part One
theProgram = [3,1033,1008,1033,1,1032,1005,1032,31,1008,1033,2,1032,1005,1032,58,1008,1033,3,1032,1005,1032,81,1008,1033,4,1032,1005,1032,104,99,1002,1034,1,1039,102,1,1036,1041,1001,1035,-1,1040,1008,1038,0,1043,102,-1,1043,1032,1,1037,1032,1042,1106,0,124,1001,1034,0,1039,102,1,1036,1041,1001,1035,1,1040,1008,1038,0,1043,1,1037,1038,1042,1105,1,124,1001,1034,-1,1039,1008,1036,0,1041,1002,1035,1,1040,101,0,1038,1043,1002,1037,1,1042,1106,0,124,1001,1034,1,1039,1008,1036,0,1041,1001,1035,0,1040,1002,1038,1,1043,1002,1037,1,1042,1006,1039,217,1006,1040,217,1008,1039,40,1032,1005,1032,217,1008,1040,40,1032,1005,1032,217,1008,1039,35,1032,1006,1032,165,1008,1040,7,1032,1006,1032,165,1101,2,0,1044,1105,1,224,2,1041,1043,1032,1006,1032,179,1101,1,0,1044,1105,1,224,1,1041,1043,1032,1006,1032,217,1,1042,1043,1032,1001,1032,-1,1032,1002,1032,39,1032,1,1032,1039,1032,101,-1,1032,1032,101,252,1032,211,1007,0,38,1044,1106,0,224,1101,0,0,1044,1105,1,224,1006,1044,247,1001,1039,0,1034,101,0,1040,1035,101,0,1041,1036,102,1,1043,1038,102,1,1042,1037,4,1044,1106,0,0,4,23,34,36,20,5,93,36,72,13,75,47,14,34,44,15,61,24,50,12,76,22,40,17,13,24,59,32,99,35,33,5,31,91,44,27,11,21,15,20,99,6,62,16,62,6,14,69,10,53,37,52,99,18,92,33,19,99,6,82,13,19,45,15,21,39,59,1,24,39,79,77,35,5,69,79,95,28,49,71,7,83,81,99,58,17,3,98,37,11,14,29,44,50,23,75,1,15,67,45,35,44,93,62,31,6,85,81,24,19,22,86,54,19,77,6,4,15,35,40,42,7,9,69,2,53,63,78,94,29,82,3,16,64,86,48,36,57,20,54,25,7,89,51,31,52,17,64,51,12,67,6,99,12,17,99,10,73,16,25,57,78,2,4,46,37,96,25,9,96,80,6,60,9,7,3,24,52,33,73,23,22,71,24,77,19,96,35,86,50,93,2,75,25,59,14,79,31,54,4,24,87,17,18,88,25,36,49,87,22,22,20,76,31,62,18,39,39,35,70,79,37,35,72,26,25,96,8,35,25,60,26,34,5,21,37,79,65,99,50,7,33,54,69,39,35,21,72,9,67,16,92,47,65,89,20,77,34,85,24,87,3,49,62,2,81,17,49,31,41,29,80,18,63,2,70,18,96,31,53,70,24,37,78,59,20,74,8,67,93,29,24,71,19,23,28,90,10,21,34,49,18,14,48,90,13,54,93,4,96,95,23,26,85,3,3,99,24,43,8,72,19,50,17,58,94,5,50,16,12,91,25,68,68,42,27,54,49,2,44,47,31,3,35,66,36,67,2,84,74,14,3,5,63,95,21,23,47,22,61,25,28,69,3,50,13,74,96,53,9,32,21,90,8,8,34,66,49,18,34,63,28,90,37,14,43,33,97,12,39,96,31,23,76,14,16,12,74,43,10,63,14,20,95,73,1,59,5,40,97,42,47,29,54,64,17,73,44,10,44,43,42,53,37,37,29,48,9,10,18,28,69,62,25,50,53,29,15,60,10,74,1,83,21,21,49,19,61,35,30,99,87,10,42,17,4,67,87,6,89,2,21,56,1,80,24,1,64,24,42,95,20,95,77,23,29,84,39,5,91,65,16,39,46,36,57,23,30,49,70,21,7,92,22,90,1,25,41,20,35,59,54,98,88,40,23,33,99,5,95,28,73,15,72,76,8,2,11,86,23,31,6,69,13,23,93,86,59,24,16,90,23,32,41,11,50,84,58,28,40,3,71,12,86,33,45,34,33,81,23,10,33,53,28,81,68,15,96,4,68,3,54,19,73,27,3,21,99,5,47,77,26,28,49,35,92,4,18,1,66,16,1,28,28,66,56,26,23,45,53,20,55,32,26,57,67,5,86,73,9,70,2,87,16,75,93,31,78,66,14,76,4,64,24,80,20,45,15,75,17,54,85,16,16,28,45,20,85,34,7,2,82,59,25,15,58,92,36,88,46,22,78,6,71,15,23,67,14,71,60,33,56,10,61,7,40,79,37,59,58,37,34,59,17,80,10,90,11,89,95,9,37,9,45,60,10,29,73,4,95,42,29,54,49,21,36,65,34,21,94,70,37,86,33,92,84,15,18,72,82,28,12,12,25,91,40,68,2,8,83,59,62,4,29,75,79,34,21,99,24,90,79,13,22,92,62,73,19,9,84,46,11,88,32,92,35,58,79,31,4,30,90,21,93,14,76,55,48,23,43,13,89,13,67,33,90,86,70,32,65,15,77,32,48,25,61,27,58,2,81,36,59,10,77,5,95,35,41,50,88,0,0,21,21,1,10,1,0,0,0,0,0,0];

theRobot = Robot.new(theProgram);
theRobot.run();




