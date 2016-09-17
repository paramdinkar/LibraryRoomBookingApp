class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.belongs_to :room, index=true
      t.string :room_number
      t.datetime :start_time
      t.datetime :end_time
      t.string :status

      t.timestamps
    end
  end
end
