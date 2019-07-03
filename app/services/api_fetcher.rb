require 'net/http'
require 'uri'
require 'json'


def get_summoner_from_api(summoner_name)
	uri = URI.parse("https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/Chubbles?api_key=RGAPI-c632ce1d-a793-4b0d-a4ae-90340ff59ad4")
	response = Net::HTTP.get_response(uri)
	#puts response.body

	json = response.body
	#run into invalid characters. Double convert to force valid characters
	json.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
	json.encode!('UTF-8', 'UTF-16')

	return JSON.parse(json)

end

def get_league_from_api(encrypted_sum_id)
	uri = URI.parse("https://na1.api.riotgames.com/lol/league/v4/entries/by-summoner/KV6e5YkrCHN3A0mKolnLvRTp6MVbf0LwQn8sJjE47ke9k9I?api_key=RGAPI-c632ce1d-a793-4b0d-a4ae-90340ff59ad4")
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
			return 0
		else
			return input
		end
	end
	def is_nil_ret_char (input)
		if input.nil?
			puts "Could not read value. Char 0 returned instead."
			return "0"
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

