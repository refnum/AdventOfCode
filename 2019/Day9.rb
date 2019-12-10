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

		@name		= theName.dup;
		@logging	= false;

		@memory		= theProgram.dup;
		@inputs		= theInputs.dup;
		@outputs	= [];

		@pc			= 0;
		@reg_rel	= 0;

	end



	#==========================================================================
	#		addInput : Add an input.
	#--------------------------------------------------------------------------
	def addInput(theValue)

		putLog("addInput(#{theValue})");
		@inputs << theValue;

	end



	#==========================================================================
	#		getOutput : Get the last output.
	#--------------------------------------------------------------------------
	def getOutput

		putLog("getOutput() -> (#{@outputs.last})");
	
		if (@outputs.empty?)
			abort("Can't get output from empty #{@name}!");
		else
			return @outputs.shift;
		end

	end



	#==========================================================================
	#		getOutputs : Get the outputs.
	#--------------------------------------------------------------------------
	def getOutputs

		putLog("getOutputs() -> (#{@outputs})");
	
		return @outputs;

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

		return (opCode != :OP_HALT);

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

		if (@inputs.empty?)
			print "Input: ";
			theValue = gets.chomp.to_i;
		else
			theValue = @inputs.shift;
		end
	
		return theValue;

	end



	#==========================================================================
	#		storeOutput : Store an output.
	#--------------------------------------------------------------------------
	def storeOutput(theValue)

		@outputs << theValue;

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




# Part One
#theProgram = [1002,4,3,4,33];
#theProgram=[3,9,8,9,10,9,4,9,99,-1,8];

#theProgram  = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99];
#theProgram = [1102,34915192,34915192,7,4,7,99,0];
#theProgram = [104,1125899906842624,99];

theProgram = [1102,34463338,34463338,63,1007,63,34463338,63,1005,63,53,1102,1,3,1000,109,988,209,12,9,1000,209,6,209,3,203,0,1008,1000,1,63,1005,63,65,1008,1000,2,63,1005,63,904,1008,1000,0,63,1005,63,58,4,25,104,0,99,4,0,104,0,99,4,17,104,0,99,0,0,1102,1,21,1004,1101,28,0,1016,1101,0,27,1010,1102,36,1,1008,1102,33,1,1013,1101,0,22,1012,1101,0,37,1011,1102,34,1,1017,1102,466,1,1027,1102,1,484,1029,1102,1,699,1024,1102,1,1,1021,1101,0,0,1020,1102,1,24,1015,1101,0,473,1026,1101,653,0,1022,1102,26,1,1007,1102,25,1,1006,1101,0,39,1014,1102,646,1,1023,1101,690,0,1025,1102,1,29,1019,1101,32,0,1018,1101,30,0,1002,1101,0,20,1001,1102,1,38,1005,1102,1,23,1003,1101,0,31,1000,1101,35,0,1009,1101,0,493,1028,109,5,1208,0,37,63,1005,63,201,1001,64,1,64,1106,0,203,4,187,1002,64,2,64,109,-4,2107,36,8,63,1005,63,223,1001,64,1,64,1105,1,225,4,209,1002,64,2,64,109,18,21107,40,41,-9,1005,1010,243,4,231,1105,1,247,1001,64,1,64,1002,64,2,64,109,6,21107,41,40,-9,1005,1016,267,1001,64,1,64,1106,0,269,4,253,1002,64,2,64,109,-19,21102,42,1,5,1008,1011,42,63,1005,63,291,4,275,1105,1,295,1001,64,1,64,1002,64,2,64,109,15,1205,0,309,4,301,1105,1,313,1001,64,1,64,1002,64,2,64,109,-27,2101,0,9,63,1008,63,20,63,1005,63,333,1106,0,339,4,319,1001,64,1,64,1002,64,2,64,109,19,21102,43,1,6,1008,1019,45,63,1005,63,363,1001,64,1,64,1105,1,365,4,345,1002,64,2,64,109,1,21108,44,47,-3,1005,1011,385,1001,64,1,64,1106,0,387,4,371,1002,64,2,64,109,-22,1201,9,0,63,1008,63,21,63,1005,63,411,1001,64,1,64,1106,0,413,4,393,1002,64,2,64,109,9,1207,0,19,63,1005,63,433,1001,64,1,64,1106,0,435,4,419,1002,64,2,64,109,-9,2107,30,8,63,1005,63,453,4,441,1105,1,457,1001,64,1,64,1002,64,2,64,109,25,2106,0,10,1001,64,1,64,1106,0,475,4,463,1002,64,2,64,109,11,2106,0,0,4,481,1001,64,1,64,1105,1,493,1002,64,2,64,109,-18,2108,21,-6,63,1005,63,511,4,499,1106,0,515,1001,64,1,64,1002,64,2,64,109,-12,2108,18,6,63,1005,63,535,1001,64,1,64,1106,0,537,4,521,1002,64,2,64,109,19,21101,45,0,-7,1008,1010,45,63,1005,63,563,4,543,1001,64,1,64,1105,1,563,1002,64,2,64,109,-10,1207,-5,31,63,1005,63,581,4,569,1106,0,585,1001,64,1,64,1002,64,2,64,109,-8,2102,1,5,63,1008,63,21,63,1005,63,611,4,591,1001,64,1,64,1105,1,611,1002,64,2,64,109,5,1201,0,0,63,1008,63,21,63,1005,63,633,4,617,1106,0,637,1001,64,1,64,1002,64,2,64,109,13,2105,1,6,1001,64,1,64,1106,0,655,4,643,1002,64,2,64,109,-7,1202,-3,1,63,1008,63,26,63,1005,63,681,4,661,1001,64,1,64,1106,0,681,1002,64,2,64,109,12,2105,1,2,4,687,1001,64,1,64,1105,1,699,1002,64,2,64,109,-28,1208,8,30,63,1005,63,717,4,705,1106,0,721,1001,64,1,64,1002,64,2,64,109,10,1202,1,1,63,1008,63,40,63,1005,63,745,1001,64,1,64,1105,1,747,4,727,1002,64,2,64,109,10,21108,46,46,-2,1005,1012,765,4,753,1105,1,769,1001,64,1,64,1002,64,2,64,109,-2,1205,8,781,1106,0,787,4,775,1001,64,1,64,1002,64,2,64,109,-9,2101,0,0,63,1008,63,23,63,1005,63,809,4,793,1105,1,813,1001,64,1,64,1002,64,2,64,109,9,1206,8,831,4,819,1001,64,1,64,1106,0,831,1002,64,2,64,109,-9,2102,1,-2,63,1008,63,22,63,1005,63,855,1001,64,1,64,1106,0,857,4,837,1002,64,2,64,109,4,21101,47,0,10,1008,1017,50,63,1005,63,877,1105,1,883,4,863,1001,64,1,64,1002,64,2,64,109,18,1206,-4,895,1105,1,901,4,889,1001,64,1,64,4,64,99,21101,0,27,1,21102,915,1,0,1106,0,922,21201,1,56639,1,204,1,99,109,3,1207,-2,3,63,1005,63,964,21201,-2,-1,1,21102,1,942,0,1106,0,922,22102,1,1,-1,21201,-2,-3,1,21101,0,957,0,1106,0,922,22201,1,-1,-2,1106,0,968,22102,1,-2,-2,109,-3,2106,0,0];

theVM = IntcodeVM.new("A", theProgram, [1]);


# Part Two
theVM = IntcodeVM.new("A", theProgram, [2]);



theVM.execute();
puts theVM.getOutputs().join(', ');


