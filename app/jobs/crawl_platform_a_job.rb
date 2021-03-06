## 아래에 서술된 플랫폼에 대해 크롤링이 수행됩니다.
## 뽐뿌, 클리앙, 루리웹, 딜바다
# CrawlPlatformAJob.perform_now(:running_crawl)

class CrawlPlatformAJob < ApplicationJob
  class_timeout 300
  
  ### 뽐뿌  
  def data_write_ppom(dataArray)
    dataArray.each do |currentData|
      puts "[뽐뿌] Process : Data Writing..."
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
        elsif (@previousData.is_sold_out == true && currentData[4] == false)
          @previousData.update(is_sold_out: false)
        end
        
      end
      
      HitProduct.create(product_id: currentData[0], date: currentData[1], title: currentData[2], website: currentData[3], is_sold_out: currentData[4], view: currentData[5], comment: currentData[6], like: currentData[7], score: currentData[8], url: currentData[9], image_url: currentData[10])
    end
  end
  
  
  def crawl_ppom(index, url, failStack)
    
    begin
      puts "[뽐뿌 #{index}] 크롤링 시작!"
      @dataArray = Array.new
      
      @browser.navigate().to "#{url}"
      
      ## find_element랑 find_elements의 차이
      @content = @browser.find_elements(css: 'li.none-border')
      
      @content.each_with_index do |t, w|
        if (index == 1 && w >= 15)
          next
        end
        @title = t.find_element(css: 'span.cont').text
        
        # @brand = @title[/\[(.*?)\]/, 1]
        @info = t.find_element(css: "li.exp > span:nth-child(4)").text.gsub("[", "").gsub("]", "").split("/")
        @view = @info[0].gsub(" ", "").to_i
        
        @time = t.find_element(css: "li.exp > time").text
        if @time.include?(":")
          @time = Time.now.in_time_zone("Asia/Seoul").strftime('%Y-%m-%d') + " #{@time}"
        elsif @time.include?("-")
          @time = "20" + @time
        elsif @time.nil?
          @time = Time.now.in_time_zone("Asia/Seoul").strftime('%Y-%m-%d %H:%M')
        end
        @time = @time.to_time - 9.hours
        
        @comment = t.find_element(css: 'span.rp').text.to_i rescue @comment = 0
        @like = @info[1].gsub(" ", "").to_i
        @score = eval(ENV["SCORE_PPOM"])
        
        @sailStatus = t.find_element(css: "span.cont > span").attribute("style") rescue @sailStatus = false
        
        if @sailStatus != false
          @sailStatus = true
        end
        
        @urlMobile = t.find_element(css: "a").attribute("href")
        @urlExtract = CGI::parse(@urlMobile)
        @urlPostNo = @urlExtract['no'].to_a[0]
        @url = "http://www.ppomppu.co.kr/zboard/view.php?id=ppomppu&no=" + @urlPostNo
        
        
        @imageUrlCollect = t.find_element(css: 'img').attribute("src")
        @imageUrl = "#{@imageUrlCollect.gsub("http", "https")}"
        
        if @imageUrl.include?("noimage") || @imageUrl.include?("no_img")
          @imageUrl = nil
        end
        
        if @imageUrl != nil && @imageUrl.include?("https://cfile")
          @imageUrl = @imageUrl.gsub("https:", "http:")
        end
        
        
        ## Console 확인용
        # puts "index : #{index}"
        # puts "title : #{@title} / time : #{@time} / view : #{@view}"
        # puts "comment : #{@comment} / like : #{@like} / score : #{@score} / url : #{@url}"
        # puts "==============================================="
        
        @dataArray.push(["ppom_#{SecureRandom.hex(6)}", @time, @title, "뽐뿌", @sailStatus, @view, @comment, @like, @score, @url, @imageUrl])
        # @newHotDeal = HitProduct.create(product_id: "ppom_#{SecureRandom.hex(6)}", date: @time, title: @title, website: "뿜뿌", is_sold_out: @sailStatus, view: @view, comment: @comment, like: @like, score: @score, url: @url, image_url: @imageUrl)
      end
      
      data_write_ppom(@dataArray)
      return 1
      
    rescue Timeout::Error
      # puts "crawl_ppom failStack : #{failStack}"
      # puts "타임아웃 에러 발생, 크롤링 재시작"
      
      if failStack == 1
        return 0
      else
        return crawl_ppom(index, url, failStack+1)
      end
    end
  end
  
  def main_ppom_chrome
    
    ### 뿜뿌 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 2)
    for index in 1..2
      @result = crawl_ppom(index, "http://m.ppomppu.co.kr/new/bbs_list.php?id=ppomppu&page=#{index}", 0)
      # puts "@result : #{@result}"
    end
    
  end
  
  
  ### 루리웹
  def data_write_ruliweb(dataArray)
    dataArray.each do |currentData|
      puts "[루리웹] Process : Data Writing..."
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
        
        
        ## RedirectUrl 변경 체크
        if (currentData[11].to_s != @previousData.redirect_url.to_s)
          @previousData.update(redirect_url: currentData[11].to_s)
        end
        
      end
      
      HitProduct.create(product_id: currentData[0], date: currentData[1], title: currentData[2], website: currentData[3], is_sold_out: currentData[4], view: currentData[5], comment: currentData[6], like: currentData[7], score: currentData[8], url: currentData[9], image_url: currentData[10], redirect_url: currentData[11])
    end
  end
  
  def crawl_ruliweb(index, url, failStack)
  
    begin
      puts "[루리웹 #{index}] 크롤링 시작!"
      @dataArray = Array.new
      
      # @current_page = @page.page_stack
      @browser.navigate().to "#{url}"
      
      ## find_element랑 find_elements의 차이
      @content = @browser.find_elements(css: '#board_list > div > div.board_main.theme_default.theme_white > table > tbody > tr')
      
      @content.each_with_index do |t, j|
        @timeCheck = t.find_element(css: 'td.time').text
        @noticeCheck = t.find_element(css: 'td.divsn').text rescue @noticeCheck = ""
        if (not @noticeCheck.include?("전체공지") || @noticeCheck.include?("공지"))
          @webCreatedTime = @timeCheck
          
          @title = t.find_element(css: "a.deco").text
          @view = t.find_element(css: 'td.hit').text.to_i
          @comment = t.find_element(css: "td.subject > div.relative > span.num_reply > span.num").text.to_i rescue @comment = 0
          @like = t.find_element(css: 'td.recomd > span').text.to_i rescue @like = 0
          @score = eval(ENV["SCORE_RULIWEB"])
          @url = t.find_element(css: "a.deco").attribute("href")
          @url = @url.gsub("https://bbs.ruliweb.com", "https://m.ruliweb.com").gsub("?page=#{index}", "")
  
          @sailStatus = false rescue @sailStatus = false
          if not (@sailStatus == false)
            @sailStatus = true
          end
          
          begin
            docs = Nokogiri::HTML(open(@url))
            redirectUrl = docs.css("div.source_url").text.split("|")[1].gsub(" ", "")
            if redirectUrl.nil? || redirectUrl.empty? || (not redirectUrl.include? "http") || (not redirectUrl.include? "https")
              redirectUrl = nil
            end
            
            time = docs.css("span.regdate").text.gsub(/\(|\)/, "").to_time - 9.hours
            imageUrlCollect = docs.at("div.view_content").at("img").attr('src')
            
            if imageUrlCollect.include?("ruliweb.com/img/") == false
              imageUrl = "#{imageUrlCollect.gsub("http", "https")}"
            elsif imageUrlCollect.include?("ruliweb.com/img/") == true
              imageUrl = "https:" + "#{imageUrlCollect}"
            end
            
            if imageUrl != nil && imageUrl.include?("https://cfile")
              imageUrl = imageUrl.gsub("https:", "http:")
            end
          rescue
            imageUrl = nil
          end
          
          ## Console 확인용
          # puts "i : #{index}"
          # puts "title : #{@title} / time : #{time} / view : #{@view}"
          # puts "comment : #{@comment} / like : #{@like} / score : #{@score} / url : #{@url}"
          # puts "@imageUrl : #{imageUrl}"
          # puts "==============================================="
         
          # puts "Process : Pushing..."
          @dataArray.push(["ruliweb_#{SecureRandom.hex(6)}", time, @title, "루리웹", @sailStatus, @view, @comment, @like, @score, @url, imageUrl, redirectUrl])
          # HitProduct.create(product_id: "ruliweb_#{SecureRandom.hex(6)}", date: @time, title: @title, website: "루리웹", is_sold_out: @sailStatus, view: @view, comment: @comment, like: @like, score: @score, url: @url, image_url: @imageUrl)
        else
          next
        end
      end
      data_write_ruliweb(@dataArray)
      return 1
      
    rescue Timeout::Error
      # puts "crawl_ppom failStack : #{failStack}"
      # puts "타임아웃 에러 발생, 크롤링 재시작"
      
      if failStack == 1
        return 0
      else
        return main_ruliweb_chrome(index, url, failStack+1)
      end
    end
  end
  
  def main_ruliweb_chrome
    
    ### 루리웹 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 3)
    for index in 1..3
      @result = crawl_ruliweb(index, "https://bbs.ruliweb.com/market/board/1020?page=#{index}", 0)
      # puts "@result : #{@result}"
    end
    
  end
  
  
  ### 딜바다
  def data_write_deal_bada(data)
    
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
        elsif (@previousData.is_sold_out == true && currentData[4] == false)
          @previousData.update(is_sold_out: false)
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
          @score = eval(ENV["SCORE_DEALBADA"])
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
            redirectUrl = nil
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
      data_write_deal_bada(@dataArray)
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
  
  def main_deal_bada_chrome
    
    ### 딜바다 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 2)
    for index in 1..2
      @result = crawl_deal_bada(index, "http://www.dealbada.com/bbs/board.php?bo_table=deal_domestic&page=#{index}", 0)
      # puts "@result : #{@result}"
    end
  
  end
  
  
  ### 클리앙
  def collect_rest_data_clien(urlId, failStack)
    @browser2.navigate().to "https://www.clien.net/service/board/jirum/#{urlId}"
    begin
      time = @browser2.find_element(css: "#div_content > div.post_view > div.post_author > span:nth-child(1)").text
      # puts "time : #{time}"
    rescue
      if failStack == 4
        # puts "실패"
        return 0
      else
        # puts "재시도..."
        return collect_rest_data_clien(urlId, failStack+1)
      end
    end
    
    return @browser2
  end
  
  def data_write_clien(data)
    data.each do |currentData|
      @previousData = HitProduct.find_by(url: currentData[9])
      puts "[클리앙] Process : Data Writing..."
      
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
        elsif (@previousData.is_sold_out == true && currentData[4] == false)
          @previousData.update(is_sold_out: false)
        end
        
        
        ## RedirectUrl 변경 체크
        if (currentData[11].to_s != @previousData.redirect_url.to_s)
          @previousData.update(redirect_url: currentData[11].to_s)
        end
        
      end
      
      if currentData[10] == ""
        currentData[10] = nil
      end
      
      HitProduct.create(product_id: currentData[0], date: currentData[1], title: currentData[2], website: currentData[3], is_sold_out: currentData[4], view: currentData[5], comment: currentData[6], like: currentData[7], score: currentData[8], url: currentData[9], image_url: currentData[10], redirect_url: currentData[11])
    end
  end
  
  ### 클리앙 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 2)
  def crawl_clien(index, url, failStack)
    begin
      puts "[클리앙 #{index}] 크롤링 시작!"
      @dataArray = Array.new
      
      # @current_page = @page.page_stack
      @browser.navigate().to "https://www.clien.net/service/board/jirum?po=2"
      
      ## find_element랑 find_elements의 차이
      @content = @browser.find_elements(css: 'div.list_item.symph_row')
      
      @content.each do |t|
        @title = t.find_element(css: 'span.list_subject').text
        @view = t.find_element(css: 'span.hit').text.to_i
        @comment = t.find_element(css: "div.list_title > a > span").text.to_i rescue @comment = 0
        @like = t.find_element(css: 'span.list_votes').text.to_i
        @score = eval(ENV["SCORE_CLIEN"])
        @urlId = t.find_element(css: "a").attribute("href").split("/").last.split("?").first
        @url = "https://www.clien.net/service/board/jirum/#{@urlId}"

        @sailStatus = t.find_element(css: "span.icon_info") rescue @sailStatus = false
        if @sailStatus != false
          @sailStatus = true
        end
        
        @browser2 = collect_rest_data_clien(@urlId, 0)
        
        begin
          redirectUrl = @browser2.find_element(css: "a.url").attribute("href")
        rescue
          redirectUrl = nil
        end
        
        if redirectUrl.nil? || redirectUrl.empty?
          begin
            redirectUrl = @browser2.find_element(css: "div.attached_link").text.split(" ")[1]
          rescue
            redirectUrl = nil
          end
          if redirectUrl.nil? || redirectUrl.empty?
            redirectUrl = nil
          end
        end
        
        time = @browser2.find_element(css: "#div_content > div.post_view > div.post_author > span:nth-child(1)").text.to_time - 9.hours
        begin
          imageUrlCollect = @browser2.find_element(css: "img.fr-dib").attribute('src')
        rescue
          imageUrlCollect = nil
        end
        
        if imageUrlCollect != nil && imageUrlCollect.include?("cdn.clien.net") == false
          imageUrl = "#{imageUrlCollect.gsub("http", "https")}"
        elsif imageUrlCollect != nil && imageUrlCollect.include?("cdn.clien.net") == true
          imageUrl = imageUrlCollect
        end
        
        if imageUrl != nil && imageUrl.include?("https://cfile")
          imageUrl = imageUrl.gsub("https:", "http:")
        end
        
        if redirectUrl.nil? || redirectUrl.empty? || (not redirectUrl.include? "http") || (not redirectUrl.include? "https")
          redirectUrl = nil
        end
        
        ## Console 확인용
        # puts "i : #{index}"
        # puts "title : #{@title} / sailStatus : #{@sailStatus}"
        # puts "title : #{@title} / time : #{time} / view : #{@view}"
        # puts "comment : #{@comment} / like : #{@like} / score : #{@score} / url : #{@url}"
        # puts "==============================================="
        
        @dataArray.push(["clien_#{SecureRandom.hex(6)}", time, @title, "클리앙", @sailStatus, @view, @comment, @like, @score, @url, imageUrl, redirectUrl])
        # @newHotDeal = HitProduct.create(product_id: "clien_#{SecureRandom.hex(6)}", date: @time, title: @title, website: "클리앙", is_sold_out: @sailStatus, view: @view, comment: @comment, like: @like, score: @score, url: @url, image_url: @imageUrl)
      end
      
      data_write_clien(@dataArray)
      
      return 1
    rescue Timeout::Error
      # puts "crawl_ppom failStack : #{failStack}"
      # puts "타임아웃 에러 발생, 크롤링 재시작"
      
      if failStack == 1
        return 0
      else
        return crawl_clien(index, url, failStack+1)
      end
    end
  end
  
  def main_clien_chrome
    
    ### 클리앙 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 2)
    2.step(0, -1) do |index|
      @result = crawl_clien(index, "https://www.clien.net/service/board/jirum?po=#{index}", 0)
      # puts "@result : #{@result}"
    end
    
    @browser2.quit
  end
  
  
  ## 모든 플랫폼 크롤링
  cron "40 * * * ? *"
  def running_crawl
    
    if Jets.env == "production"
      Selenium::WebDriver::Chrome.driver_path = "/opt/bin/chrome/chromedriver"
      options = Selenium::WebDriver::Chrome::Options.new(binary:"/opt/bin/chrome/headless-chromium")
      options2 = Selenium::WebDriver::Chrome::Options.new(binary:"/opt/bin/chrome/headless-chromium")
    else
      Selenium::WebDriver::Chrome.driver_path = `which chromedriver-helper`.chomp
      options = Selenium::WebDriver::Chrome::Options.new
      options2 = Selenium::WebDriver::Chrome::Options.new
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
    @browser2 = Selenium::WebDriver.for :chrome, options: options
    
    main_ppom_chrome
    main_ruliweb_chrome
    main_clien_chrome
    main_deal_bada_chrome
    
    @browser.quit
  end
  
end
