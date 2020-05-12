require 'net/http'
require 'uri'
require 'json'
require 'ostruct'



#pull API request from Riot Games. Parse the body of the request as JSON and return it
def get_api_request_as_json(request_uri2)
	request_uri = request_uri2.gsub /\s+/, '%20'
	begin
		uri = URI.parse(request_uri)
		puts "The URI is #{uri}"
	rescue
		uri = URI.parse(URI.escape(request_uri))
		puts "The escaped uri is #{uri}"
	end
	response = Net::HTTP.get_response(uri)
	
	#puts response.code
	#puts "buffer"
	#puts response.body

	#make a pair to return the reponse body in JSON and the response code
	ret = OpenStruct.new
	
	json = response.body
	#run into invalid characters. Double convert to force valid characters
	json.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
	json.encode!('UTF-8', 'UTF-16')
	
	ret.head = response.code
	ret.tail = JSON.parse(json)
	
	puts "The head is #{ret.head}" 	
	puts "The tail is #{ret.tail}" 	
	#puts "HERE is the response code"
	#puts response.code

	return ret

end



#fetches summoner information from the Riot Games API when passed a summoner name and an API key
def get_summoner_from_api(summoner_name, api_key)
	begin
		uri = URI.parse("https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/#{summoner_name}?api_key=#{api_key}")
	rescue
		uri = URI.parse(URI.excape("https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/#{summoner_name}?api_key=#{api_key}"))
	end
	response = Net::HTTP.get_response(uri)
	#puts response.body

	json = response.body
	#run into invalid characters. Double convert to force valid characters
	json.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
	json.encode!('UTF-8', 'UTF-16')

	return JSON.parse(json)

end

#fetches summoner league information (rank, tier, queue type, etc) when passed an ecrypted summoner id and an API key
def get_league_from_api(encrypted_sum_id, api_key)
	uri = URI.parse("https://na1.api.riotgames.com/lol/league/v4/entries/by-summoner/#{encrypted_sum_id}?api_key=#{api_key}")
	response = Net::HTTP.get_response(uri)

	json = response.body
	#run into invalid characters. Double convert to force valid characters
	json.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
	json.encode!('UTF-8', 'UTF-16')
	
	return JSON.parse(json)

end


        def is_nil_ret_int (input) #values can be empty or nil. Checking for nil so code doesnt error out. Return 0 for nil value
		if input.nil?
			puts "Could not read value. Int 0 returned instead."
			return -1
		else
			return input
		end
	end
	def is_nil_ret_char (input)
		if input.nil?
			puts "Could not read value. Char 0 returned instead."
			return "-1"
		else
			return input
		end
	end
	def is_nil_ret_bool (input)
		if input.nil?
			puts "Could not read value. False returned instead."
			return false
		else
			return input
		end
	end

