class TeamStatsDtoControllerController < ApplicationController
        require "json"
        require "rubygems"
        require "pp"

        def index
                @team_stats_dtos = Team_stats_dto.all
        end

        def show
                @team_stats_dto = Team_stats_dto.find(params[:id])
        end


        def new
        end

        def create
                @team_stats_dto = Team_stats_dto.new(match_params)
                @team_stats_dto.save
                redirect_to @team_stats_dto
        end
end
