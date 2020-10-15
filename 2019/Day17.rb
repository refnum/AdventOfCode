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
#		ANSI colours.
#------------------------------------------------------------------------------
class String

	def black;          "\e[30m#{self}\e[0m";	end
	def red;            "\e[31m#{self}\e[0m";	end
	def green;          "\e[32m#{self}\e[0m";	end
	def brown;          "\e[33m#{self}\e[0m";	end
	def blue;           "\e[34m#{self}\e[0m";	end
	def magenta;        "\e[35m#{self}\e[0m";	end
	def cyan;           "\e[36m#{self}\e[0m";	end
	def gray;           "\e[37m#{self}\e[0m";	end

	def bg_black;       "\e[40m#{self}\e[0m";	end
	def bg_red;         "\e[41m#{self}\e[0m";	end
	def bg_green;       "\e[42m#{self}\e[0m";	end
	def bg_brown;       "\e[43m#{self}\e[0m";	end
	def bg_blue;        "\e[44m#{self}\e[0m";	end
	def bg_magenta;     "\e[45m#{self}\e[0m";	end
	def bg_cyan;        "\e[46m#{self}\e[0m";	end
	def bg_gray;        "\e[47m#{self}\e[0m";	end

	def bold;           "\e[1m#{self}\e[22m";	end
	def italic;         "\e[3m#{self}\e[23m";	end
	def underline;      "\e[4m#{self}\e[24m";	end
	def blink;          "\e[5m#{self}\e[25m";	end
	def reverse_color;  "\e[7m#{self}\e[27m";	end
	
	def clear_screen;	"\e[2J\e[f#{self}";		end
end





#==============================================================================
#		Robot : Robot painter virtual machine.
#------------------------------------------------------------------------------
class Robot

	#==========================================================================
	#		Constants
	#--------------------------------------------------------------------------
	TILE_OUTSIDE		= '+';
	TILE_EMPTY			= '.';
	TILE_SCAFFOLD		= '#';
	TILE_INTERSECTION	= 'O';
	TILE_ROBOT_U		= '^';
	TILE_ROBOT_D		= 'v';
	TILE_ROBOT_L		= '<';
	TILE_ROBOT_R		= '>';
	TILE_ROBOT_LOST		= 'X';
	
	MAP_HEIGHT = 47;



	#==========================================================================
	#		initialize : Initialiser.
	#--------------------------------------------------------------------------
	def initialize(theProgram)

		@vm      = IntcodeVM.new("Robot", theProgram);
		@logging = false;
		@video   = true;

		@program = robotProgram();

		@map    = Hash.new();
		@cursor = Point.new();

	end



	#==========================================================================
	#		run : Run the robot.
	#--------------------------------------------------------------------------
	def run
	
		@vm.setInputOutput(method(:robotInput), method(:robotOutput));
		@vm.execute();
		
		# Part One
#		putMap();
#		countIntersections();
	
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
		puts "";
		puts "Frame #{@frame}:";
	
		boundsMax.y.downto(boundsMin.y) do |y|
			boundsMin.x.upto(boundsMax.x) do |x|

				theTile = getMap(Point.new(x, y), TILE_OUTSIDE);
				printTile(theTile);

			end
			puts "";
		end
		
		puts "";

	end



	#==========================================================================
	#		countIntersections : Count the intersections.
	#--------------------------------------------------------------------------
	def countIntersections
	
		# Get the intersections
		thePoints = [];
		
		@map.each_pair do |thePoint, theTile|
		
			if (theTile == TILE_SCAFFOLD)
				pointU = Point.new(thePoint.x,     thePoint.y - 1);
				pointD = Point.new(thePoint.x,     thePoint.y + 1);
				pointL = Point.new(thePoint.x - 1, thePoint.y);
				pointR = Point.new(thePoint.x + 1, thePoint.y);

				if (getMap(pointU, TILE_OUTSIDE) == TILE_SCAFFOLD &&
					getMap(pointD, TILE_OUTSIDE) == TILE_SCAFFOLD &&
					getMap(pointL, TILE_OUTSIDE) == TILE_SCAFFOLD &&
					getMap(pointR, TILE_OUTSIDE) == TILE_SCAFFOLD)
					thePoints << thePoint;
				end
			end

		end



		# Calculate the total
		puts "Found intersections at:";

		theSum = 0;
		
		thePoints.each do |thePoint|
			puts "  #{thePoint}";
			theSum += (thePoint.x * thePoint.y);
		end
		
		puts "";
		puts "Sum of the alignment parameters is: #{theSum}";
	
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

		return @program.shift;
		
	end



	#==========================================================================
	#		robotOutput : Receive output from the robot.
	#--------------------------------------------------------------------------
	def robotOutput(theValue)


		# Live video
		if (@video)
		
			if (theValue < 128)
				printTile(theValue.chr);
			else
				puts "";
				puts "Total space dust: #{theValue}";
			end


		# Buffered map
		else
			if (theValue == 10)
				@cursor.x  = 0;
				@cursor.y += 1;
			else
				setMap(@cursor, theValue.chr);
				@cursor.x += 1;
			end
		end
			
	end



	#==========================================================================
	#		robotProgram : Get the program for the robot.
	#--------------------------------------------------------------------------
	def robotProgram
	
		# Program
		#                   11111111112  
		#          12345678901234567890
		#          |                  |
		main    = "A,A,B,C,B,A,C,B,C,A";
		funcA   = "L,6,R,12,L,6,L,8,L,8";
		funcB   = "L,6,R,12,R,8,L,8";
		funcC   = "L,4,L,4,L,6";
		doVideo = (@video ? "y" : "n");
		
		theText    = [main, funcA, funcB, funcC, doVideo].join("\n") + "\n";
		theProgram = theText.chars.map(&:ord);

		return theProgram;

	end



	#==========================================================================
	#		getMap : Get the map at a point.
	#--------------------------------------------------------------------------
	def getMap(thePoint, defaultValue=0)

		if (@map.has_key?(thePoint))
			theTile = @map[thePoint];

		else
			theTile = defaultValue;
		end

		return theTile;

	end



	#==========================================================================
	#		setMap : Set the map at a point.
	#--------------------------------------------------------------------------
	def setMap(thePoint, theTile)

		@map[thePoint.dup] = theTile;

	end



	#==========================================================================
	#		printTile : Print a map tile.
	#--------------------------------------------------------------------------
	def printTile(theTile)

		case theTile
		when TILE_OUTSIDE
			print theTile.magenta;

		when TILE_EMPTY
			print theTile.gray;

		when TILE_SCAFFOLD
			print theTile.green;

		when TILE_INTERSECTION
			print theTile.cyan;

		when TILE_ROBOT_U, TILE_ROBOT_D, TILE_ROBOT_L, TILE_ROBOT_R
			print theTile.red;

		when TILE_ROBOT_LOST
			print theTile.magenta;
		
		else
			print theTile;
		end
	
	end

end







# Part One
#theProgram = [1,330,331,332,109,3564,1102,1182,1,15,1101,0,1449,24,1002,0,1,570,1006,570,36,101,0,571,0,1001,570,-1,570,1001,24,1,24,1106,0,18,1008,571,0,571,1001,15,1,15,1008,15,1449,570,1006,570,14,21102,58,1,0,1105,1,786,1006,332,62,99,21101,333,0,1,21102,1,73,0,1106,0,579,1101,0,0,572,1102,1,0,573,3,574,101,1,573,573,1007,574,65,570,1005,570,151,107,67,574,570,1005,570,151,1001,574,-64,574,1002,574,-1,574,1001,572,1,572,1007,572,11,570,1006,570,165,101,1182,572,127,1001,574,0,0,3,574,101,1,573,573,1008,574,10,570,1005,570,189,1008,574,44,570,1006,570,158,1105,1,81,21102,340,1,1,1106,0,177,21102,477,1,1,1105,1,177,21101,0,514,1,21101,176,0,0,1106,0,579,99,21102,1,184,0,1105,1,579,4,574,104,10,99,1007,573,22,570,1006,570,165,102,1,572,1182,21102,375,1,1,21102,1,211,0,1106,0,579,21101,1182,11,1,21102,222,1,0,1105,1,979,21101,388,0,1,21101,233,0,0,1105,1,579,21101,1182,22,1,21102,1,244,0,1105,1,979,21102,1,401,1,21102,255,1,0,1105,1,579,21101,1182,33,1,21102,1,266,0,1106,0,979,21102,1,414,1,21102,1,277,0,1105,1,579,3,575,1008,575,89,570,1008,575,121,575,1,575,570,575,3,574,1008,574,10,570,1006,570,291,104,10,21102,1,1182,1,21101,313,0,0,1105,1,622,1005,575,327,1102,1,1,575,21102,1,327,0,1105,1,786,4,438,99,0,1,1,6,77,97,105,110,58,10,33,10,69,120,112,101,99,116,101,100,32,102,117,110,99,116,105,111,110,32,110,97,109,101,32,98,117,116,32,103,111,116,58,32,0,12,70,117,110,99,116,105,111,110,32,65,58,10,12,70,117,110,99,116,105,111,110,32,66,58,10,12,70,117,110,99,116,105,111,110,32,67,58,10,23,67,111,110,116,105,110,117,111,117,115,32,118,105,100,101,111,32,102,101,101,100,63,10,0,37,10,69,120,112,101,99,116,101,100,32,82,44,32,76,44,32,111,114,32,100,105,115,116,97,110,99,101,32,98,117,116,32,103,111,116,58,32,36,10,69,120,112,101,99,116,101,100,32,99,111,109,109,97,32,111,114,32,110,101,119,108,105,110,101,32,98,117,116,32,103,111,116,58,32,43,10,68,101,102,105,110,105,116,105,111,110,115,32,109,97,121,32,98,101,32,97,116,32,109,111,115,116,32,50,48,32,99,104,97,114,97,99,116,101,114,115,33,10,94,62,118,60,0,1,0,-1,-1,0,1,0,0,0,0,0,0,1,36,16,0,109,4,1202,-3,1,586,21001,0,0,-1,22101,1,-3,-3,21102,0,1,-2,2208,-2,-1,570,1005,570,617,2201,-3,-2,609,4,0,21201,-2,1,-2,1105,1,597,109,-4,2105,1,0,109,5,2102,1,-4,629,21002,0,1,-2,22101,1,-4,-4,21101,0,0,-3,2208,-3,-2,570,1005,570,781,2201,-4,-3,652,21001,0,0,-1,1208,-1,-4,570,1005,570,709,1208,-1,-5,570,1005,570,734,1207,-1,0,570,1005,570,759,1206,-1,774,1001,578,562,684,1,0,576,576,1001,578,566,692,1,0,577,577,21102,1,702,0,1106,0,786,21201,-1,-1,-1,1106,0,676,1001,578,1,578,1008,578,4,570,1006,570,724,1001,578,-4,578,21102,731,1,0,1106,0,786,1106,0,774,1001,578,-1,578,1008,578,-1,570,1006,570,749,1001,578,4,578,21102,756,1,0,1106,0,786,1105,1,774,21202,-1,-11,1,22101,1182,1,1,21101,0,774,0,1105,1,622,21201,-3,1,-3,1106,0,640,109,-5,2106,0,0,109,7,1005,575,802,20102,1,576,-6,20102,1,577,-5,1105,1,814,21101,0,0,-1,21101,0,0,-5,21101,0,0,-6,20208,-6,576,-2,208,-5,577,570,22002,570,-2,-2,21202,-5,45,-3,22201,-6,-3,-3,22101,1449,-3,-3,1201,-3,0,843,1005,0,863,21202,-2,42,-4,22101,46,-4,-4,1206,-2,924,21102,1,1,-1,1106,0,924,1205,-2,873,21101,0,35,-4,1106,0,924,1201,-3,0,878,1008,0,1,570,1006,570,916,1001,374,1,374,2102,1,-3,895,1102,2,1,0,2102,1,-3,902,1001,438,0,438,2202,-6,-5,570,1,570,374,570,1,570,438,438,1001,578,558,921,21002,0,1,-4,1006,575,959,204,-4,22101,1,-6,-6,1208,-6,45,570,1006,570,814,104,10,22101,1,-5,-5,1208,-5,47,570,1006,570,810,104,10,1206,-1,974,99,1206,-1,974,1101,0,1,575,21101,0,973,0,1105,1,786,99,109,-7,2106,0,0,109,6,21102,1,0,-4,21101,0,0,-3,203,-2,22101,1,-3,-3,21208,-2,82,-1,1205,-1,1030,21208,-2,76,-1,1205,-1,1037,21207,-2,48,-1,1205,-1,1124,22107,57,-2,-1,1205,-1,1124,21201,-2,-48,-2,1106,0,1041,21101,0,-4,-2,1105,1,1041,21102,-5,1,-2,21201,-4,1,-4,21207,-4,11,-1,1206,-1,1138,2201,-5,-4,1059,1201,-2,0,0,203,-2,22101,1,-3,-3,21207,-2,48,-1,1205,-1,1107,22107,57,-2,-1,1205,-1,1107,21201,-2,-48,-2,2201,-5,-4,1090,20102,10,0,-1,22201,-2,-1,-2,2201,-5,-4,1103,2101,0,-2,0,1105,1,1060,21208,-2,10,-1,1205,-1,1162,21208,-2,44,-1,1206,-1,1131,1106,0,989,21102,1,439,1,1105,1,1150,21101,0,477,1,1105,1,1150,21102,1,514,1,21101,1149,0,0,1105,1,579,99,21102,1157,1,0,1106,0,579,204,-2,104,10,99,21207,-3,22,-1,1206,-1,1138,2101,0,-5,1176,1201,-4,0,0,109,-6,2105,1,0,36,9,36,1,7,1,36,1,7,1,36,1,7,1,24,7,5,1,7,1,24,1,5,1,5,1,7,1,24,1,5,1,1,13,24,1,5,1,1,1,3,1,32,1,5,1,1,1,3,7,26,1,5,1,1,1,9,1,26,1,5,1,1,1,9,1,26,1,5,1,1,1,9,1,26,9,9,1,32,1,11,1,32,1,11,1,32,1,11,1,32,7,5,1,44,1,44,1,44,1,36,9,36,1,22,9,13,1,22,1,7,1,13,1,20,13,9,7,16,1,1,1,7,1,1,1,9,1,1,1,3,1,10,5,1,1,1,1,7,1,1,1,9,1,1,1,3,1,10,1,3,1,1,1,1,1,7,1,1,1,9,1,1,1,3,1,6,13,7,1,1,1,3,5,1,1,1,5,6,1,3,1,3,1,1,1,9,1,1,1,3,1,3,1,1,1,12,1,3,7,9,13,12,1,7,1,13,1,3,1,3,1,14,1,7,1,13,9,14,1,7,1,17,1,18,9,17,7,44,1,44,1,44,1,42,9,38,1,5,1,38,1,5,1,38,1,5,1,38,1,5,1,38,1,5,1,38,1,5,1,38,1,5,1,38,7,6];


# Part Two
theProgram = [2,330,331,332,109,3564,1102,1182,1,15,1101,0,1449,24,1002,0,1,570,1006,570,36,101,0,571,0,1001,570,-1,570,1001,24,1,24,1106,0,18,1008,571,0,571,1001,15,1,15,1008,15,1449,570,1006,570,14,21102,58,1,0,1105,1,786,1006,332,62,99,21101,333,0,1,21102,1,73,0,1106,0,579,1101,0,0,572,1102,1,0,573,3,574,101,1,573,573,1007,574,65,570,1005,570,151,107,67,574,570,1005,570,151,1001,574,-64,574,1002,574,-1,574,1001,572,1,572,1007,572,11,570,1006,570,165,101,1182,572,127,1001,574,0,0,3,574,101,1,573,573,1008,574,10,570,1005,570,189,1008,574,44,570,1006,570,158,1105,1,81,21102,340,1,1,1106,0,177,21102,477,1,1,1105,1,177,21101,0,514,1,21101,176,0,0,1106,0,579,99,21102,1,184,0,1105,1,579,4,574,104,10,99,1007,573,22,570,1006,570,165,102,1,572,1182,21102,375,1,1,21102,1,211,0,1106,0,579,21101,1182,11,1,21102,222,1,0,1105,1,979,21101,388,0,1,21101,233,0,0,1105,1,579,21101,1182,22,1,21102,1,244,0,1105,1,979,21102,1,401,1,21102,255,1,0,1105,1,579,21101,1182,33,1,21102,1,266,0,1106,0,979,21102,1,414,1,21102,1,277,0,1105,1,579,3,575,1008,575,89,570,1008,575,121,575,1,575,570,575,3,574,1008,574,10,570,1006,570,291,104,10,21102,1,1182,1,21101,313,0,0,1105,1,622,1005,575,327,1102,1,1,575,21102,1,327,0,1105,1,786,4,438,99,0,1,1,6,77,97,105,110,58,10,33,10,69,120,112,101,99,116,101,100,32,102,117,110,99,116,105,111,110,32,110,97,109,101,32,98,117,116,32,103,111,116,58,32,0,12,70,117,110,99,116,105,111,110,32,65,58,10,12,70,117,110,99,116,105,111,110,32,66,58,10,12,70,117,110,99,116,105,111,110,32,67,58,10,23,67,111,110,116,105,110,117,111,117,115,32,118,105,100,101,111,32,102,101,101,100,63,10,0,37,10,69,120,112,101,99,116,101,100,32,82,44,32,76,44,32,111,114,32,100,105,115,116,97,110,99,101,32,98,117,116,32,103,111,116,58,32,36,10,69,120,112,101,99,116,101,100,32,99,111,109,109,97,32,111,114,32,110,101,119,108,105,110,101,32,98,117,116,32,103,111,116,58,32,43,10,68,101,102,105,110,105,116,105,111,110,115,32,109,97,121,32,98,101,32,97,116,32,109,111,115,116,32,50,48,32,99,104,97,114,97,99,116,101,114,115,33,10,94,62,118,60,0,1,0,-1,-1,0,1,0,0,0,0,0,0,1,36,16,0,109,4,1202,-3,1,586,21001,0,0,-1,22101,1,-3,-3,21102,0,1,-2,2208,-2,-1,570,1005,570,617,2201,-3,-2,609,4,0,21201,-2,1,-2,1105,1,597,109,-4,2105,1,0,109,5,2102,1,-4,629,21002,0,1,-2,22101,1,-4,-4,21101,0,0,-3,2208,-3,-2,570,1005,570,781,2201,-4,-3,652,21001,0,0,-1,1208,-1,-4,570,1005,570,709,1208,-1,-5,570,1005,570,734,1207,-1,0,570,1005,570,759,1206,-1,774,1001,578,562,684,1,0,576,576,1001,578,566,692,1,0,577,577,21102,1,702,0,1106,0,786,21201,-1,-1,-1,1106,0,676,1001,578,1,578,1008,578,4,570,1006,570,724,1001,578,-4,578,21102,731,1,0,1106,0,786,1106,0,774,1001,578,-1,578,1008,578,-1,570,1006,570,749,1001,578,4,578,21102,756,1,0,1106,0,786,1105,1,774,21202,-1,-11,1,22101,1182,1,1,21101,0,774,0,1105,1,622,21201,-3,1,-3,1106,0,640,109,-5,2106,0,0,109,7,1005,575,802,20102,1,576,-6,20102,1,577,-5,1105,1,814,21101,0,0,-1,21101,0,0,-5,21101,0,0,-6,20208,-6,576,-2,208,-5,577,570,22002,570,-2,-2,21202,-5,45,-3,22201,-6,-3,-3,22101,1449,-3,-3,1201,-3,0,843,1005,0,863,21202,-2,42,-4,22101,46,-4,-4,1206,-2,924,21102,1,1,-1,1106,0,924,1205,-2,873,21101,0,35,-4,1106,0,924,1201,-3,0,878,1008,0,1,570,1006,570,916,1001,374,1,374,2102,1,-3,895,1102,2,1,0,2102,1,-3,902,1001,438,0,438,2202,-6,-5,570,1,570,374,570,1,570,438,438,1001,578,558,921,21002,0,1,-4,1006,575,959,204,-4,22101,1,-6,-6,1208,-6,45,570,1006,570,814,104,10,22101,1,-5,-5,1208,-5,47,570,1006,570,810,104,10,1206,-1,974,99,1206,-1,974,1101,0,1,575,21101,0,973,0,1105,1,786,99,109,-7,2106,0,0,109,6,21102,1,0,-4,21101,0,0,-3,203,-2,22101,1,-3,-3,21208,-2,82,-1,1205,-1,1030,21208,-2,76,-1,1205,-1,1037,21207,-2,48,-1,1205,-1,1124,22107,57,-2,-1,1205,-1,1124,21201,-2,-48,-2,1106,0,1041,21101,0,-4,-2,1105,1,1041,21102,-5,1,-2,21201,-4,1,-4,21207,-4,11,-1,1206,-1,1138,2201,-5,-4,1059,1201,-2,0,0,203,-2,22101,1,-3,-3,21207,-2,48,-1,1205,-1,1107,22107,57,-2,-1,1205,-1,1107,21201,-2,-48,-2,2201,-5,-4,1090,20102,10,0,-1,22201,-2,-1,-2,2201,-5,-4,1103,2101,0,-2,0,1105,1,1060,21208,-2,10,-1,1205,-1,1162,21208,-2,44,-1,1206,-1,1131,1106,0,989,21102,1,439,1,1105,1,1150,21101,0,477,1,1105,1,1150,21102,1,514,1,21101,1149,0,0,1105,1,579,99,21102,1157,1,0,1106,0,579,204,-2,104,10,99,21207,-3,22,-1,1206,-1,1138,2101,0,-5,1176,1201,-4,0,0,109,-6,2105,1,0,36,9,36,1,7,1,36,1,7,1,36,1,7,1,24,7,5,1,7,1,24,1,5,1,5,1,7,1,24,1,5,1,1,13,24,1,5,1,1,1,3,1,32,1,5,1,1,1,3,7,26,1,5,1,1,1,9,1,26,1,5,1,1,1,9,1,26,1,5,1,1,1,9,1,26,9,9,1,32,1,11,1,32,1,11,1,32,1,11,1,32,7,5,1,44,1,44,1,44,1,36,9,36,1,22,9,13,1,22,1,7,1,13,1,20,13,9,7,16,1,1,1,7,1,1,1,9,1,1,1,3,1,10,5,1,1,1,1,7,1,1,1,9,1,1,1,3,1,10,1,3,1,1,1,1,1,7,1,1,1,9,1,1,1,3,1,6,13,7,1,1,1,3,5,1,1,1,5,6,1,3,1,3,1,1,1,9,1,1,1,3,1,3,1,1,1,12,1,3,7,9,13,12,1,7,1,13,1,3,1,3,1,14,1,7,1,13,9,14,1,7,1,17,1,18,9,17,7,44,1,44,1,44,1,42,9,38,1,5,1,38,1,5,1,38,1,5,1,38,1,5,1,38,1,5,1,38,1,5,1,38,1,5,1,38,7,6];



theRobot = Robot.new(theProgram);
theRobot.run();




