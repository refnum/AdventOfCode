#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		Day1.rb
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





masses = [
136995,
113523,
51895,
79350,
124361,
62331,
93313,
67673,
65387,
139570,
74864,
73723,
142366,
108790,
50333,
109242,
67155,
126685,
148459,
126160,
56323,
123773,
116336,
123357,
117877,
90720,
105322,
92084,
100609,
143050,
99542,
137618,
70385,
116984,
137877,
142591,
104263,
77096,
107016,
106030,
88411,
56359,
129141,
88179,
82296,
66855,
146894,
65655,
65481,
107083,
129529,
94207,
118038,
93389,
116976,
141468,
137616,
78852,
57602,
82514,
59790,
115105,
125868,
104067,
100487,
109434,
68047,
84831,
64928,
131286,
78450,
70130,
84341,
105659,
61101,
137930,
125096,
73937,
58756,
123901,
123296,
110409,
104259,
87899,
97236,
111253,
60227,
129468,
79553,
55170,
99267,
101485,
146930,
105511,
145835,
98257,
147609,
143714,
55276,
66162,
];


def getFuel(theMass)
	theFuel = (theMass.to_f / 3.0).floor - 2.0;
	if (theFuel < 0.0)
		theFuel = 0.0;
	end
	
	return theFuel;
end


totalFuel = 0.0;

masses.each do |theMass|

	while theMass > 0.0 do
	
		theFuel = getFuel(theMass);
		totalFuel += theFuel;
		
		theMass = theFuel;
	end

end

puts totalFuel;


