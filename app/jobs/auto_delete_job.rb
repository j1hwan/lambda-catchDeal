## 캐치딜 DB 내 데이터 중, 오래된 데이터에 대한 삭제가 이루어집니다.
# AutoDeleteJob.perform_now(:auto_delete)

class AutoDeleteJob < ApplicationJob
	
  rate "30 days"
  def main_auto_delete
		HitProduct.where('created_at < ?', 30.days.ago).each do |x|
		  x.destroy
		end
	end
  
end