class AddMultipleReservationToMembers < ActiveRecord::Migration
  def change
	add_column :members, :isMultipleReservationAllowed, :string, :default =>"No"
  end
end
