class PlayerDtoController < ApplicationController

	def index
		@player_dtos = PlayerDto.all
	end
end
