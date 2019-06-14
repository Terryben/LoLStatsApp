class TeamStatsDtoController < ApplicationController
        require "json"
        require "rubygems"
        require "pp"

        def index
                @team_stats_dtos = TeamStatsDto.all
        end

        def show
                @team_stats_dto = TeamStatsDto.find(params[:id])
        end


        def new
        end

        def create
                @team_stats_dto = TeamStatsDto.new(team_stats_dto_params)
                @team_stats_dto.save
                redirect_to @team_stats_dto
        end
end
