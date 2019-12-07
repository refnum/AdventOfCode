#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		Day7.rb
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






OP_ADD				= 1;
OP_MULTIPLY			= 2;
OP_INPUT			= 3;
OP_OUTPUT			= 4;
OP_JUMP_IF_TRUE		= 5;
OP_JUMP_IF_FALSE	= 6;
OP_LESS_THAN		= 7;
OP_EQUALS			= 8;
OP_HALT				= 99;

MODE_POSITION		= 0;
MODE_IMMEDIATE		= 1;



class IntcodeVM

	def initialize(theName, theProgram, theInputs)
		@name    = theName.dup;
		@memory  = theProgram.dup;
		@pc      = 0;
		@inputs  = theInputs.dup;
		@outputs = [];
	end


	def addInput(theValue)
		putLog("addInput(#{theValue})");
		@inputs << theValue;
	end


	def getOutput
		putLog("getOutput() -> (#{@outputs.last})");
	
		if (@outputs.empty?)
			abort("Can't get output from empty #{@name}!");
		else
			return @outputs.shift;
		end

	end


	def execute

		putLog("execute...");
		areDone = false;
		
		while (!areDone) do

			theInstruction	= @memory[@pc];
			opCode			= getOpCode(theInstruction);
			opSize			= getOpSize(opCode);
		
			case opCode
			when OP_ADD
				param1 = @memory[@pc + 1];
				param2 = @memory[@pc + 2];
				dst    = @memory[@pc + 3];
		
				value1 = getParamValue(@memory, theInstruction, 1, param1);
				value2 = getParamValue(@memory, theInstruction, 2, param2);
				result = value1 + value2;

				putLog("OP_ADD(#{param1}, #{param2}) => #{value1} + #{value2}, storing #{result} to #{dst}");
				@memory[dst] = result;


			when OP_MULTIPLY
				param1 = @memory[@pc + 1];
				param2 = @memory[@pc + 2];
				dst    = @memory[@pc + 3];
		
				value1 = getParamValue(@memory, theInstruction, 1, param1);
				value2 = getParamValue(@memory, theInstruction, 2, param2);
				result = value1 * value2;

				putLog("OP_MULTIPLY(#{param1}, #{param2}) => #{value1} * #{value2}, storing #{result} to #{dst}");
				@memory[dst] = result;


			when OP_INPUT
				value1 = getInput();
				dst    = @memory[@pc + 1];

				putLog("OP_INPUT() => storing #{value1} to #{dst}");
				@memory[dst] = value1;


			when OP_OUTPUT
				param1 = @memory[@pc + 1];

				value1 = getParamValue(@memory, theInstruction, 1, param1);

				putLog("OP_OUTPUT(#{param1}) => #{value1}");
				putOutput(value1);
				areDone = true;


			when OP_JUMP_IF_TRUE
				param1 = @memory[@pc + 1];
				param2 = @memory[@pc + 2];
		
				value1 = getParamValue(@memory, theInstruction, 1, param1);
				value2 = getParamValue(@memory, theInstruction, 2, param2);

				if (value1 != 0)
					putLog("OP_JUMP_IF_TRUE(#{param1}, #{param2}) => #{value1} != 0, jumping to #{value2}")
					@pc     = value2;
					opSize = 0;
				else
					putLog("OP_JUMP_IF_TRUE(#{param1}, #{param2}) => #{value1} == 0")
				end


			when OP_JUMP_IF_FALSE
				param1 = @memory[@pc + 1];
				param2 = @memory[@pc + 2];
		
				value1 = getParamValue(@memory, theInstruction, 1, param1);
				value2 = getParamValue(@memory, theInstruction, 2, param2);
			
				if (value1 == 0)
					putLog("OP_JUMP_IF_FALSE(#{param1}, #{param2}) => #{value1} == 0, jumping to #{value2}")
					@pc     = value2;
					opSize = 0;
				else
					putLog("OP_JUMP_IF_FALSE(#{param1}, #{param2}) => #{value1} != 0")
				end


			when OP_LESS_THAN
				param1 = @memory[@pc + 1];
				param2 = @memory[@pc + 2];
				dst    = @memory[@pc + 3];
		
				value1 = getParamValue(@memory, theInstruction, 1, param1);
				value2 = getParamValue(@memory, theInstruction, 2, param2);
				result = (value1 < value2) ? 1 : 0;
			
				putLog("OP_LESS_THAN(#{param1}, #{param2}) => #{value1} < #{value2}, storing #{result} to #{dst}");
				@memory[dst] = result;


			when OP_EQUALS
				param1 = @memory[@pc + 1];
				param2 = @memory[@pc + 2];
				dst    = @memory[@pc + 3];
		
				value1 = getParamValue(@memory, theInstruction, 1, param1);
				value2 = getParamValue(@memory, theInstruction, 2, param2);
				result = (value1 == value2) ? 1 : 0;
			
				putLog("OP_EQUALS(#{param1}, #{param2}) => #{value1} == #{value2}, storing #{result} to #{dst}");
				@memory[dst] = result;


			when OP_HALT
				putLog("OP_HALT");
				areDone = true;


			else
				puts @memory;
				abort("Unexpected opcode #{opCode} at #{@pc}");
			end
		
			@pc += opSize;

		end

		return (opCode != OP_HALT);

	end


private
	def putLog(theText)
		if true
			puts "[#{@name}] #{theText}";
		end
	end


	def getOpCode(theInstruction)

		opCode = theInstruction - ((theInstruction / 100) * 100);

		return opCode;

	end


	def getOpSize(opCode)

		case opCode
		when OP_ADD
			return 4;

		when OP_MULTIPLY
			return 4;

		when OP_INPUT
			return 2;

		when OP_OUTPUT
			return 2;
	
		when OP_JUMP_IF_TRUE
			return 3;
	
		when OP_JUMP_IF_FALSE
			return 3;
	
		when OP_LESS_THAN
			return 4;
	
		when OP_EQUALS
			return 4;
	
		when OP_HALT
			return 0;

		else
			abort("Unexpected opCode #{opCode}");
		end

	end


	def getParamMode(theInstruction, paramIndex)

		paramMode = theInstruction / 10;

		for n in (1..paramIndex) do 
			paramMode = paramMode / 10;
		end

		paramMode = paramMode - ((paramMode / 10) * 10);

		return paramMode;	
	
	end


	def getParamValue(theMemory, theInstruction, paramIndex, theParam)

		paramMode = getParamMode(theInstruction, paramIndex);

		case paramMode
		when MODE_POSITION
			return theMemory[theParam];
	
		when MODE_IMMEDIATE
			return theParam;
	
		else
			abort("Unexpected param mode #{paramMode}");
		end

	end


	def getInput

		if (@inputs.empty?)
			print "Input: ";
			theValue = gets.chomp.to_i;
		else
			theValue = @inputs.shift;
		end
	
		return theValue;

	end


	def putOutput(theValue)
		@outputs << theValue;
	end

end





def invokeAmplifiers(theProgram, theSequence, canLoop)

	amplifierA = IntcodeVM.new("A", theProgram, [theSequence[0], 0]);
	amplifierB = IntcodeVM.new("B", theProgram, [theSequence[1]]);
	amplifierC = IntcodeVM.new("C", theProgram, [theSequence[2]]);
	amplifierD = IntcodeVM.new("D", theProgram, [theSequence[3]]);
	amplifierE = IntcodeVM.new("E", theProgram, [theSequence[4]]);
	theResult  = -999;
	
	loop do

		# Run the sequence
		if (amplifierA.execute())
			amplifierB.addInput(amplifierA.getOutput());
		end

		if (amplifierB.execute())
			amplifierC.addInput(amplifierB.getOutput());
		end

		if (amplifierC.execute())
			amplifierD.addInput(amplifierC.getOutput());
		end

		if (amplifierD.execute())
			amplifierE.addInput(amplifierD.getOutput());
		end

		if (amplifierE.execute())
			theResult = amplifierE.getOutput();
		else
			canLoop = false;
		end



		# Halt when done
		if (canLoop)
			amplifierA.addInput(theResult);
		else
			break;
		end

	end

	return theResult;

end



def testSequence(theProgram, theSequence, canLoop)

	maxSignal   = 0;
	maxSequence = [];
	
	theSequence.permutation.each do |theSequence|

		theSignal = invokeAmplifiers(theProgram, theSequence, canLoop);
		if (theSignal > maxSignal)
			maxSignal   = theSignal;
			maxSequence = theSequence;
		end
	
	end
	
	puts "Maximum signal #{maxSignal} from sequence #{maxSequence.join(',')}";

end





# Part One

#theProgram  = [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0];
#theSequence = [4,3,2,1,0];

#theProgram  = [3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0];
#theSequence = [0,1,2,3,4];

#theProgram  = [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0];
#theSequence = [1,0,4,3,2];

#puts invokeAmplifiers(theProgram, theSequence, false);


#theProgram  = [3,8,1001,8,10,8,105,1,0,0,21,34,43,64,85,98,179,260,341,422,99999,3,9,1001,9,3,9,102,3,9,9,4,9,99,3,9,102,5,9,9,4,9,99,3,9,1001,9,2,9,1002,9,4,9,1001,9,3,9,1002,9,4,9,4,9,99,3,9,1001,9,3,9,102,3,9,9,101,4,9,9,102,3,9,9,4,9,99,3,9,101,2,9,9,1002,9,3,9,4,9,99,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,99,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,101,1,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,99];
#theSequence = [0,1,2,3,4];

#testSequence(theProgram, theSequence, false);



# Part Two

#theProgram  = [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5];
#theSequence = [9,8,7,6,5];

#theProgram  = [3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10];
#theSequence = [9,7,8,5,6];


theProgram  = [3,8,1001,8,10,8,105,1,0,0,21,34,43,64,85,98,179,260,341,422,99999,3,9,1001,9,3,9,102,3,9,9,4,9,99,3,9,102,5,9,9,4,9,99,3,9,1001,9,2,9,1002,9,4,9,1001,9,3,9,1002,9,4,9,4,9,99,3,9,1001,9,3,9,102,3,9,9,101,4,9,9,102,3,9,9,4,9,99,3,9,101,2,9,9,1002,9,3,9,4,9,99,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,2,9,4,9,99,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,101,1,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,99];
theSequence = [9,7,8,5,6];

testSequence(theProgram, theSequence, true);







