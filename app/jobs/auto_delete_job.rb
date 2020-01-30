## 캐치딜 DB 내 데이터 중, 오래된 데이터에 대한 삭제가 이루어집니다.
# AutoDeleteJob.perform_now(:auto_delete)

class AutoDeleteJob < ApplicationJob
	def hit_product_auto_delete
		# SELECT A.id FROM hit_products A
		# 	LEFT OUTER JOIN book_marks B ON A.id = B.hit_product_id
		# 	LEFT OUTER JOIN keyword_pushalarm_lists C ON A.id = C.hit_product_id
		# WHERE B.id is NULL AND C.id is NULL AND A.created_at < now() - INTERVAL '30 DAYS';
		
		HitProduct.left_joins(:book_marks).left_joins(:keyword_pushalarm_lists).where("book_marks.id is NULL AND keyword_pushalarm_lists.id is NULL").where('hit_products.created_at < ?', 30.days.ago).each do |x|
		  x.destroy
		end
	end
	
	def bookmark_auto_delete
		BookMark.where('created_at < ?', 60.days.ago).each do |x|
			x.destroy
		end
	end
	
	def pushalarm_list_auto_delete
		KeywordPushalarmList.where('created_at < ?', 60.days.ago).each do |x|
			x.destroy
		end
	end
	
	rate "24 hours"
	def main_running
		bookmark_auto_delete
		pushalarm_list_auto_delete
		hit_product_auto_delete
	end
  
end