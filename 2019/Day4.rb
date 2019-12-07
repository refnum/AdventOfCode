#!/usr/bin/ruby -w
#==============================================================================
#	NAME:
#		Day4.rb
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






def digit0(n)
	return n - ((n / 10) * 10);
end


def getPasswords(first, last)

	passwords = [];
	
	(first..last).each do |n|

		n6 = digit0(n / 100000);
		n5 = digit0(n / 10000);
		n4 = digit0(n / 1000);
		n3 = digit0(n / 100);
		n2 = digit0(n / 10);
		n1 = digit0(n);


		# Part One
		isValid = (n5 >= n6 && n4 >= n5 && n3 >= n4 && n2 >= n3 && n1 >= n2);
		
		if (isValid)
			isValid = (n6 == n5 || n5 == n4 || n4 == n3 || n3 == n2 || n2 == n1);
		end


		# Part Two
		if (isValid)
		
			isValid = false;
			
			isValid ||= (n6 == n5 && n5 != n4);
			
			isValid ||= (n6 != n5 && n5 == n4 && n4 != n3);

			isValid ||= (n5 != n4 && n4 == n3 && n3 != n2);

			isValid ||= (n4 != n3 && n3 == n2 && n2 != n1);

			isValid ||= (n3 != n2 && n2 == n1);

		end


		if (isValid)
			passwords << n;
		end

	end
	
	return passwords;

end



passwords = getPasswords(254032, 789860);

puts "Found #{passwords.size} matching passwords";
puts "----";
puts passwords;
