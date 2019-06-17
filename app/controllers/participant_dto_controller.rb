class ParticipantDtoController < ApplicationController
	def index
		@participant_dtos = ParticipantDto.all
	end


end
