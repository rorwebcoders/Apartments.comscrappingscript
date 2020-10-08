require 'csv'
require 'byebug'
require 'nokogiri'
require 'watir'
require 'rest-client'
require 'mysql2'

$connection = Mysql2::Client.new(:host => 'localhost', :username => 'root', :password => 'Sudhaviki@1624', :database => 'scrapping')


# # Selenium::WebDriver::Chrome.driver_path = 'C:/chrome driver/chromedriver.exe'
# Selenium::WebDriver::Firefox.driver_path = 'C:/GeckoDriver/geckodriver.exe'
	
# driver = Watir::Browser.new :firefox
# byebug
input_data =  $connection.query("SELECT * from whtop")
# input_data =  CSV.read('Whtop_input.csv', headers: true)

# def get_request(url)
#   agent = Mechanize.new
#   agent.redirect_ok = true
#   agent.set_proxy("p.webshare.io", 80, 'dujgdxtb-rotate', '1g2np6qimr51')
#   search_url = URI::encode(url)
#   agent.user_agent_alias = "Windows Mozilla"
#   res = agent.get(search_url)

#   return res
# end

CSV.open("Whtop_details_#{Time.now.to_i}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['URL', 'Country', 'Phone', 'Email', 'Category', 'Platform', 'Pleice Range', 'Min Price', 'Max Price', 'Currency', 'Website', 'Facebook', 'Twitter', 'Linked', 'Youtube', 'Instagram', 'Description', 'HTML']

	input_data.each_with_index do |data, i|
		begin
			url = data['URL']

			html = data['html']

			# response = get_request(url)

			# doc = Nokogiri::HTML(response.body)

			# driver.goto(url)

			# sleep 5
			
			doc = Nokogiri::HTML(html)

			tags = doc.css("div.aj").to_html.to_s.split('Services: ').last.split(' | Redirected domains: ').first

			tags_html = Nokogiri::HTML(tags)

			country_code = begin doc.css("abbr[@property = 'addressCountry']").text rescue '' end

			country = begin doc.css("abbr[@property = 'addressCountry']").attr('title').value rescue '' end

			phone = ''
			begin
				doc.css("span[@property = 'telephone']").each do |each_ph|
					phone = phone + each_ph.text.strip + ','
				end

				phone = phone.split(',').join(', ')
				
			rescue
			end	
# byebug
			email = begin doc.css("abbr[@property = 'email']").attr('content').value rescue '' end

			price_range = begin doc.css("span[@property = 'priceRange']").text rescue '' end

			min_price = begin price_range.split('-').first.strip rescue '' end

			max_price = begin price_range.split('-').last.strip rescue '' end

			currency = begin doc.at("span:contains('Offer Currency') > span.value").text rescue '' end

			website = begin doc.css("link[@property = 'url']").attr('href').value rescue '' end

			facebook = begin doc.css("div.network.facebook.aj > a").attr('href').value rescue '' end

			twitter = begin doc.css("div.network.twitter.aj > a").attr('href').value rescue '' end

			linked_in = begin doc.css("div.network.linkedin > a").attr('href').value rescue '' end

			you_tube = begin doc.css("div.network.youtube > a").attr('href').value rescue '' end

			instagram = begin doc.css("div.network.instagram > a").attr('href').value rescue '' end

			des = begin doc.css("div.aj").to_html.split('<br>').reverse[0..-3].reverse.join.split('Special pages').first rescue '' end
			begin	
				des_doc = Nokogiri::HTML(des)

				description = des_doc.text.split('Server locations:').first.strip
			rescue
			end
			category = ''
			platform = ''
			category_1 = ''
			begin
				doc.css("table.table.center > tbody > tr").each do |each_row|
					if each_row.css("th").count > 1
						begin category = (category + each_row.css("th")[0].text.split('-').first.strip + ',') if each_row.css("th")[0].text.split('-').count > 1 rescue '' end
						
						begin platform = (platform + each_row.css("th")[0].text.split('-').last.strip + ',') if each_row.css("th")[0].text.split('-').count > 1 rescue '' end
						
						begin category_1 = (category_1 + each_row.css("th")[0].text.strip + ',') if each_row.css("th")[0].text.split('-').count == 1 rescue '' end

						
					end
				end
				platform = platform.gsub('Linux/Windows', 'Linux,Windows').split(',').map(&:strip).uniq.join(', ')

			  category_final = (category + category_1).split(',').join(', ')
			  
			  category_final = category_final.split(',').map(&:strip).uniq.join(', ')
			
			rescue Exception => e
				puts "-----\nException in fecthing category URL: #{url}\n   Exception Type : #{e.class}\n   Exception Message : #{e.message}\n-----"
			end
			# byebug
		  csv << [url, country, phone, email, category_final, platform, price_range, min_price, max_price, currency, website, facebook, twitter, linked_in, you_tube, instagram, description]
		  csv.flush

		  $connection.query("UPDATE whtop set Flag = 'Y', html = '#{doc.to_s.gsub("'", '')}' where URL = '#{url}'")
		  # break if i > 500
		rescue Exception => e
			puts "-----\nException in  URL: #{url}\n   Exception Type : #{e.class}\n   Exception Message : #{e.message}\n-----"
			$connection.query("UPDATE whtop set Flag = 'N' where URL = '#{url}'")
		end
	
	 
	end

end