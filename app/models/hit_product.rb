class HitProduct < ApplicationRecord
  validates_uniqueness_of :url, :scope => :title
  
  establish_connection "#{Jets.env}".to_sym
  self.table_name = "hit_products"
end
