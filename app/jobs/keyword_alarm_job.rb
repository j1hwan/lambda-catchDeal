# KeywordAlarmJob.perform_now(:push_alarm_main)

class KeywordAlarmJob < ApplicationJob
  class_timeout 300
  
  cron "0 1-14 * * ? *"
  def push_alarm_main
    sql = "
      SELECT keyword_alarms.title keyword_title, keyword_alarms.app_user_id, hit_products.id product_id, hit_products.title product_title, hit_products.url product_url
      FROM keyword_alarms, hit_products
      WHERE exists(
          SELECT keyword_alarms.title FROM keyword_alarms
          LEFT JOIN app_users ON app_users.id = keyword_alarms.app_user_id
      ) AND hit_products.title LIKE CONCAT('%', keyword_alarms.title, '%') AND hit_products.created_at > now() - INTERVAL '1 hour';
    "
    @productData = ActiveRecord::Base.connection.execute(sql)
    
    userTotalPushCount = Hash.new(0)
    @productData.each do |product|
      appUser = AppUser.find(product["app_user_id"])
      # puts "product : #{product} || appUser: #{appUser.app_player}"
      
      if (appUser.alarm_status == true && appUser.max_push_count.to_i > userTotalPushCount["#{appUser.app_player}"].to_i && KeywordPushalarmList.find_by(app_user_id: appUser.id, hit_product_id: product["hit_product_id"]).nil?)
        userTotalPushCount[appUser.app_player] += 1

        ## 특정 대상에게 푸쉬
        params = {"app_id" => ENV["ONESIGNAL_APP_ID"], 
                "headings" => {"en" => "캐치가 [#{product["keyword_title"]}] 키워드 상품을 물어왔어요!"},
                "contents" => {"en" => product["product_title"]},
                "url" => product["product_url"],
                "include_player_ids" => [appUser.app_player]}
      
        uri = URI.parse('https://onesignal.com/api/v1/notifications')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        
        request = Net::HTTP::Post.new(uri.path,
                                      'Content-Type'  => 'application/json;charset=utf-8',
                                      'Authorization' => ENV["ONESIGNAL_API_KEY"])
        request.body = params.as_json.to_json
        response = http.request(request)
        # puts "Debugging Response : #{response.body}"
      end
      
      KeywordPushalarmList.create(app_user_id: AppUser.find_by(app_player: appUser.app_player).id, keyword_title: product["keyword_title"], hit_product_id: product["product_id"])
      # puts "[Count] #{userTotalPushCount}"
    end
  end
  
end