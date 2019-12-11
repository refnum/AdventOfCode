#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		Day9.rb
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
	DIRECTION =
	[
		:UP,
		:DOWN,
		:LEFT,
		:RIGHT
	];

	TURN =
	[
		:LEFT,
		:RIGHT
	];



	#==========================================================================
	#		initialize : Initialiser.
	#--------------------------------------------------------------------------
	def initialize(theProgram)

		@vm      = IntcodeVM.new("Robot", theProgram);
		@logging = false;

		@direction = :UP;
		@newOutput = true;
		@position  = Point.new();
		@painted   = Hash.new();
		
		
		# Part two
		setColour(@position, 1);

	end



	#==========================================================================
	#		paint : Paint the ship.
	#--------------------------------------------------------------------------
	def paint
	
		@vm.setInputOutput(method(:robotInput), method(:robotOutput));
		@vm.execute();
		
		putMap();
	
	end



	#==========================================================================
	#		putMap : Print the map.
	#--------------------------------------------------------------------------
	def putMap
	
	
		# Print the stats
		puts "Map was painted #{@painted.size} times";



		# Find the bounds
		boundsMin = Point.new;
		boundsMax = Point.new;
				
		@painted.each_key do |thePoint|
		
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
		boundsMax.y.downto(boundsMin.y) do |y|
			boundsMin.x.upto(boundsMax.x) do |x|
			
				theColour = getColour(Point.new(x, y), -1);
				case theColour
				when -1
					print '⬛️';

				when 0
					print '️⬛️';

				when 1
					print '⬜️';
				
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
	#		robotInput : Provide input for the robot.
	#--------------------------------------------------------------------------
	def robotInput

		theValue = getColour(@position);
		trace("robotInput() -> #{theValue}");

		return theValue;
	
	end



	#==========================================================================
	#		robotOutput : Receive output from the robot.
	#--------------------------------------------------------------------------
	def robotOutput(theValue)

		trace("robotOutput((#{theValue}), is #{@newOutput ? "colour" : "turn"}");

		# First output is colour
		if (@newOutput)
			setColour(@position, theValue);
			@newOutput = false;
		
		
		# Second output is turn
		else
			setDirection(theValue);
			moveForward();
			@newOutput = true;
		end

	end



	#==========================================================================
	#		getColour : Get the colour at a point.
	#--------------------------------------------------------------------------
	def getColour(thePoint, defaultValue=0)

		if (@painted.has_key?(thePoint))
			theColour = @painted[thePoint];
		else
			theColour = defaultValue;
		end

		trace("getColour(#{thePoint}) -> #{theColour}");

		return theColour;

	end



	#==========================================================================
	#		setColour : Set the colour at a point.
	#--------------------------------------------------------------------------
	def setColour(thePoint, theColour)

		trace("setColour(#{thePoint}, #{theColour})");

		@painted[thePoint.dup] = theColour;

	end



	#==========================================================================
	#		setDirection : Set the direction.
	#--------------------------------------------------------------------------
	def setDirection(turnTo)

		# Get the state we need
		oldDirection = @direction;
		theTurn      = TURN[turnTo];
		
		if (theTurn == :LEFT)

			case @direction
			when :UP
				@direction = :LEFT;

			when :DOWN
				@direction = :RIGHT;

			when :LEFT
				@direction = :DOWN;

			when :RIGHT
				@direction = :UP;
			end
		
		elsif (theTurn == :RIGHT)

			case @direction
			when :UP
				@direction = :RIGHT;

			when :DOWN
				@direction = :LEFT;

			when :LEFT
				@direction = :UP;

			when :RIGHT
				@direction = :DOWN;
			end
		
		else
			abort("Unknown turn '#{turnTo}'");
		end

		trace("setDirection(#{theTurn}), #{oldDirection} -> #{@direction}");

	end



	#==========================================================================
	#		moveForward : Move forwards.
	#--------------------------------------------------------------------------
	def moveForward

		oldPosition = @position;
		 
		case @direction
		when :UP
			@position.y += 1;

		when :DOWN
			@position.y -= 1;

		when :LEFT
			@position.x -= 1;

		when :RIGHT
			@position.x += 1;
		
		else
			abort("Unknown direction #{theDirection}");
		end

		trace("moveForward(), #{oldPosition} -> #{@position}");

	end

end







# Part One
theProgram = [3,8,1005,8,311,1106,0,11,0,0,0,104,1,104,0,3,8,102,-1,8,10,1001,10,1,10,4,10,1008,8,0,10,4,10,1002,8,1,29,3,8,102,-1,8,10,1001,10,1,10,4,10,108,0,8,10,4,10,101,0,8,50,1,2,19,10,1006,0,23,1,103,14,10,1,1106,15,10,3,8,1002,8,-1,10,1001,10,1,10,4,10,1008,8,1,10,4,10,102,1,8,88,1006,0,59,3,8,1002,8,-1,10,101,1,10,10,4,10,1008,8,1,10,4,10,1002,8,1,113,2,101,12,10,2,1001,0,10,2,1006,14,10,3,8,1002,8,-1,10,101,1,10,10,4,10,108,0,8,10,4,10,102,1,8,146,1,1106,11,10,1006,0,2,1,9,8,10,3,8,1002,8,-1,10,1001,10,1,10,4,10,1008,8,1,10,4,10,101,0,8,180,1,6,13,10,1,1102,15,10,2,7,1,10,3,8,1002,8,-1,10,1001,10,1,10,4,10,108,0,8,10,4,10,1002,8,1,213,1006,0,74,2,1005,9,10,3,8,1002,8,-1,10,101,1,10,10,4,10,1008,8,0,10,4,10,1002,8,1,243,3,8,1002,8,-1,10,101,1,10,10,4,10,108,1,8,10,4,10,101,0,8,264,2,104,8,10,3,8,1002,8,-1,10,1001,10,1,10,4,10,108,1,8,10,4,10,1001,8,0,290,101,1,9,9,1007,9,952,10,1005,10,15,99,109,633,104,0,104,1,21101,387512640296,0,1,21101,0,328,0,1106,0,432,21102,1,665749660564,1,21101,339,0,0,1106,0,432,3,10,104,0,104,1,3,10,104,0,104,0,3,10,104,0,104,1,3,10,104,0,104,1,3,10,104,0,104,0,3,10,104,0,104,1,21102,179318226984,1,1,21101,386,0,0,1105,1,432,21101,46266346499,0,1,21101,0,397,0,1105,1,432,3,10,104,0,104,0,3,10,104,0,104,0,21102,709580555028,1,1,21102,420,1,0,1106,0,432,21102,1,988220642068,1,21101,0,431,0,1106,0,432,99,109,2,21202,-1,1,1,21101,40,0,2,21102,1,463,3,21102,1,453,0,1106,0,496,109,-2,2106,0,0,0,1,0,0,1,109,2,3,10,204,-1,1001,458,459,474,4,0,1001,458,1,458,108,4,458,10,1006,10,490,1102,0,1,458,109,-2,2105,1,0,0,109,4,2102,1,-1,495,1207,-3,0,10,1006,10,513,21101,0,0,-3,21201,-3,0,1,22101,0,-2,2,21102,1,1,3,21101,532,0,0,1106,0,537,109,-4,2106,0,0,109,5,1207,-3,1,10,1006,10,560,2207,-4,-2,10,1006,10,560,22102,1,-4,-4,1105,1,628,21201,-4,0,1,21201,-3,-1,2,21202,-2,2,3,21102,1,579,0,1105,1,537,22101,0,1,-4,21101,1,0,-1,2207,-4,-2,10,1006,10,598,21101,0,0,-1,22202,-2,-1,-2,2107,0,-3,10,1006,10,620,22101,0,-1,1,21102,620,1,0,106,0,495,21202,-2,-1,-2,22201,-4,-2,-4,109,-5,2105,1,0];

theRobot = Robot.new(theProgram);
theRobot.paint();


