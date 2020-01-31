## 크롤링에 있어 문제 발생 시, 관리자들에게 메일로 발생이 됩니다.
# ChromeCheckJob.perform_now(:chrome_check)

class ChromeCheckJob < ApplicationJob
	
	rate "1 year"
	def main_chromium_check_chrome
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
		
		begin
			@browser = Selenium::WebDriver.for :chrome, options: options # 실레니움 + 크롬 + 헤드리스 옵션으로 브라우저 실행
			#@errorMessage = $!
			#SendmailMailer.email_notification(@errorMessage).deliver_now
		rescue
			puts "에러 발생! 관리자에게 메일이 발송됩니다.."
			@errorMessage = $!
			AdminMailer.alert(@errorMessage).deliver_now
		end
		
		@browser.quit
	end
end
