class Reservation < ActiveRecord::Base
  belongs_to :room
  belongs_to :member, foreign_key: "members_id"
end
