class KeywordAlarm < ApplicationRecord
  belongs_to :app_user
  validates_uniqueness_of :title, :scope => :app_user
  
  establish_connection "#{Jets.env}".to_sym
  self.table_name = "keyword_alarms"
end
