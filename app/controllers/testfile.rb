require "json"
require "rubygems"
require "pp"

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
