## 딜바다 사이트에 대해 크롤링이 수행됩니다.
# HitProductDealBadaJob.perform_now(:main_deal_bada_chrome)

class HitProductDealBadaJob < ApplicationJob
  
  def data_write(data)
    
    @dataArray.each do |currentData|
      puts "[딜바다] Process : Data Writing..."
      @previousData = HitProduct.find_by(url: currentData[9])
      
      if @previousData != nil
        
        ## 제목 변경 체크
        if (currentData[2].to_s != @previousData.title.to_s)
          @previousData.update(title: currentData[2].to_s, is_title_changed: true)
        end
        
        
        ## 이미지 변경 체크
        if (currentData[10].to_s != @previousData.image_url.to_s)
          @previousData.update(image_url: currentData[10].to_s)
        end
        
        
        ## score 변경 체크
        if (currentData[8].to_i > @previousData.score.to_i)
          @previousData.update(view: currentData[5].to_i, comment: currentData[6].to_i, like: currentData[7].to_i, score: currentData[8].to_i)
        end
        
        
        ## 판매상태 체크
        if (@previousData.is_sold_out == false && currentData[4] == true)
          @previousData.update(is_sold_out: true)
        end
        
        
        ## RedirectUrl 변경 체크
        if (currentData[11].to_s != @previousData.redirect_url.to_s)
          @previousData.update(redirect_url: currentData[11].to_s)
        end
      end
      HitProduct.create(product_id: currentData[0], date: currentData[1], title: currentData[2], website: currentData[3], is_sold_out: currentData[4], view: currentData[5], comment: currentData[6], like: currentData[7], score: currentData[8], url: currentData[9], image_url: currentData[10], redirect_url: currentData[11])
    end
    
  end
    
  
  def crawl_deal_bada(index, url, failStack)
    
    ### 딜바다 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 2)
    begin
      puts "[딜바다 #{index}] 크롤링 시작!"
      @dataArray = Array.new
      
      @browser.navigate().to "#{url}"
        
      ## find_element랑 find_elements의 차이
      @content = @browser.find_elements(css: 'table.hoverTable > tbody > tr')
        
      @content.each do |t|
        @titleContent = t.find_element(css: "td.td_subject > a").text.strip
        @noticeCheck = t.find_element(css: "a.bo_cate_link").text.strip
          
        @previousData = HitProduct.find_by(title: @title, website: "딜바다")
        if (@previousData != nil && @titleContent.split("\n")[0].include?("블라인드 처리된 게시물입니다."))
          @previousData.destroy
        end
          
        if (not @titleContent.split("\n")[0].include?("블라인드 처리") || @noticeCheck == "공지" || @titleContent.split("\n")[0].include?("확인 가능합니다."))
          @webCreatedTime = t.find_element(css: 'td.td_date').text
          
          @title = @titleContent.split("\n")[0]
          
          @view = t.find_element(css: 'td:nth-child(7)').text.to_i
          @comment = @titleContent.split("\n")[1].to_i rescue @comment = 0
          @like = t.find_element(css: 'td.td_num_g > span:nth-child(1)').text.to_i
          @score = @view/1.5 + @like*250 + @comment*10
          @url = t.find_element(css: "td.td_subject > a").attribute("href").gsub("&page=#{index}", "")
  
          @sailStatus = t.find_element(css: "td.td_subject > a > img") rescue @sailStatus = false
            
          if @sailStatus != false
            @sailStatus = true
          end
            
          begin
            docs = Nokogiri::HTML(open(@url))
              
            begin
              redirectUrl = docs.at("ul > li > span > a").attr("href")
            rescue
              redirectUrl = nil
            end
              
            begin
              for i in 7..9
                compareCase = docs.at("#bo_v_info > div:nth-child(2) > span:nth-child(#{i})")
                if compareCase.nil? == false && compareCase.text.include?("-")
                  time = compareCase.text
                end
              end
                
            rescue
              if (time.nil?)
                time = Time.zone.now.strftime('%Y-%m-%d %H:%M')
              end
            end
              
            begin
              imageUrlCollect = docs.at("div#bo_v_con").at("img").attr('src')
            rescue
              imageUrl = nil
            end
              
            if imageUrlCollect.include?("cdn.dealbada.com") == false
              imageUrl = "#{imageUrlCollect.gsub("http", "https")}"
            elsif imageUrlCollect.include?("cdn.dealbada.com") == true
              imageUrl = imageUrlCollect.gsub("http", "https")
            end
              
            if imageUrl != nil && imageUrl.include?("https://cfile")
              imageUrl = imageUrl.gsub("https:", "http:")
            end
          rescue
            redirectUrl = nil
            imageUrl = nil
          end
            
          if redirectUrl.nil? || redirectUrl.empty? || (not redirectUrl.include? "http") || (not redirectUrl.include? "https")
            redirectUrl = ""
          end
          
          ## Console 확인용
          # puts "i : #{index}"
          # puts "title : #{@title} / time : #{@time} / view : #{@view}"
          # puts "comment : #{@comment} / like : #{@like} / score : #{@score} / sailStatus : #{@sailStatus} / url : #{@url}"
          # puts "==============================================="
            
          @dataArray.push(["dealBaDa_#{SecureRandom.hex(6)}", time, @title, "딜바다", @sailStatus, @view, @comment, @like, @score, @url, imageUrl, redirectUrl])
          # @newHotDeal = HitProduct.create(product_id: "dealBaDa_#{SecureRandom.hex(6)}", date: @time, title: @title, website: "딜바다", is_sold_out: @sailStatus, view: @view, comment: @comment, like: @like, score: @score, url: @url, image_url: @imageUrl)
        else
          next
        end
      end
      data_write(@dataArray)
      return 1
    rescue
      # puts "crawl_ppom failStack : #{failStack}"
      # puts "타임아웃 에러 발생, 크롤링 재시작"
      
      if failStack == 1
        return 0
      else
        return crawl_deal_bada(index, url, failStack+1)
      end
    end
  end
  
  rate "2 minutes"
  def main_deal_bada_chrome
    
    if Jets.env == "production"
      Selenium::WebDriver::Chrome.driver_path = "/opt/bin/chrome/chromedriver"
    else
      Selenium::WebDriver::Chrome.driver_path = `which chromedriver-helper`.chomp
    end
    
    if Jets.env == "production"
      options = Selenium::WebDriver::Chrome::Options.new(binary:"/opt/bin/chrome/headless-chromium")
    else
      options = Selenium::WebDriver::Chrome::Options.new
    end
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--window-size=1280x1696")
    options.add_argument("--disable-application-cache")
    options.add_argument("--disable-infobars")
    options.add_argument("--no-sandbox")
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument("--hide-scrollbars")
    options.add_argument("--enable-logging")
    options.add_argument("--log-level=0")
    options.add_argument("--single-process")
    options.add_argument("--ignore-certificate-errors")
    options.add_argument("--homedir=/tmp")
    @browser = Selenium::WebDriver.for :chrome, options: options # 실레니움 + 크롬 + 헤드리스 옵션으로 브라우저 실행
  
    ### 딜바다 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 2)
    for index in 1..2
      @result = crawl_deal_bada(index, "http://www.dealbada.com/bbs/board.php?bo_table=deal_domestic&page=#{index}", 0)
      # puts "@result : #{@result}"
    end
  
    @browser.quit
    
  end
    
end