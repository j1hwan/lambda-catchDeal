class HitProduct < ApplicationRecord
  validates_uniqueness_of :url, :scope => :title
  
  has_many :book_marks
  has_many :app_users, through: :book_marks
  
  has_many :keyword_pushalarm_lists
  has_many :app_users, through: :keyword_pushalarm_lists
  
  establish_connection "#{Jets.env}".to_sym
  self.table_name = "hit_products"
end
