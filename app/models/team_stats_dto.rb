class TeamStatsDto < ApplicationRecord
	belongs_to :matches, optional: true
end
