class ParticipantDto < ApplicationRecord
	belongs_to :match
	belongs_to :champion
	has_one :player_dto
end
