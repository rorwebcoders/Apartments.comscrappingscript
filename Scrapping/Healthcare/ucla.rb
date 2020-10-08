
# -*- encoding : utf-8 -*-
require 'csv'
require 'nokogiri'
require 'open-uri'
require 'mysql2'
require 'openssl'
require 'watir'
# require 'watir-webdriver'
# require 'headless'
require 'byebug'

Selenium::WebDriver::Chrome.driver_path = 'C:/chrome driver/chromedriver.exe'

CSV.open('ucla_output_2.csv', 'wb', col_sep: '~') do |csv|
  csv << ['url', 'Name', 'Category', 'Phone', 'email', 'address', 'signature1', 'signature2', 'signature3', 'advisor', 'Description'] 
	browser =  Watir::Browser.new :chrome
	# browser.window.maximize


		lis=["Academic","African American","Arts","Asian","Asian Pacific Islander","Business","Career Planning","Chicano/Chicana","Club Sports","Community Service","Cultural","Cultural/Ethnic","Dance","Dental","Educational","Engineering","Environmental","Ethnic","Faculty/Staff","Film","Fitness","GSA Affiliated","Greek Life - Co-Ed","Greek Life - Fraternities","Greek Life - Sororities","Health and Wellness","Honor Societies","International Students","Journals","LGBTQI","Latino/Latina","Law","Leadership","Martial Arts","Media","Medical","Music","Out-of-state Students","Political","Pre-Professional","Recreation","Religious","Religious - Christian","Religious - Jewish","Religious - Muslim","Residential Life","Self Improvement","Self Improvement - Exercise","Self Improvement - Meditation","Service","Service - Community Involvement","Service - Outreach","Service - Retention","Social","Social Activism","Spirit/Booster","Sports","Student Government","Student Government - GSA Affiliated","Student Government - USAC Affiliated","Technology","Theater","Transfer Students"]


		lis.each do |l|

			    	search_url = URI::encode("https://sa.ucla.edu/RCO/public/search?category=#{l}")
			   # doc = Nokogiri::HTML(open(search_url))
			   
				browser.goto search_url
				sleep 2
				doc = Nokogiri::HTML.parse(browser.html)
					temp_1 = doc.css("div.margin-10")

					temp_1.each do |t_1|
						  header = t_1.css("div.row.bold")[0].text.strip() rescue ""
						 description = t_1.css("div")[1].text.strip.gsub(/\r/,"").gsub(/\n/,"") rescue ""
						  category =  t_1.at('div:contains("Category:")').text.to_s.gsub("Category:","").gsub("  "," ").strip() rescue ""
						  phone_number =  t_1.at('div:contains("Phone Number:")').text.to_s.split("Email:").first.gsub("Phone Number:","").gsub("  "," ").strip() rescue ""
						  email =  t_1.at('div:contains("Email:")').text.to_s.split("Email:").last.gsub("Email:","").gsub("  "," ").strip() rescue ""
						  website =  t_1.at('div:contains("Website:")').text.to_s.gsub("Website:","").gsub("  "," ").strip() rescue ""
						  signature1 =  t_1.at('div:contains("Signatory 1:")').text.to_s.split("Signatory 2:").first.gsub("Signatory 1:","").gsub("  "," ").strip() rescue ""
						  signature2 =  t_1.at('div:contains("Signatory 2:")').text.to_s.split("Signatory 2:").last.split("Signatory 3:").first.gsub("Signatory 2:","").gsub("  "," ").strip() rescue ""
						  signature3 =  t_1.at('div:contains("Signatory 3:")').text.to_s.split("Signatory 3:").last.gsub("Signatory 3:","").gsub("  "," ").strip() rescue ""
						  advisor =  t_1.at('div:contains("Advisor:")').text.to_s.gsub("Advisor:","").split.join(' ') rescue ""
						  puts search_url+"~"+header+"~"+category+"~"+phone_number+"~"+email+"~"+website+"~"+signature1+"~"+signature2+"~"+signature3+"~"+advisor
						  
						  csv << [search_url, header, category, phone_number, email, website, signature1, signature2, signature3, advisor, description]

					end

			   # .next_element.next_element
		end

	end