class Admin < ActiveRecord::Base
  validates :name, presence: true
  validates :password, presence: true
  validates :email, format: {with: /\A[a-zA-Z._0-9]+@[a-zA-Z]+\.[a-zA-Z]+/}, uniqueness: true
  #self.primary_key = :email
end
