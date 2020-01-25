class AppUser < ApplicationRecord
  validates_uniqueness_of :app_player
  
  establish_connection "#{Jets.env}".to_sym
  self.table_name = "app_users"
end
