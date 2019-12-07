#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		Day5.rb
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



def traceOpCode(theText)
	if true
		puts theText
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


def executeProgram(theProgram)

	theMemory = theProgram.dup;
	pc        = 0;

	while true do

		theInstruction	= theMemory[pc];
		opCode			= getOpCode(theInstruction);
		opSize			= getOpSize(opCode);
		
		case opCode
		when OP_ADD
			param1 = theMemory[pc + 1];
			param2 = theMemory[pc + 2];
			dst    = theMemory[pc + 3];
		
			value1 = getParamValue(theMemory, theInstruction, 1, param1);
			value2 = getParamValue(theMemory, theInstruction, 2, param2);
			result = value1 + value2;

			traceOpCode("OP_ADD(#{param1}, #{param2}) => #{value1} + #{value2}, storing #{result} to #{dst}");
			theMemory[dst] = result;


		when OP_MULTIPLY
			param1 = theMemory[pc + 1];
			param2 = theMemory[pc + 2];
			dst    = theMemory[pc + 3];
		
			value1 = getParamValue(theMemory, theInstruction, 1, param1);
			value2 = getParamValue(theMemory, theInstruction, 2, param2);
			result = value1 * value2;

			traceOpCode("OP_MULTIPLY(#{param1}, #{param2}) => #{value1} * #{value2}, storing #{result} to #{dst}");
			theMemory[dst] = result;


		when OP_INPUT
			print "Input: ";
			value1 = gets.chomp.to_i;
			dst    = theMemory[pc + 1];

			traceOpCode("OP_INPUT() => storing #{value1} to #{dst}");
			theMemory[dst] = value1;


		when OP_OUTPUT
			param1 = theMemory[pc + 1];

			value1 = getParamValue(theMemory, theInstruction, 1, param1);

			traceOpCode("OP_OUTPUT(#{param1}) => #{value1}");
			puts "#{value1} ";


		when OP_JUMP_IF_TRUE
			param1 = theMemory[pc + 1];
			param2 = theMemory[pc + 2];
		
			value1 = getParamValue(theMemory, theInstruction, 1, param1);
			value2 = getParamValue(theMemory, theInstruction, 2, param2);

			if (value1 != 0)
				traceOpCode("OP_JUMP_IF_TRUE(#{param1}, #{param2}) => #{value1} != 0, jumping to #{value2}")
				pc     = value2;
				opSize = 0;
			else
				traceOpCode("OP_JUMP_IF_TRUE(#{param1}, #{param2}) => #{value1} == 0")
			end


		when OP_JUMP_IF_FALSE
			param1 = theMemory[pc + 1];
			param2 = theMemory[pc + 2];
		
			value1 = getParamValue(theMemory, theInstruction, 1, param1);
			value2 = getParamValue(theMemory, theInstruction, 2, param2);
			
			if (value1 == 0)
				traceOpCode("OP_JUMP_IF_FALSE(#{param1}, #{param2}) => #{value1} == 0, jumping to #{value2}")
				pc     = value2;
				opSize = 0;
			else
				traceOpCode("OP_JUMP_IF_FALSE(#{param1}, #{param2}) => #{value1} != 0")
			end


		when OP_LESS_THAN
			param1 = theMemory[pc + 1];
			param2 = theMemory[pc + 2];
			dst    = theMemory[pc + 3];
		
			value1 = getParamValue(theMemory, theInstruction, 1, param1);
			value2 = getParamValue(theMemory, theInstruction, 2, param2);
			result = (value1 < value2) ? 1 : 0;
			
			traceOpCode("OP_LESS_THAN(#{param1}, #{param2}) => #{value1} < #{value2}, storing #{result} to #{dst}");
			theMemory[dst] = result;


		when OP_EQUALS
			param1 = theMemory[pc + 1];
			param2 = theMemory[pc + 2];
			dst    = theMemory[pc + 3];
		
			value1 = getParamValue(theMemory, theInstruction, 1, param1);
			value2 = getParamValue(theMemory, theInstruction, 2, param2);
			result = (value1 == value2) ? 1 : 0;
			
			traceOpCode("OP_EQUALS(#{param1}, #{param2}) => #{value1} == #{value2}, storing #{result} to #{dst}");
			theMemory[dst] = result;


		when OP_HALT
			break;


		else
			puts theMemory;
			abort("Unexpected opcode #{opCode} at #{pc}");
		end
		
		pc += opSize;

	end

	return theMemory;

end




#theProgram = [3,0,4,0,99];
#theProgram = [1101,100,-1,4,0];

#theProgram = [3,9,8,9,10,9,4,9,99,-1,8];
#theProgram = [3,9,7,9,10,9,4,9,99,-1,8];
#theProgram = [3,3,1108,-1,8,3,4,3,99];
#theProgram = [3,3,1107,-1,8,3,4,3,99];

#theProgram = [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9];
#theProgram = [3,3,1105,-1,9,1101,0,0,12,4,12,99,1];

#theProgram = [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99];

theProgram = [3,225,1,225,6,6,1100,1,238,225,104,0,1102,89,49,225,1102,35,88,224,101,-3080,224,224,4,224,102,8,223,223,1001,224,3,224,1,223,224,223,1101,25,33,224,1001,224,-58,224,4,224,102,8,223,223,101,5,224,224,1,223,224,223,1102,78,23,225,1,165,169,224,101,-80,224,224,4,224,102,8,223,223,101,7,224,224,1,224,223,223,101,55,173,224,1001,224,-65,224,4,224,1002,223,8,223,1001,224,1,224,1,223,224,223,2,161,14,224,101,-3528,224,224,4,224,1002,223,8,223,1001,224,7,224,1,224,223,223,1002,61,54,224,1001,224,-4212,224,4,224,102,8,223,223,1001,224,1,224,1,223,224,223,1101,14,71,225,1101,85,17,225,1102,72,50,225,1102,9,69,225,1102,71,53,225,1101,10,27,225,1001,158,34,224,101,-51,224,224,4,224,102,8,223,223,101,6,224,224,1,223,224,223,102,9,154,224,101,-639,224,224,4,224,102,8,223,223,101,2,224,224,1,224,223,223,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,108,226,226,224,102,2,223,223,1006,224,329,101,1,223,223,1007,677,677,224,1002,223,2,223,1005,224,344,1001,223,1,223,8,226,677,224,1002,223,2,223,1006,224,359,1001,223,1,223,108,226,677,224,1002,223,2,223,1005,224,374,1001,223,1,223,107,226,677,224,102,2,223,223,1006,224,389,101,1,223,223,1107,226,226,224,1002,223,2,223,1005,224,404,1001,223,1,223,1107,677,226,224,102,2,223,223,1005,224,419,101,1,223,223,1007,226,226,224,102,2,223,223,1006,224,434,1001,223,1,223,1108,677,226,224,1002,223,2,223,1005,224,449,101,1,223,223,1008,226,226,224,102,2,223,223,1005,224,464,101,1,223,223,7,226,677,224,102,2,223,223,1006,224,479,101,1,223,223,1008,226,677,224,1002,223,2,223,1006,224,494,101,1,223,223,1107,226,677,224,1002,223,2,223,1005,224,509,1001,223,1,223,1108,226,226,224,1002,223,2,223,1006,224,524,101,1,223,223,7,226,226,224,102,2,223,223,1006,224,539,1001,223,1,223,107,226,226,224,102,2,223,223,1006,224,554,101,1,223,223,107,677,677,224,102,2,223,223,1006,224,569,101,1,223,223,1008,677,677,224,1002,223,2,223,1006,224,584,1001,223,1,223,8,677,226,224,1002,223,2,223,1005,224,599,101,1,223,223,1108,226,677,224,1002,223,2,223,1005,224,614,101,1,223,223,108,677,677,224,102,2,223,223,1005,224,629,1001,223,1,223,8,677,677,224,1002,223,2,223,1005,224,644,1001,223,1,223,7,677,226,224,102,2,223,223,1006,224,659,1001,223,1,223,1007,226,677,224,102,2,223,223,1005,224,674,101,1,223,223,4,223,99,226];

executeProgram(theProgram);



