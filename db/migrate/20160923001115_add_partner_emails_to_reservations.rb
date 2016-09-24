class AddPartnerEmailsToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :partnersEmail, :string
  end
end
