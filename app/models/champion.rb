class Champion < ApplicationRecord
	has_many :participant_dtos
	has_many :champion_positional_stats
end
