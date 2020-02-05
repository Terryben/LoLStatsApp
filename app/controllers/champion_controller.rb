class ChampionController < ApplicationController
	def index
		@champions = Champion.all
	end

	def show
		#must include the "select("*") or it will not return values from the joined table. Commented out section is a differet and kinda worse way to write this code
		@champion = Champion.select("*").left_outer_joins(:champion_positional_stats).where("champions.id = ?", params[:id])
		#@champion = Champion.select("*").joins("INNER JOIN champion_positional_stats ON champions.id = champion_positional_stats.champion_id").where("champions.id = #{params[:id]}")	
	end
	
	def new
	end

	def create
	end

	def edit
	end

	def update
	end

	def delete
	end
	
end
