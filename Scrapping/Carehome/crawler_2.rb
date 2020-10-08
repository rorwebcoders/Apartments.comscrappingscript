
# -*- encoding : utf-8 -*-
require 'csv'
require 'nokogiri'
require 'open-uri'
require 'mysql2'
require 'openssl'
require 'watir'
require 'byebug'

Selenium::WebDriver::Chrome.driver_path = 'C:/chrome driver/chromedriver.exe'

input_data = CSV.read('Carehome_input.csv', headers: true)
input_data.each do |data|


	name = data['Name']
	url = data['URL']

	CSV.open("CareHome_#{name}_Output_1.csv", "wb") do |csv|
		csv << ['URL', 'Name', 'Address', 'Group Name', 'Person In Charge']

		browser = Watir::Browser.new :chrome
		 
		browser.window.maximize
		 @i = 1
		loop  do

		 	puts search_url = url.to_s + "/startpage/#{@i}"
	 	  # puts search_url = "https://www.carehome.co.uk/care_search_results.cfm/searchcounty/London/startpage/27"  
	      browser.goto(search_url)
						byebug
	      doc = Nokogiri::HTML(browser.html)
	      # doc = Nokogiri::HTML(open(search_url))
	      sleep 5
	 	temp_1 = doc.css("div.row.panel.panel-default.mediablock-homesearch")     

	 	temp_1.each do |t_1|
	 		  puts detail_url = t_1.css("div.home-name").css("a")[1]["href"] rescue ""
	 		   name = t_1.css("div.home-name").css("a")[1].text.strip rescue ""

	 		  if detail_url == ""
	 		  puts detail_url = t_1.css("div.home-name").css("a")[0]["href"] rescue ""
	 		   name = t_1.css("div.home-name").css("a")[0].text.strip rescue ""
	 		  end
	 		  
	 		  address = t_1.css("div.home-name").css("p")[1].text.strip rescue ""
	 		 if t_1.at('span:contains("Group:")')
	 		 	 group_name = t_1.at('span:contains("Group:")').next_element.text
	 		 end
	 		 person_inn_charge = ''

	 		if detail_url != ""
	 			byebug
	 			doc_1 = Nokogiri::HTML(open(detail_url))

				if doc_1.at('h4:contains("Person in charge")')
					 person_inn_charge =  doc_1.at('h4:contains("Person in charge")').parent.next_element.text.strip()
					 if group_name == "" || group_name.nil?
					 	group_name = doc_1.at('h4:contains("Group/Owner")').parent.next_element.text.strip() rescue ""
					 end
				end
					 
						csv << [detail_url.to_s, name.to_s, address.to_s, group_name.to_s, person_inn_charge.to_s]

			end
	 	end

	 	if @i > 1
	 		# byebug
	 		if !doc.css('a.btn.btn-ghost.btn-ghost-small').text.downcase.include? 'next'
	 			break
	 		end
	 	end
		@i=@i+1
		end
	end
end