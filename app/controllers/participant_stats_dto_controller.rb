class ParticipantStatsDtoController < ApplicationController

def index
	@participant_stats_dtos = ParticipantStatsDto.all
end





end
