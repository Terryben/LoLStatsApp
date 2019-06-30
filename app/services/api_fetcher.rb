require 'net/http'
require 'uri'
require 'json'

uri = URI.parse("https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/Chubbles?api_key=RGAPI-94ea6491-276a-49dd-a7b2-04e277f05043")
response = Net::HTTP.get_response(uri)

#puts response.body

json = response.body
#run into invalid characters. Double convert to force valid characters
json.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
json.encode!('UTF-8', 'UTF-16')

puts json


# response.code
# response.body
