class ParticipantTimelineDtoController < ApplicationController

	def index
                @participant_timeline_dtos = ParticipantTimelineDto.all
        end

        def show
                @participant_timeline_dto = ParticipantTimelineDto.find(params[:id])
        end


        def new
        end

        def create
                @participant_timeline_dto = ParticipantTimelineDto.new(participant_timeline_dto_params)
                @participant_timeline_dto.save
                redirect_to @participant_timeline_dto
        end

end
