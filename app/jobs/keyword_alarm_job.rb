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
    
    ## 유저가 몇 개의 키워드 데이터가 저장되었는지 기록하는 변수
    userTotalPushCount = Hash.new(0)
    
    ## 유저별 Hash 생성
    @productData.field_values("app_user_id").uniq.each do |product|
      appUser = AppUser.find(product)
      
      userTotalPushCount["#{appUser.app_player}"] = Hash.new(0)
      userTotalPushCount["#{appUser.app_player}"]["app_player"] = appUser.app_player
      userTotalPushCount["#{appUser.app_player}"]["keywordTitle"] = Array.new
    end
    
    ## 데이터베이스에 키워드 수집에 따른 데이터 저장
    @productData.each_with_index do |product, index|
      appUser = AppUser.find(product["app_user_id"])
      
      userTotalPushCount["#{appUser.app_player}"]["keywordCount"] += 1
      userTotalPushCount["#{appUser.app_player}"]["productTitle"] = product["product_title"]
      userTotalPushCount["#{appUser.app_player}"]["keywordTitle"] << product["keyword_title"]
      
      KeywordPushalarmList.create(app_user_id: AppUser.find_by(app_player: appUser.app_player).id, keyword_title: product["keyword_title"], hit_product_id: product["product_id"])
    end
    
    ## 중복 키워드 Title 제거
    @productData.field_values("app_user_id").uniq.each do |product|
      appUser = AppUser.find(product)
      userTotalPushCount["#{appUser.app_player}"]["keywordTitle"].uniq!
    end
    
    puts "[Count] #{userTotalPushCount}"
    
    ## 특정 대상에게 푸쉬알람 전송
    userTotalPushCount.values.each do |push|
      appUser = AppUser.find_by(app_player: push["app_player"])
      
      if (appUser.alarm_status == true)
        params = {"app_id" => ENV["ONESIGNAL_APP_ID"], 
                "headings" => {"en" => "캐치가 [#{push["keywordTitle"].sample(1)[0]}] 키워드 외, 총 #{push["keywordCount"]}개의 핫딜정보를 물어왔어요!"},
                "contents" => {"en" => push["productTitle"]},
                "include_player_ids" => [push["app_player"]]}
      
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
    end
  end
  
end