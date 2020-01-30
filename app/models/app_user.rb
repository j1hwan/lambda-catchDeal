class AppUser < ApplicationRecord
  validates_uniqueness_of :app_player
  
  has_many :book_marks, dependent: :destroy
  has_many :hit_products, through: :book_marks
  
  has_many :keyword_alarms, dependent: :destroy
  
  has_many :keyword_pushalarm_lists, dependent: :destroy
  has_many :hit_products, through: :keyword_pushalarm_lists
  
  establish_connection "#{Jets.env}".to_sym
  self.table_name = "app_users"
end
