class AddReservationIdToReservation < ActiveRecord::Migration
  def change
    remove_column :reservations, :true_id
    add_reference :reservations, :members, index: true, foreign_key: true
  end
end
