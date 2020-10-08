require 'csv'
require 'nokogiri'
require 'watir'
require 'watir-webdriver'
require 'json'
require 'byebug'
require 'mechanize'

puts "---------Starting Time#{Time.now}------------------"



# Selenium::WebDriver::Chrome.driver_path = 'C:/chrome driver/chromedriver.exe'

browser = Watir::Browser.new :firefox#,args: ['user-data-dir=C:/Users/91787/AppData/Local/Google/Chrome/User Data']

CSV.open("open_play_details_updated_#{ARGV[0]}.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['url', 'website', 'sport_name','members_only', 'surface', 'Indoor/Outdoor', 'showers', 'hospitality', 'equipment_rental', 'changing_rooms','pay_as_you_play', 'floodlights', 'car_parking_string', 'car_parking_yes_no', 'number_of_courts'
]

	input = CSV.read("Open_Play_Input_#{ARGV[0]}.csv", headers: true)

	browser.goto('https://www.openplay.co.uk')

	sleep 30

	input.each do |data|
	begin
			url = data['url']
		# url = "https://www.openplay.co.uk/view/1138/cranleigh-golf-and-country-club"

		
		browser.goto(url)
		sleep 3

		doc = Nokogiri::HTML(browser.html)

		website = begin doc.at_css("i.fa.fa-globe.color-green").next_element.text.strip rescue '' end


		listing = doc.css("div.panel.panel-default")

		sports_array = []

		doc.css("span.search-sport").each do |each_sport|
			sports_array.push(each_sport.text)
		end
		sports_in = []
		
		if !doc.css("div.panel.panel-default").nil? && listing.count > 0
 			
				listing.each do |each_data|
					sport_name = each_data.css("h4.panel-title").text.strip
					sports_in.push(sport_name)
						details = each_data.css("div.col-md-6")
						membership = ""
						surface = '-'
						indoor = ''
						showers = 'FALSE'
						hospitality = ''
						rental = 'FALSE'
						changing_rooms = 'FALSE'
						pay_as = 'FALSE'
						floodlights = 'FALSE'
						car_parking_string = ''
						car_parking_yes = ''
						courts = ''
						# details.each do |each_details|
							membership = begin 'TRUE' if details.at('small:contains("Membership Required:")').text.gsub('Membership Required:', '').strip.downcase == "yes" rescue membership = "FALSE" end
							if (membership == "" || membership.nil?)
								membership = begin 'FALSE' if details.at('small:contains("Membership Required:")').text.gsub('Membership Required:', '').strip.downcase == "no" rescue membership = "FALSE" end
							end

							surface = begin details.at('small:contains("Surface:")').text.gsub('Surface:', '').strip rescue surface = '-' end
							if surface.split(',').count > 1
								surface = begin surface.split(',')  rescue surface = "-" end
							end
							

							indoor = begin details.at('small:contains("Indoor/Outdoor:")').text.gsub('Indoor/Outdoor:', '').strip rescue indoor = '' end
							showers = begin 'TRUE' if details.at('small:contains("Showers:")').text.gsub('Showers:', '').strip.downcase == "yes" rescue showers = 'FALSE' end
							if (showers == "" || showers.nil?)
								showers = begin 'FALSE' if details.at('small:contains("Showers:")').text.gsub('Showers:', '').strip.downcase == "no" rescue showers = 'FALSE' end
							end
							hospitality = begin details.at('small:contains("Hospitality:")').text.gsub('Hospitality:', '').strip rescue hospitality = '' end

							rental = begin 'TRUE' if details.at('small:contains("Equipment Rental:")').text.gsub('Equipment Rental:', '').strip.downcase == "yes" rescue rental = 'FALSE' end
							if (rental == "" || rental.nil?)
								rental = begin 'FALSE' if details.at('small:contains("Equipment Rental:")').text.gsub('Equipment Rental:', '').strip.downcase == "no" rescue rental = 'FALSE' end
							end
							changing_rooms = begin 'TRUE' if details.at('small:contains("Changing Rooms:")').text.gsub('Changing Rooms:', '').strip.downcase == "yes" rescue changing_rooms = 'FALSE' end
							if (changing_rooms == "" || changing_rooms.nil?)
								changing_rooms = begin 'FALSE' if details.at('small:contains("Changing Rooms:")').text.gsub('Changing Rooms:', '').strip.downcase == "no" rescue changing_rooms = 'FALSE' end
							end
							pay_as = begin 'TRUE' if details.at('small:contains("Pay as you Play:")').text.gsub('Pay as you Play:', '').strip.downcase == "yes" rescue pay_as = 'FALSE' end
							if (pay_as == "" || pay_as.nil?)
								pay_as = begin 'FALSE' if details.at('small:contains("Pay as you Play:")').text.gsub('Pay as you Play:', '').strip.downcase == "no" rescue pay_as = 'FALSE' end
							end
							if (pay_as == "" || pay_as.nil?)
								pay_as = begin details.at('small:contains("Pay as you Play:")').text.gsub('Pay as you Play:', '').strip rescue pay_as = '' end
							end
							floodlights = begin 'TRUE' if details.at('small:contains("Floodlights:")').text.gsub('Floodlights:', '').strip.downcase == "yes" rescue floodlights = 'FALSE' end
							if (floodlights == ""|| floodlights.nil?)
								floodlights = begin 'FALSE' if details.at('small:contains("Floodlights:")').text.gsub('Floodlights:', '').strip.downcase == "no" rescue floodlights = 'FALSE' end
							end	
							car_parking_string = begin details.at('small:contains("Car Parking:")').text.gsub('Car Parking:', '').strip if details.at('small:contains("Car Parking:")').text.gsub('Car Parking:', '').strip.downcase != "yes" rescue car_parking_string = '' end
							car_parking_yes = begin 'TRUE' if details.at('small:contains("Car Parking:")').text.gsub('Car Parking:', '').strip.downcase == "yes" rescue car_parking_yes = '' end
							 
							courts = begin details.at('small:contains("No. of Courts:")').text.gsub('No. of Courts:', '').strip rescue courts = '' end

						# end
						
							csv << [data['url'], website, sport_name, membership, surface, indoor, showers, hospitality, rental, changing_rooms, pay_as, floodlights, car_parking_string, car_parking_yes, courts]
						
				end
				(sports_array - sports_in).each do |sport_out|
					csv << [data['url'], website, sport_out, '', '', '', '', '', '', '', '', '', '', '', '']
				end
		else
			
			each_details = doc.css("div.col-md-5").css("div.clearfix")
			membership = "FALSE"
			surface = ''
			indoor = ''
			showers = 'FALSE'
			hospitality = ''
			rental = 'FALSE'
			changing_rooms = 'FALSE'
			pay_as = 'FALSE'
			floodlights = 'FALSE'
			car_parking_string = ''
			car_parking_yes = ''
			courts = ''
			doc.css("span.search-sport").each do |each_sport|
				
				sport_name = each_sport.text
				
				membership = begin 'TRUE' if each_details.at('small:contains("Membership :")').text.gsub('Membership :', '').strip.downcase == "yes" rescue '' end
				if (membership == "" || membership.nil?)
					membership = begin 'FALSE' if each_details.at('small:contains("Membership :")').text.gsub('Membership :', '').strip.downcase == "no" rescue '' end
				end	
				surface = begin each_details.at('small:contains("Surface :")').text.gsub('Surface :', '').strip rescue surface = "-" end
				 if surface.split(',').count > 1
						surface = begin surface.split(',') rescue surface = "-" end
					end
				indoor = begin each_details.at('small:contains("Indoor/Outdoor :")').text.gsub('Indoor/Outdoor :', '').strip rescue indoor = '' end
				showers = begin 'TRUE' if each_details.at('small:contains("Showers :")').text.gsub('Showers :', '').strip.downcase == "yes" rescue showers = 'FALSE' end
				if (showers == "" || showers.nil?)
					showers = begin 'FALSE' if each_details.at('small:contains("Showers :")').text.gsub('Showers :', '').strip.downcase == "no" rescue showers = 'FALSE' end
				end
				hospitality = begin each_details.at('small:contains("Hospitality :")').text.gsub('Hospitality :', '').strip rescue hospitality = '' end
				rental = begin 'TRUE' if each_details.at('small:contains("Equipment Hire :")').text.gsub('Equipment Hire :', '').strip.downcase == "yes" rescue rental = 'FALSE' end
				if (rental == "" || rental.nil?)
					rental = begin 'FALSE' if each_details.at('small:contains("Equipment Hire :")').text.gsub('Equipment Hire :', '').strip.downcase == "no" rescue rental = 'FALSE' end
				end
				changing_rooms = begin 'TRUE' if each_details.at('small:contains("Changing rooms :")').text.gsub('Changing rooms :', '').strip.downcase == "yes" rescue changing_rooms = 'FALSE' end
				if (changing_rooms == "" || changing_rooms.nil?)
					changing_rooms = begin 'FALSE' if each_details.at('small:contains("Changing rooms :")').text.gsub('Changing rooms :', '').strip.downcase == "no" rescue changing_rooms = 'FALSE' end
				end
				pay_as = begin 'TRUE' if each_details.at('small:contains("Pay and play :")').text.gsub('Pay and play :', '').strip.downcase == "yes" rescue pay_as = 'FALSE' end
				if (pay_as == "" || pay_as.nil?)
					pay_as = begin 'FALSE' if each_details.at('small:contains("Pay and play :")').text.gsub('Pay and play :', '').strip.downcase == "no" rescue pay_as = 'FALSE' end
				end		
				floodlights = begin 'TRUE' if each_details.at('small:contains("Floodlights :")').text.gsub('Floodlights :', '').strip.downcase == "yes" rescue floodlights = 'FALSE' end
				if (floodlights == "" || floodlights.nil?)
					floodlights = begin 'FALSE' if each_details.at('small:contains("Floodlights :")').text.gsub('Floodlights :', '').strip.downcase == "no" rescue floodlights = 'FALSE' end
				end
				car_parking_string = begin each_details.at('small:contains("Car Park :")').text.gsub('Car Park :', '').strip if each_details.at('small:contains("Car Park :")').text.gsub('Car Park :', '').strip.downcase != "yes" rescue '' end
				car_parking_yes = begin 'TRUE' if each_details.at('small:contains("Car Park :")').text.gsub('Car Park :', '').strip.downcase == "yes" rescue car_parking_yes = '' end
				 
				courts = begin each_details.at('small:contains("No. of Courts :")').text.gsub('No. of Courts :', '').strip rescue courts = '' end
					
				csv << [data['url'], website, sport_name, membership, surface, indoor, showers, hospitality, rental, changing_rooms, pay_as, floodlights, car_parking_string, car_parking_yes, courts]
			end
		end
		
	rescue Exception => e
		puts "---------Exception in maik block #{url}\n Exception message : #{e.message}"
	end

	

	end
end
puts "---------Ending Time#{Time.now}------------------"