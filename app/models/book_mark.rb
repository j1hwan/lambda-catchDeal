class BookMark < ApplicationRecord
  validates_uniqueness_of :title, :scope => :app_user
  belongs_to :app_user
  
  establish_connection "#{Jets.env}".to_sym
  self.table_name = "book_marks"
end
