## 캐치딜 DB 내 데이터 중, 오래된 데이터에 대한 삭제가 이루어집니다.
# AutoDeleteJob.perform_now(:auto_delete)

class AutoDeleteJob < ApplicationJob
	
  def hit_product_auto_delete
		HitProduct.where('created_at < ?', 30.days.ago).each do |x|
		  x.destroy
		end
	end
	
  def bookmark_auto_delete
		BookMark.where('created_at < ?', 60.days.ago).each do |x|
		  x.destroy
		end
	end
	
  def pushalarm_list_auto_delete
		KeywordPushalarmList.where('created_at < ?', 30.days.ago).each do |x|
		  x.destroy
		end
	end
	
	rate "24 hours"
	def main_running
		hit_product_auto_delete
		bookmark_auto_delete
		pushalarm_list_auto_delete
	end
  
end