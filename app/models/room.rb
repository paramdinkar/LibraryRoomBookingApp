class Room < ActiveRecord::Base
   validates :room_number, presence: true
   validates :building, presence: true
   validates :size, presence: true
   #self.primary_key = :room_number
   has_many :reservations, dependent: :destroy
   BUILDINGS = ['D.H.Hill', 'James. B. Hunt']
   STATUS = ['Available', 'Reserved']
   SIZE = ['SMALL(4)','MEDIUM(6)', 'LARGE(12)']
end