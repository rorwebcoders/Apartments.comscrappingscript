require 'watir'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'csv'
require 'byebug'

Selenium::WebDriver::Chrome.driver_path = 'C:/chrome driver/chromedriver.exe'
# Selenium::WebDriver::Firefox.driver_path = 'C:/GeckoDriver/geckodriver.exe'

driver = Watir::Browser.new :chrome,args: ['user-data-dir=C:\Users\91787\AppData\Local\Google\Chrome\User Data']

file = CSV.read('Real_estate_output_carla.csv', headers: true)

file.each do |data|
	begin
		url = data['agent_url']

		driver.goto(url)
		sleep 5

		driver.labels(class: ["toggle-button", "toggle-button--column"])[3].click

		driver.button(text: 'Next').click

		name = 'Carla'

		driver.input(id: 'consumer-name').send_keys name.to_s

		message = "Hi,\n\nThis is Carla from Jarda Constuction. If you know anyone that needs a builder, we’d be more than happy to offer a finders fee to any contracts you brings us.\n\nWith over 500 homes built in Melbourne & 75 under construction at the moment, we’re keen to expand our company in the next few months.\n\nThank you,\n\nCarla"

		driver.textarea(id: 'contact-message').send_keys message.to_s

		driver.spans(class: 'construct-radio__label')[1].click

		phone = '0452619559'

		driver.input(id: 'consumer-phone').send_keys phone.to_s

		email = 'carlageorgescu94@yahoo.com'

		driver.input(id: 'consumer-email').send_keys email.to_s

		driver.button(text: 'Send enquiry').click

		number = rand(10..15)
		puts "--------------------Completed : #{url}--------------------------\n"

		# sleep number.to_i
		sleep 3
	rescue Exception => e
		puts "-----\nException in  agent: #{url}\n   Exception Type : #{e.class}\n   Exception Message : #{e.message}\n-----"
	end
	
	
end