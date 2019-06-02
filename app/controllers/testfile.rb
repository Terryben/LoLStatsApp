require "json"
require "rubygems"
require "pp"


def is_nil_ret_int (input) #values can be empty or nil. Checking for nil so code doesnt error out. Return 0 for nil value
                if input.nil?
                                return "0"
                        else
                                return input

                end
        end

=begin
file = open("F:/Downloads/matches1.json")
                        json = file.read

			parsed_input = JSON.parse(json)
	#		pp parsed_input
                        parsed_input["matches"].each do |game|
                         #       puts game["teams"][0]["teamId"] 
			#	pp game["platformId"]
				game["teams"].each do |team|
					pp team["teamId"]
				end
                        end

=end

h = { "foo-l": {"bar-3": {"baz-4": 1}}}

puts h.dig(:'foo-l', :'bar-3', :'baz-4')           #=> 1
puts h.dig(:foo, :zot)                 #=> nil
puts is_nil_ret_int(h.dig(:"foo-l", :"bar-3", :"baz-4"))
puts is_nil_ret_int(h.dig(:'foo-1', :'bar-3', :lia, :step))

