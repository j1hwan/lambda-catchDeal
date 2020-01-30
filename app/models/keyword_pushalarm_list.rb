class KeywordPushalarmList < ApplicationRecord
  establish_connection "#{Jets.env}".to_sym
  self.table_name = "keyword_pushalarm_lists"
  
  validates_uniqueness_of :app_user_id, :scope => :hit_product_id
  
  belongs_to :app_user
  belongs_to :hit_product
end
