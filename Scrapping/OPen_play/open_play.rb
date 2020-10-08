require 'csv'
require 'nokogiri'
require 'watir'
require 'watir-webdriver'
require 'json'
require 'byebug'
require 'mechanize'

# Selenium::WebDriver::Chrome.driver_path = 'C:/chrome driver/chromedriver.exe'

# browser = Watir::Browser.new :chrome

# url = 'https://www.openplay.co.uk/'

# browser.goto(url)

# byebug

# browser.input(class: 'homepage-inputs').send_keys 'a'

# doc = Nokogiri::HTML(browser.html)

# listing = doc.css("a.hit")

# listing.each do |each_data|

def post_request(url, header, data)
  agent = Mechanize.new
  # agent.set_proxy("p.webshare.io", 80, 'ssewadpd-rotate', 'ewpc7poi760o')
  agent.user_agent_alias = "Windows Mozilla"
  res = agent.post(url, data, header)

  return res
end

def get_details(response, csv)
	json_value = response

	listings = json_value['hits']

	listings.each do |each_data|

		begin
			puts data_url = 'https://www.openplay.co.uk/view/' + each_data['id'].to_s + '/' + each_data['slug']

			puts name = begin each_data['name'] rescue '' end

			description = begin each_data['description'] rescue '' end

			address = begin each_data['address'] rescue '' end

			latitude = begin each_data['_geoloc']['lat'] rescue '' end

			longitude = begin each_data['_geoloc']['lng'] rescue '' end

			op_monday = begin each_data['openingTimes']['monday'] rescue '' end

			op_tuesday = begin each_data['openingTimes']['tuesday'] rescue '' end

			op_wedday = begin each_data['openingTimes']['wednesday'] rescue '' end

			op_thursday = begin each_data['openingTimes']['thursday'] rescue '' end

			op_friday = begin each_data['openingTimes']['friday'] rescue '' end

			op_satday = begin each_data['openingTimes']['saturday'] rescue '' end

			op_sunday = begin each_data['openingTimes']['sunday'] rescue '' end

			phone = begin each_data['phone'] rescue '' end

			email = begin each_data['email'] rescue '' end

			image_2 = ''

			image_3 = ''

			image_4 = ''

			image_5 = ''

			if !each_data['images'].count.positive?
				image_1 = begin each_data['image'] rescue '' end
			else
				image_1 = begin 'https://www.openplay.co.uk' + each_data['images'][0]['image'] rescue '' end

				image_2 = begin 'https://www.openplay.co.uk' + each_data['images'][1]['image'] if each_data['images'].count > 1 rescue '' end
				
				image_3 = begin 'https://www.openplay.co.uk' + each_data['images'][2]['image'] if each_data['images'].count > 2 rescue '' end
				
				image_4 = begin 'https://www.openplay.co.uk' + each_data['images'][3]['image'] if each_data['images'].count > 3 rescue '' end

				image_5 = begin 'https://www.openplay.co.uk' + each_data['images'][4]['image'] if each_data['images'].count > 4 rescue '' end
			end
			
			each_data['uses'].each do |each_game|
				csv << [data_url, name, description, address, latitude, longitude, op_monday, op_tuesday, op_wedday, op_thursday, op_friday, op_satday, op_sunday, phone, email, image_1, image_2, image_3, image_4, image_5, each_game]
			end
		rescue Exception => e
			puts "---------Exception in listing #{data_url}\n Exception message : #{e.message}"
		end

		
	end
end

CSV.open('open_play_Output_updated_check.csv', 'wb', { col_sep: '~' }) do |csv|
	csv << ['url', 'name', 'about', 'address', 'latitude', 'longitude', 'opening_hours_monday', 'opening_hours_tusday', 	'opening_hours_wednesday', 'opening_hours_thursday', 'opening_hours_friday', 'opening_hours_saturday', 'opening_hours_sunday', 'phone', 'email', 'image_1', 'image_2', 'image_3', 'image_4', 'image_5', 'Sports']

	url = "https://9z2yotkiyr-dsn.algolia.net/1/indexes/production_openplay_places/query?x-algolia-api-key=dc1cfbe934843996ad30441fe30f5492&x-algolia-application-id=9Z2YOTKIYR&x-algolia-agent=Algolia%20for%20vanilla%20JavaScript%203.9.0"

	header = {'Content-Type' => 'application/x-www-form-urlencoded'}

	data = "{\"params\":\"query=&facets=*&facetFilters=%5B%5D&getRankingInfo=1&page=0\"}"

	response = post_request(url, header, data)


	json_data = JSON.parse(response.body)

	sports = json_data['facets']['uses']

	# sports = [["Athletics",6]]

	alphabet_array = [*('a'..'z')]
	# alphabet_array = ['z', 'q']

	# loop do

		sports.each do |each_sport|
			begin
				page = 0
				# sports_name = ["uses:#{each_sport[0]}"].to_s
				encoded_uri = CGI.escape("[\"uses:#{each_sport[0]}\"]")
				if each_sport[1].to_i > 1000
				
					alphabet_array.each do |alphabet|
						begin
							loop do
								data = "{\"params\":\"query=#{alphabet}&facets=*&facetFilters=#{encoded_uri}&getRankingInfo=1&page=#{page}\"}"
								3.times do
									begin
										post_response = post_request(url, header, data)
										
										response = JSON.parse(post_response.body)
								byebug
										get_details(response, csv)
										break
									rescue Exception => subEx
										
										puts "\tException  : at getting details for sport #{each_sport[0]}:   #{subEx.message}"
										
									end
								end
								break if page >= response['nbPages'].to_i
								page += 1
							end
						rescue Exception => e
							puts "---------Exception in alphabet #{alphabet}\n Exception message : #{e.message}"
						end
						

					end
				
				end
			rescue Exception => e
				puts "---------Exception in sport #{each_sport[0]}\n Exception message : #{e.message}"
			end
			
		end
		# break if page >= json_data['nbPages'].to_i
		# page += 1
	# end
end



# puts response.body