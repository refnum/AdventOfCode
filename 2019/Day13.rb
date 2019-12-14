#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		Day13.rb
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
require 'io/console'





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
		return self == otherPoint;
	end
	
	def hash
		return [@x, @y].hash;
	end

end





#==============================================================================
#		Game : Arcade game virtual machine.
#------------------------------------------------------------------------------
class Game

	#==========================================================================
	#		Constants
	#--------------------------------------------------------------------------
	TILE_OUTSIDE	= -1;
	TILE_EMPTY		= 0;
	TILE_WALL		= 1;
	TILE_BLOCK		= 2;
	TILE_PADDLE		= 3;
	TILE_BALL		= 4;
	
	MOVE_NONE		= 0;
	MOVE_LEFT		= -1;
	MOVE_RIGHT		= 1;
	
	POS_SCORE		= Point.new(-1, 0);

	ANSI_CLEAR		= "\e[2J\e[f";



	#==========================================================================
	#		initialize : Initialiser.
	#--------------------------------------------------------------------------
	def initialize(theProgram)

		@vm      = IntcodeVM.new("Game", theProgram);
		@logging = false;

		@outputs = [];
		@score   = 0;
		@screen  = Hash.new();

	end



	#==========================================================================
	#		run : Run the game.
	#--------------------------------------------------------------------------
	def run
	
		@vm.setInputOutput(method(:gameInput), method(:gameOutput));
		@vm.execute();


		# Part one
		putScreen();
		puts "Screen contains #{@screen.values.count(TILE_BLOCK)} blocks.";
		
	end



	#==========================================================================
	#		putScreen : Print the screen.
	#--------------------------------------------------------------------------
	def putScreen(clearScreen = false)
	
	
		# Find the bounds
		boundsMin = Point.new;
		boundsMax = Point.new;
				
		@screen.each_key do |thePoint|
		
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



		# Print the screen
		if (clearScreen)
			puts ANSI_CLEAR;
		end
	
		puts "Score: #{@score}";

		boundsMax.y.downto(boundsMin.y) do |y|
			boundsMin.x.upto(boundsMax.x) do |x|
			
				theTile = getTile(Point.new(x, y), TILE_OUTSIDE);
				case theTile
				when TILE_OUTSIDE
					print ' ';

				when TILE_EMPTY
					print ' ';

				when TILE_WALL
					print '+';

				when TILE_BLOCK
					print '@';

				when TILE_PADDLE
					print '=';

				when TILE_BALL
					print 'o';
				
				end
			end

			puts "";
		end

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
	#		getChar : Get a character.
	#--------------------------------------------------------------------------
	def getChar

		state = `stty -g`
		`stty raw -echo -icanon isig`
		theChar = STDIN.read_nonblock(1) rescue nil
#		theChar = STDIN.getc.chr;
		`stty #{state}`
		
		return theChar;

	end



	#==========================================================================
	#		gameInput : Provide input for the game.
	#--------------------------------------------------------------------------
	def gameInput

		putScreen(true);
		theChar = getChar();
		
		case theChar
		when 'a'
			return -1
		
		when 'd'
			return 1
		
		else
			return 0
		end
	
	end



	#==========================================================================
	#		gameOutput : Receive output from the game.
	#--------------------------------------------------------------------------
	def gameOutput(theValue)

		trace("gameOutput((#{theValue})");
		
		@outputs << theValue;
		
		if (@outputs.size == 3)
			thePoint = Point.new(@outputs[0], @outputs[1]);
			theValue = @outputs[2];

			if (thePoint == POS_SCORE)
				setScore(theValue);
			else
				setTile(thePoint, theValue);
			end

			@outputs.clear;
		end

	end



	#==========================================================================
	#		getTile : Get the tile at a point.
	#--------------------------------------------------------------------------
	def getTile(thePoint, defaultValue=0)

		if (@screen.has_key?(thePoint))
			theTile = @screen[thePoint];
		else
			theTile = defaultValue;
		end

		trace("getTile(#{thePoint}) -> #{theTile}");

		return theTile;

	end



	#==========================================================================
	#		setTile : Set the tile at a point.
	#--------------------------------------------------------------------------
	def setTile(thePoint, theTile)

		trace("setTile(#{thePoint}, #{theTile})");

		@screen[thePoint.dup] = theTile;

	end



	#==========================================================================
	#		setScore : Set the score.
	#--------------------------------------------------------------------------
	def setScore(theScore)

		trace("setScore(#{theScore})");

		@score = theScore;

	end

end





# Part One
theProgram = [1,380,379,385,1008,2415,504308,381,1005,381,12,99,109,2416,1101,0,0,383,1102,1,0,382,20101,0,382,1,20102,1,383,2,21102,1,37,0,1106,0,578,4,382,4,383,204,1,1001,382,1,382,1007,382,37,381,1005,381,22,1001,383,1,383,1007,383,24,381,1005,381,18,1006,385,69,99,104,-1,104,0,4,386,3,384,1007,384,0,381,1005,381,94,107,0,384,381,1005,381,108,1105,1,161,107,1,392,381,1006,381,161,1101,-1,0,384,1105,1,119,1007,392,35,381,1006,381,161,1101,0,1,384,20102,1,392,1,21102,22,1,2,21102,1,0,3,21101,0,138,0,1106,0,549,1,392,384,392,21002,392,1,1,21102,1,22,2,21102,1,3,3,21102,1,161,0,1105,1,549,1102,0,1,384,20001,388,390,1,20101,0,389,2,21101,0,180,0,1106,0,578,1206,1,213,1208,1,2,381,1006,381,205,20001,388,390,1,21002,389,1,2,21102,205,1,0,1105,1,393,1002,390,-1,390,1102,1,1,384,21002,388,1,1,20001,389,391,2,21102,228,1,0,1106,0,578,1206,1,261,1208,1,2,381,1006,381,253,20101,0,388,1,20001,389,391,2,21101,253,0,0,1105,1,393,1002,391,-1,391,1102,1,1,384,1005,384,161,20001,388,390,1,20001,389,391,2,21101,279,0,0,1106,0,578,1206,1,316,1208,1,2,381,1006,381,304,20001,388,390,1,20001,389,391,2,21101,0,304,0,1106,0,393,1002,390,-1,390,1002,391,-1,391,1102,1,1,384,1005,384,161,21001,388,0,1,21001,389,0,2,21101,0,0,3,21102,1,338,0,1105,1,549,1,388,390,388,1,389,391,389,20102,1,388,1,20102,1,389,2,21101,0,4,3,21101,0,365,0,1105,1,549,1007,389,23,381,1005,381,75,104,-1,104,0,104,0,99,0,1,0,0,0,0,0,0,286,16,19,1,1,18,109,3,22102,1,-2,1,22102,1,-1,2,21101,0,0,3,21101,0,414,0,1106,0,549,21202,-2,1,1,22101,0,-1,2,21102,429,1,0,1105,1,601,2101,0,1,435,1,386,0,386,104,-1,104,0,4,386,1001,387,-1,387,1005,387,451,99,109,-3,2106,0,0,109,8,22202,-7,-6,-3,22201,-3,-5,-3,21202,-4,64,-2,2207,-3,-2,381,1005,381,492,21202,-2,-1,-1,22201,-3,-1,-3,2207,-3,-2,381,1006,381,481,21202,-4,8,-2,2207,-3,-2,381,1005,381,518,21202,-2,-1,-1,22201,-3,-1,-3,2207,-3,-2,381,1006,381,507,2207,-3,-4,381,1005,381,540,21202,-4,-1,-1,22201,-3,-1,-3,2207,-3,-4,381,1006,381,529,21201,-3,0,-7,109,-8,2105,1,0,109,4,1202,-2,37,566,201,-3,566,566,101,639,566,566,2102,1,-1,0,204,-3,204,-2,204,-1,109,-4,2106,0,0,109,3,1202,-1,37,594,201,-2,594,594,101,639,594,594,20101,0,0,-2,109,-3,2106,0,0,109,3,22102,24,-2,1,22201,1,-1,1,21101,449,0,2,21102,721,1,3,21101,888,0,4,21102,1,630,0,1105,1,456,21201,1,1527,-2,109,-3,2106,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,2,2,0,2,2,2,0,2,2,2,0,2,2,2,2,0,0,2,2,0,2,0,0,2,0,2,2,2,2,0,2,0,0,1,1,0,0,2,0,0,0,2,0,2,2,0,0,0,2,2,2,0,0,0,2,2,2,0,2,2,0,0,0,0,0,0,0,2,0,0,1,1,0,0,2,0,2,0,2,0,2,0,2,2,0,2,0,2,0,2,2,2,0,0,2,2,2,0,2,0,2,2,2,2,0,0,0,1,1,0,0,2,0,0,0,0,2,0,0,0,2,0,0,2,2,2,2,2,2,2,0,0,0,0,2,2,2,2,2,0,2,2,2,0,1,1,0,2,2,2,0,0,2,2,2,2,2,2,0,2,0,0,0,2,0,0,2,2,2,0,2,0,2,0,2,0,0,2,2,2,0,1,1,0,0,2,2,2,2,0,2,0,2,0,0,2,0,2,2,2,2,2,0,2,0,2,2,0,2,0,2,2,2,0,2,2,0,0,1,1,0,0,0,0,2,2,2,2,2,0,0,2,0,0,0,0,2,0,2,2,0,2,2,2,2,2,0,2,2,0,0,0,2,2,0,1,1,0,2,0,2,2,2,0,0,0,0,0,0,0,2,2,2,2,2,2,2,0,2,0,2,2,0,2,0,2,0,0,0,0,0,0,1,1,0,0,0,2,2,0,0,2,0,0,2,2,2,2,2,0,0,2,2,2,2,0,2,0,0,0,2,2,2,0,2,2,2,2,0,1,1,0,0,0,0,0,2,0,2,2,2,0,0,2,2,2,0,2,2,2,0,0,2,2,0,2,2,2,2,0,0,2,2,2,0,0,1,1,0,0,2,0,2,2,2,2,0,0,0,0,2,0,0,0,2,0,0,0,0,2,0,0,0,0,2,2,0,0,0,2,2,2,0,1,1,0,0,2,0,2,2,2,2,0,0,0,0,0,2,2,2,2,2,2,0,0,2,2,0,2,0,0,2,2,2,2,2,2,0,0,1,1,0,0,2,0,2,0,0,0,0,0,0,2,0,0,0,0,0,0,0,2,2,2,2,0,2,0,2,2,2,2,0,2,0,2,0,1,1,0,0,2,2,2,0,2,2,2,2,0,2,0,2,0,2,0,0,0,0,0,0,2,2,0,2,2,2,2,0,0,2,2,0,0,1,1,0,0,0,2,0,2,2,2,0,0,2,2,2,0,2,0,0,2,2,2,0,2,0,2,2,0,2,2,2,2,0,0,0,0,0,1,1,0,2,2,0,2,2,0,2,0,2,2,2,2,0,2,2,0,2,2,2,0,2,0,0,0,2,0,2,0,0,0,0,0,2,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,72,24,61,53,70,95,17,71,27,25,75,75,9,41,47,87,93,47,92,11,93,87,16,9,94,89,5,46,23,64,39,44,23,93,27,28,10,82,54,70,26,84,86,88,64,20,6,8,8,27,46,80,6,57,15,35,55,86,30,72,88,50,49,11,31,76,89,50,24,13,71,45,35,46,57,14,84,36,1,41,48,87,67,92,83,28,41,7,33,60,66,16,46,42,49,47,53,27,60,84,63,32,23,17,67,61,56,7,31,68,43,50,37,36,56,6,65,35,9,56,15,32,64,68,7,52,30,15,55,71,57,97,31,60,37,35,85,96,59,14,83,76,47,71,65,39,37,22,77,90,60,38,29,72,11,49,40,20,26,19,80,83,58,67,50,94,79,62,86,57,76,44,36,37,55,67,6,26,34,63,80,33,64,45,39,93,70,26,4,71,79,71,21,70,31,48,58,50,54,74,53,31,89,78,57,70,52,70,85,68,5,1,55,12,25,74,81,36,3,3,8,97,9,62,58,80,45,87,45,17,80,62,25,63,29,97,84,55,11,28,86,55,39,81,93,48,67,46,62,79,58,63,87,66,89,23,81,95,22,41,29,87,30,14,67,94,13,7,32,56,66,29,89,77,17,54,12,82,59,83,89,65,72,56,78,97,5,24,20,27,5,37,66,68,77,16,9,66,41,43,18,94,84,86,42,25,47,72,7,8,93,28,68,6,75,55,44,36,15,71,9,49,66,80,77,81,13,7,73,1,86,17,80,36,12,57,42,1,50,87,74,37,60,91,92,46,75,1,17,83,65,49,61,44,13,69,36,90,10,35,61,53,66,11,62,33,14,58,24,82,11,68,48,20,96,68,56,57,77,71,24,41,46,81,43,55,96,30,69,63,23,86,55,83,1,23,88,88,20,66,39,23,26,2,21,80,57,68,3,88,68,1,76,67,84,63,89,45,84,20,97,29,97,7,92,84,65,49,31,93,63,30,89,96,93,37,15,97,30,69,39,1,22,68,5,75,38,39,62,19,24,30,38,36,27,93,1,3,27,39,69,3,86,42,92,81,18,37,16,94,1,94,47,81,51,25,11,6,25,28,78,50,89,39,6,41,27,31,22,17,33,76,2,36,64,79,14,81,91,11,45,12,17,57,70,17,49,54,45,83,71,68,25,89,62,4,55,73,77,98,1,1,36,11,12,78,56,71,96,55,85,71,49,57,68,14,76,63,22,60,79,11,61,49,39,36,33,59,73,85,8,38,3,21,65,21,31,69,54,85,38,26,5,73,43,87,15,44,80,10,92,54,75,96,26,53,84,37,1,76,53,77,68,13,67,64,11,31,32,86,85,71,98,37,53,45,3,3,87,20,20,36,95,87,41,74,23,76,78,19,45,57,41,89,1,11,42,85,74,13,3,72,19,20,64,25,51,82,97,45,55,37,86,2,25,40,26,78,76,16,11,14,36,96,89,90,64,96,79,32,17,47,79,80,53,19,26,59,74,54,53,58,32,48,9,64,96,3,20,88,1,92,44,45,10,4,67,91,81,26,40,89,83,53,83,84,18,53,6,94,51,59,27,38,41,63,2,8,48,64,4,90,88,21,14,37,68,46,1,73,21,14,41,65,81,97,56,90,24,30,81,68,19,16,47,65,53,68,26,54,26,56,15,25,83,89,20,92,4,49,37,42,5,54,7,27,43,36,85,41,59,44,33,93,45,46,23,19,52,20,87,25,85,21,22,20,43,70,35,33,27,17,23,9,56,33,53,55,22,91,69,73,20,23,86,95,14,24,59,60,37,48,94,69,86,63,39,50,84,85,46,65,4,42,97,12,66,37,89,47,29,59,25,47,74,44,24,22,73,45,60,70,11,40,83,49,95,17,9,85,2,27,90,60,32,87,62,36,91,38,19,92,2,33,30,17,43,13,81,53,93,75,14,67,97,95,53,20,63,5,45,63,84,92,65,65,70,33,11,79,82,89,36,59,90,74,6,74,17,96,40,72,89,84,51,17,40,42,504308];

# Part TWo
theProgram = [2,380,379,385,1008,2415,504308,381,1005,381,12,99,109,2416,1101,0,0,383,1102,1,0,382,20101,0,382,1,20102,1,383,2,21102,1,37,0,1106,0,578,4,382,4,383,204,1,1001,382,1,382,1007,382,37,381,1005,381,22,1001,383,1,383,1007,383,24,381,1005,381,18,1006,385,69,99,104,-1,104,0,4,386,3,384,1007,384,0,381,1005,381,94,107,0,384,381,1005,381,108,1105,1,161,107,1,392,381,1006,381,161,1101,-1,0,384,1105,1,119,1007,392,35,381,1006,381,161,1101,0,1,384,20102,1,392,1,21102,22,1,2,21102,1,0,3,21101,0,138,0,1106,0,549,1,392,384,392,21002,392,1,1,21102,1,22,2,21102,1,3,3,21102,1,161,0,1105,1,549,1102,0,1,384,20001,388,390,1,20101,0,389,2,21101,0,180,0,1106,0,578,1206,1,213,1208,1,2,381,1006,381,205,20001,388,390,1,21002,389,1,2,21102,205,1,0,1105,1,393,1002,390,-1,390,1102,1,1,384,21002,388,1,1,20001,389,391,2,21102,228,1,0,1106,0,578,1206,1,261,1208,1,2,381,1006,381,253,20101,0,388,1,20001,389,391,2,21101,253,0,0,1105,1,393,1002,391,-1,391,1102,1,1,384,1005,384,161,20001,388,390,1,20001,389,391,2,21101,279,0,0,1106,0,578,1206,1,316,1208,1,2,381,1006,381,304,20001,388,390,1,20001,389,391,2,21101,0,304,0,1106,0,393,1002,390,-1,390,1002,391,-1,391,1102,1,1,384,1005,384,161,21001,388,0,1,21001,389,0,2,21101,0,0,3,21102,1,338,0,1105,1,549,1,388,390,388,1,389,391,389,20102,1,388,1,20102,1,389,2,21101,0,4,3,21101,0,365,0,1105,1,549,1007,389,23,381,1005,381,75,104,-1,104,0,104,0,99,0,1,0,0,0,0,0,0,286,16,19,1,1,18,109,3,22102,1,-2,1,22102,1,-1,2,21101,0,0,3,21101,0,414,0,1106,0,549,21202,-2,1,1,22101,0,-1,2,21102,429,1,0,1105,1,601,2101,0,1,435,1,386,0,386,104,-1,104,0,4,386,1001,387,-1,387,1005,387,451,99,109,-3,2106,0,0,109,8,22202,-7,-6,-3,22201,-3,-5,-3,21202,-4,64,-2,2207,-3,-2,381,1005,381,492,21202,-2,-1,-1,22201,-3,-1,-3,2207,-3,-2,381,1006,381,481,21202,-4,8,-2,2207,-3,-2,381,1005,381,518,21202,-2,-1,-1,22201,-3,-1,-3,2207,-3,-2,381,1006,381,507,2207,-3,-4,381,1005,381,540,21202,-4,-1,-1,22201,-3,-1,-3,2207,-3,-4,381,1006,381,529,21201,-3,0,-7,109,-8,2105,1,0,109,4,1202,-2,37,566,201,-3,566,566,101,639,566,566,2102,1,-1,0,204,-3,204,-2,204,-1,109,-4,2106,0,0,109,3,1202,-1,37,594,201,-2,594,594,101,639,594,594,20101,0,0,-2,109,-3,2106,0,0,109,3,22102,24,-2,1,22201,1,-1,1,21101,449,0,2,21102,721,1,3,21101,888,0,4,21102,1,630,0,1105,1,456,21201,1,1527,-2,109,-3,2106,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,2,2,0,2,2,2,0,2,2,2,0,2,2,2,2,0,0,2,2,0,2,0,0,2,0,2,2,2,2,0,2,0,0,1,1,0,0,2,0,0,0,2,0,2,2,0,0,0,2,2,2,0,0,0,2,2,2,0,2,2,0,0,0,0,0,0,0,2,0,0,1,1,0,0,2,0,2,0,2,0,2,0,2,2,0,2,0,2,0,2,2,2,0,0,2,2,2,0,2,0,2,2,2,2,0,0,0,1,1,0,0,2,0,0,0,0,2,0,0,0,2,0,0,2,2,2,2,2,2,2,0,0,0,0,2,2,2,2,2,0,2,2,2,0,1,1,0,2,2,2,0,0,2,2,2,2,2,2,0,2,0,0,0,2,0,0,2,2,2,0,2,0,2,0,2,0,0,2,2,2,0,1,1,0,0,2,2,2,2,0,2,0,2,0,0,2,0,2,2,2,2,2,0,2,0,2,2,0,2,0,2,2,2,0,2,2,0,0,1,1,0,0,0,0,2,2,2,2,2,0,0,2,0,0,0,0,2,0,2,2,0,2,2,2,2,2,0,2,2,0,0,0,2,2,0,1,1,0,2,0,2,2,2,0,0,0,0,0,0,0,2,2,2,2,2,2,2,0,2,0,2,2,0,2,0,2,0,0,0,0,0,0,1,1,0,0,0,2,2,0,0,2,0,0,2,2,2,2,2,0,0,2,2,2,2,0,2,0,0,0,2,2,2,0,2,2,2,2,0,1,1,0,0,0,0,0,2,0,2,2,2,0,0,2,2,2,0,2,2,2,0,0,2,2,0,2,2,2,2,0,0,2,2,2,0,0,1,1,0,0,2,0,2,2,2,2,0,0,0,0,2,0,0,0,2,0,0,0,0,2,0,0,0,0,2,2,0,0,0,2,2,2,0,1,1,0,0,2,0,2,2,2,2,0,0,0,0,0,2,2,2,2,2,2,0,0,2,2,0,2,0,0,2,2,2,2,2,2,0,0,1,1,0,0,2,0,2,0,0,0,0,0,0,2,0,0,0,0,0,0,0,2,2,2,2,0,2,0,2,2,2,2,0,2,0,2,0,1,1,0,0,2,2,2,0,2,2,2,2,0,2,0,2,0,2,0,0,0,0,0,0,2,2,0,2,2,2,2,0,0,2,2,0,0,1,1,0,0,0,2,0,2,2,2,0,0,2,2,2,0,2,0,0,2,2,2,0,2,0,2,2,0,2,2,2,2,0,0,0,0,0,1,1,0,2,2,0,2,2,0,2,0,2,2,2,2,0,2,2,0,2,2,2,0,2,0,0,0,2,0,2,0,0,0,0,0,2,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,72,24,61,53,70,95,17,71,27,25,75,75,9,41,47,87,93,47,92,11,93,87,16,9,94,89,5,46,23,64,39,44,23,93,27,28,10,82,54,70,26,84,86,88,64,20,6,8,8,27,46,80,6,57,15,35,55,86,30,72,88,50,49,11,31,76,89,50,24,13,71,45,35,46,57,14,84,36,1,41,48,87,67,92,83,28,41,7,33,60,66,16,46,42,49,47,53,27,60,84,63,32,23,17,67,61,56,7,31,68,43,50,37,36,56,6,65,35,9,56,15,32,64,68,7,52,30,15,55,71,57,97,31,60,37,35,85,96,59,14,83,76,47,71,65,39,37,22,77,90,60,38,29,72,11,49,40,20,26,19,80,83,58,67,50,94,79,62,86,57,76,44,36,37,55,67,6,26,34,63,80,33,64,45,39,93,70,26,4,71,79,71,21,70,31,48,58,50,54,74,53,31,89,78,57,70,52,70,85,68,5,1,55,12,25,74,81,36,3,3,8,97,9,62,58,80,45,87,45,17,80,62,25,63,29,97,84,55,11,28,86,55,39,81,93,48,67,46,62,79,58,63,87,66,89,23,81,95,22,41,29,87,30,14,67,94,13,7,32,56,66,29,89,77,17,54,12,82,59,83,89,65,72,56,78,97,5,24,20,27,5,37,66,68,77,16,9,66,41,43,18,94,84,86,42,25,47,72,7,8,93,28,68,6,75,55,44,36,15,71,9,49,66,80,77,81,13,7,73,1,86,17,80,36,12,57,42,1,50,87,74,37,60,91,92,46,75,1,17,83,65,49,61,44,13,69,36,90,10,35,61,53,66,11,62,33,14,58,24,82,11,68,48,20,96,68,56,57,77,71,24,41,46,81,43,55,96,30,69,63,23,86,55,83,1,23,88,88,20,66,39,23,26,2,21,80,57,68,3,88,68,1,76,67,84,63,89,45,84,20,97,29,97,7,92,84,65,49,31,93,63,30,89,96,93,37,15,97,30,69,39,1,22,68,5,75,38,39,62,19,24,30,38,36,27,93,1,3,27,39,69,3,86,42,92,81,18,37,16,94,1,94,47,81,51,25,11,6,25,28,78,50,89,39,6,41,27,31,22,17,33,76,2,36,64,79,14,81,91,11,45,12,17,57,70,17,49,54,45,83,71,68,25,89,62,4,55,73,77,98,1,1,36,11,12,78,56,71,96,55,85,71,49,57,68,14,76,63,22,60,79,11,61,49,39,36,33,59,73,85,8,38,3,21,65,21,31,69,54,85,38,26,5,73,43,87,15,44,80,10,92,54,75,96,26,53,84,37,1,76,53,77,68,13,67,64,11,31,32,86,85,71,98,37,53,45,3,3,87,20,20,36,95,87,41,74,23,76,78,19,45,57,41,89,1,11,42,85,74,13,3,72,19,20,64,25,51,82,97,45,55,37,86,2,25,40,26,78,76,16,11,14,36,96,89,90,64,96,79,32,17,47,79,80,53,19,26,59,74,54,53,58,32,48,9,64,96,3,20,88,1,92,44,45,10,4,67,91,81,26,40,89,83,53,83,84,18,53,6,94,51,59,27,38,41,63,2,8,48,64,4,90,88,21,14,37,68,46,1,73,21,14,41,65,81,97,56,90,24,30,81,68,19,16,47,65,53,68,26,54,26,56,15,25,83,89,20,92,4,49,37,42,5,54,7,27,43,36,85,41,59,44,33,93,45,46,23,19,52,20,87,25,85,21,22,20,43,70,35,33,27,17,23,9,56,33,53,55,22,91,69,73,20,23,86,95,14,24,59,60,37,48,94,69,86,63,39,50,84,85,46,65,4,42,97,12,66,37,89,47,29,59,25,47,74,44,24,22,73,45,60,70,11,40,83,49,95,17,9,85,2,27,90,60,32,87,62,36,91,38,19,92,2,33,30,17,43,13,81,53,93,75,14,67,97,95,53,20,63,5,45,63,84,92,65,65,70,33,11,79,82,89,36,59,90,74,6,74,17,96,40,72,89,84,51,17,40,42,504308];


theGame = Game.new(theProgram);
theGame.run();


