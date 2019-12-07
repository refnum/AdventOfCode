#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		Day2.rb
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






#program = [1,9,10,3,2,3,11,0,99,30,40,50];
#program = [1, 0, 0, 0, 99];
#program = [2, 3, 0, 3, 99];
#program = [2, 4, 4, 5, 99, 0];
#program = [1, 1, 1, 4, 99, 5, 6, 0, 99];


def executeProgram(program)

	memory = program.dup;
	pc      = 0;

	while memory[pc] != 99 do

		opCode = memory[pc];
	
		case opCode
		when 1
			srcA = memory[pc + 1];
			srcB = memory[pc + 2];
			dst  = memory[pc + 3];
	
			memory[dst] = memory[srcA] + memory[srcB];
			pc         += 4;

		when 2
			srcA = memory[pc + 1];
			srcB = memory[pc + 2];
			dst  = memory[pc + 3];
	
			memory[dst] = memory[srcA] * memory[srcB];
			pc         += 4;

		when 99
			# Halting

		else
			puts memory;
			abort("Unexpected opcode #{opCode} at #{pc}");
		end

	end

	return memory;
end


program = [1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,10,1,19,2,9,19,23,2,13,23,27,1,6,27,31,2,6,31,35,2,13,35,39,1,39,10,43,2,43,13,47,1,9,47,51,1,51,13,55,1,55,13,59,2,59,13,63,1,63,6,67,2,6,67,71,1,5,71,75,2,6,75,79,1,5,79,83,2,83,6,87,1,5,87,91,1,6,91,95,2,95,6,99,1,5,99,103,1,6,103,107,1,107,2,111,1,111,5,0,99,2,14,0,0]

for noun in 0..99 do
	for verb in 0..99 do

		program[1] = noun;
		program[2] = verb;
		result    = executeProgram(program)[0];
		
		if (result == 19690720)
			puts "noun=#{noun}, verb=#{verb}, result=#{result}";
			puts 100 * noun + verb;
		elsif (result > 19690720)
			break;
		end

	end
end



