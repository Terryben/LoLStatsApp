class SummonersController < ApplicationController

	require "json"
	require "rubygems"
	require "pp"
	require "ostruct"
	#load 'E:\Ruby\Ruby25-x64\LoL_Stats_App\lib\user_created_classes\api_fetcher.rb'
	#load 'E:\Ruby\Ruby25-x64\LoL_Stats_App\lib\user_created_classes\api_logic.rb'

	Pp = Struct.new(:page_num, :record_count, :asc, :col_name)

	def index
		@summoners = Summoner.select("*").where("id < 100")
		@page_params = Pp.new(1, Summoner.count, "asc", "id")
	end

	def ascend_descend_next_back

		#Create a set with all the summoner columns in it. Then compare the user variables to the set. If we get a match then you can do the query on the returned set values
		#to prevent any malicious code from getting in
		sum_col_set = Set["id", "name", "queue_type", "rank", "tier", "level", "account_id"]
		puts "The col name is #{params[:col_name]}"

		@page_params = Pp.new(params[:page_num].to_i, Summoner.count, params[:asc].gsub(/[!@#$%^&*()-=+|;':",.<>?']/, ''), params[:col_name].gsub(/[!@#$%^&*()-=+|;':",.<>?']/, ''))


		if !sum_col_set.include?(@page_params.col_name) then 
			#puts "NOT EQUALS #{params[:col_name]}"
			flash[:error] = "Invalid column parameter chosen."
			redirect_to action: "index"	
		else
			#if the column name is the same as last time, swap the order of the table
			begin
			if @page_params.asc == "asc" then
				@asc = "asc"
			else
				@asc = "desc"
			end
			#set col name to the new column
			@temp_page_num = @page_params[:page_num].to_i
			@page_params[:record_count] = Summoner.count
			puts @asc.nil?
			puts "#{@asc}"
			puts "WHAT DOES THIS RETURN?"
			puts Arel.sql("#{params[:col_name]} #{@asc}")
			@summoners = Summoner.select("*").order(Arel.sql("#{params[:col_name]} #{@asc}")).limit(100).offset((@temp_page_num * 100)-100)
			#USE RAW SQL
			rescue Exception => ex
				logger.error(ex.message)
				flash[:notice] = "Something went wrong, returning you to the index page."
				redirect_to(:action => 'index')
			end
			render 'index'
		end
	end

	#def next_index_page
	#	@page_num = params[:page_num].to_i + 1
	#	@sum_count = Summoner.count
	#	@summoners = Summoner.select("*").where("id < (#{@page_num} * 100)").where("id > ((#{@page_num} * 100)-100)")
	#	render 'index'

	#end

	#def back_index_page
	#	@page_num = params[:page_num].to_i - 1
	#	@sum_count = Summoner.count
	#	if @page_num < 1 then
	#		@page_num = 1
	#	end
	#	@summoners = Summoner.select("*").where("id < (#{@page_num} * 100)").where("id > ((#{@page_num} * 100)-100)")
	#	render 'index'
	#end

	def show
		@summoner = Summoner.select("*")
	end

	def read_summoner_json
			load_summoner_from_api(params[:summoner_name], params[:api_key])
			redirect_to action: "index"
	end

	def get_account_id(sum)
		acc_id = Summoner.select("account_id").where("summoners.name = '#{sum}'")
		return acc_id.first.account_id
	end
	
	#user passed the Riot game ID of the match, return it and only it to the user
	def search_for_summoner
		begin
		#remove punctuation to sanitize string
		sum_name = params[:summoner_name].gsub(/[!@#$%^&*()-=_+|;':",.<>?']/, '')
		@summoners = Summoner.select("*").where("name = '#{sum_name}'")
		@page_params = Pp.new(1, Summoner.count, "asc", "id")
		render 'index'
		rescue Exception => ex
			logger.error(ex.message)
			flash[:notice] = "Something went wrong, returning you to the index page."
			redirect_to(:action => 'index')
		end
	end
	

	#uses api_fetcher in services to pull needed info from Riot's api to create a summoner in the database. Parses data from two separate API calls then queries to see if the summoner already
	# exists in the database. If not, it creates it. If it does exist, it updates the summoner with the new up to date data.
	# also returns the summoners rank
	def load_summoner_from_api(summoner_name, api_key)
		api_lgc = APILogic.new
		ret_val = api_lgc.api_load_summoner_from_api(summoner_name, api_key)
		if ret_val == "ERROR: Response from API was nil and/or code was not 200." then
			ret_val = ""
			puts "ERROR: Response from API was nil and/or code was not 200."
		end
		return ret_val

	end

	private
	#only allow the API key for the read summoner params. Will need when I create generic new or create methods
		#def api_params
		#	params.require(

end
