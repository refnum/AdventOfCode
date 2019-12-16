#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		Day16.rb
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
#		Inputs
#------------------------------------------------------------------------------
# Part One
#theInput = "12345678";

theInput = "80871224585914546619083218645595";
theInput = "19617804207202209144916044189917";
theInput = "69317163492948606335995924319873";


# Part Two
theInput = "03036732577212944063491565474664";
theInput = "02935109699940807407585447034323";
theInput = "03081770884921959731165446850517";


# Puzzle Input
theInput = "59750530221324194853012320069589312027523989854830232144164799228029162830477472078089790749906142587998642764059439173975199276254972017316624772614925079238407309384923979338502430726930592959991878698412537971672558832588540600963437409230550897544434635267172603132396722812334366528344715912756154006039512272491073906389218927420387151599044435060075148142946789007756800733869891008058075303490106699737554949348715600795187032293436328810969288892220127730287766004467730818489269295982526297430971411865028098708555709525646237713045259603175397623654950719275982134690893685598734136409536436003548128411943963263336042840301380655801969822";





#==============================================================================
#		parseInput : Parse the input.
#------------------------------------------------------------------------------
def parseInput(theText)

	return theText.chars.map(&:to_i);

end





#==============================================================================
#		generatePattern : Generate the pattern.
#------------------------------------------------------------------------------
def generatePattern(numRepeats, theSize)

	# Generate the pattern
	basePattern = [0, 1, 0, -1];
	thePattern  = Array.new();
	
	basePattern.each do |x|
		thePattern.concat(Array.new(numRepeats).fill(x));
	end



	# Repeat for size
	while (thePattern.size < (theSize + 1))
		thePattern = thePattern.concat(thePattern);
	end
	
	return thePattern.slice(1, theSize);

end





#==============================================================================
#		applyPhase : Apply a phase.
#------------------------------------------------------------------------------
def applyPhase(theValues)

	theResult = Array.new();
	numValues = theValues.size;

	0.upto(numValues-1) do |theRow|

		thePattern = generatePattern(theRow + 1, numValues);
		theSum     = 0;

		0.upto(numValues-1) do |theColumn|
			theValue = theValues[ theColumn];
			theScale = thePattern[theColumn];
			theSum  += (theValue * theScale);
		end
		
		theValue = theSum.abs % 10;
		theResult << theValue;

	end

	return theResult.join('');

end








# Part One
if (false)
	puts "Input signal: #{theInput}";
	theSignal = theInput.dup();

	1.upto(100) do |n|

		theDigits = parseInput(theSignal);
		theSignal = applyPhase(theDigits);
		theResult = theSignal.slice(0, 8);
	
		if (n == 1)
			puts "After 1 phase: #{theResult}";
		else
			puts "After #{n} phases: #{theResult}";
		end
	end
end




# Part Two
if (true)
    theDigits = parseInput(theInput);
    theOffset = theInput[0, 7].to_i

    theData = (theDigits * 10_000)[theOffset..-1];
	theSize = theData.size - 2;

    100.times do
		theSize.downto(0) do |n|
			theData[n] = (theData[n] + theData[n + 1]) % 10;
		end
    end

	theResult = theData.first(8).join;
	puts theResult;

end

