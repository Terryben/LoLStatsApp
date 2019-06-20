class PlayerDto < ApplicationRecord
	belongs_to :match, :foreign_key => 'match_id'
end
