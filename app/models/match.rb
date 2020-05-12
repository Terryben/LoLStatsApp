class Match < ApplicationRecord
	has_many :player_dtos
	has_many :team_stats_dtos
	has_many :participant_dtos
end
