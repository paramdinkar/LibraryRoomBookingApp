class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :room_number
      t.string :building
      t.string :size
      t.string :status

      t.timestamps
    end
  end
end
