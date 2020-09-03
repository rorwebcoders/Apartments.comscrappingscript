require 'json'
require 'date'
require 'time'
require 'mechanize'
require 'mysql2'
require 'byebug'
require 'csv'

# Write log immediately
STDOUT.sync = true

# Open a SQLite 3 database file
# $db = SQLite3::Database.open 'testData.db'

# DB tables
# $db.execute "create table IF NOT EXISTS rentals (listingId TEXT, image TEXT, title TEXT, address TEXT, combined_address TEXT, comma_splitted_address TEXT, division TEXT, zip TEXT, beds TEXT, bath TEXT, rent TEXT, unit TEXT, area TEXT, specificType TEXT, URL TEXT);"

$props= eval(File.open('credentials.properties') {|f| f.read })


$connection = Mysql2::Client.new(:host => $props[:db_host], :username => $props[:db_user], :password => $props[:db_pass], :database => $props[:db_name],:encoding=> $props[:encoding])


def get_request(url)
  agent = Mechanize.new
  agent.redirect_ok = true
  # agent.set_proxy("p.webshare.io", 80, 'ssewadpd-rotate', 'ewpc7poi760o')
  search_url = URI::encode(url)
  agent.user_agent_alias = "Windows Mozilla"
  res = agent.get(search_url)

  return res
end

def post_request(url, header, data)
  agent = Mechanize.new
  # agent.set_proxy("p.webshare.io", 80, 'ssewadpd-rotate', 'ewpc7poi760o')
  agent.user_agent_alias = "Windows Mozilla"
  res = agent.post(url, data, header)

  return res
end


def get_details(argJson)
	# puts argJson['url']
	details_page = get_request(argJson['url'])
	html = Nokogiri::HTML(details_page.body)
	
	# byebug
	title = begin html.css("h1.propertyName").text.strip.gsub("'", '') rescue "" end

	address = begin html.css("div.propertyAddress > h2").text.split.join(' ').gsub("'", '') rescue "" end

	combined_address = begin title + ", " + address rescue "" end

	zip = begin address.split.last.strip rescue "" end

	latitude = html.css("meta[@property = 'place:location:latitude']").attr('content').value

	longitude = html.css("meta[@property = 'place:location:longitude']").attr('content').value
    	
	# address = ( address.gsub(/[^0-9A-Za-z]/,"").downcase.start_with? data["title"].gsub(/[^0-9A-Za-z]/,"").downcase ) ? address] : combined_address #combined address

	# if title.start_with?(/[0-9]/)
	# 	final_address = combined_address
	# else
	# 	final_address = address
	# end

	if address.split(',').count > 2
		comma_splitted_add = address
	else
		comma_splitted_add = combined_address
	end

	division = begin html.css("a.neighborhood").text.strip.gsub("'", '') rescue "" end

	begin 
		listing_data = html.css('table[class*="availabilityTable"]')[0].css("tr[class*=rentalGridRow]")
		listing_data.each do |each_data|
			begin
				rental_key = begin each_data.attr('data-rentalkey') rescue "" end
				beds = begin each_data.css("td.beds > span.shortText").text.downcase.gsub('brs', '').gsub('bed', '').gsub('beds', '').gsub('br', '').strip rescue "" end
				baths = begin each_data.css("td.baths > span.shortText").text.downcase.gsub('bas', '').gsub('ba', '').gsub('bath', '').gsub('baths', '').strip rescue "" end
				rent = begin each_data.css("td.rent").text.split('-').first.strip.split.join(' ') rescue "" end
				# unit = begin each_data.css("td.unit").text.strip rescue "" end
				area = begin each_data.css("td.sqft").text.split('-').first.downcase.gsub('sq ft', '').gsub('sf', '').strip rescue "" end
				# byebug
				# $db.execute "insert into rentals values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", [argJson["listingId"], argJson["image"], title, address, final_address, comma_splitted_add, division, zip, beds, baths, rent, unit, area, argJson["specificType"], argJson["url"]]
				if rent != '' && !rent.nil?

					$connection.query("INSERT INTO rentals_thread_2 (listingId, rentalKey, image, title, address, combined_address, division, zip, latitude, longitude, beds, bath, rent, unit, area, specificType, URL) VALUES('#{argJson["listingId"]}', '#{rental_key}', '#{argJson["image"]}','#{title}','#{address}','#{comma_splitted_add}','#{division}','#{zip}', '#{latitude}', '#{longitude}', '#{beds}','#{baths}','#{rent}','','#{area}','#{argJson["specificType"]}','#{argJson["url"]}')")
				end
			rescue => subEx
				puts "--- Exception in getting details #{subEx.message}"
			end		

		end
	rescue  => subEx
		puts "--- Exception in getting details #{subEx.message}"
	end

end



def get_listing( listing_filter )
	url = "https://www.apartments.com/services/search/"
	# data = "{\"Map\":{\"Resolution\":null,\"BoundingBox\":{\"LowerRight\":{\"Latitude\":23.76365,\"Longitude\":-63.99061},\"UpperLeft\":{\"Latitude\":55.40308,\"Longitude\":-129.29335}},\"CountryCode\":\"US\",\"Shape\":null},\"Geography\":{\"ID\":null,\"PlaceId\":null,\"Display\":null,\"GeographyType\":7,\"Address\":{\"City\":null,\"County\":null,\"PostalCode\":null,\"State\":null,\"StreetName\":null,\"StreetNumber\":null,\"Title\":null,\"Abbreviation\":null,\"BuildingName\":null,\"CollegeCampusName\":null,\"MarketName\":null,\"DMA\":null},\"Location\":{\"Latitude\":39.58336,\"Longitude\":-96.64198},\"BoundingBox\":null,\"O\":null,\"Radius\":null,\"v\":null},\"Listing\":{\"MinRentAmount\":null,\"MaxRentAmount\":null,\"MinBeds\":null,\"MaxBeds\":null,\"MinBaths\":null,\"PetFriendly\":null,\"Style\":#{style},\"Specialties\":null,\"StudentHousingPricings\":null,\"StudentHousingAmenities\":null,\"StudentHousings\":null,\"Ratings\":null,\"Amenities\":null,\"MinSquareFeet\":null,\"MaxSquareFeet\":null,\"GreenCertifications\":null,\"Keywords\":null},\"Transportation\":null,\"StateKey\":null,\"Paging\":{\"Page\":\"#{page}\",\"CurrentPageListingKey\":null},\"SortOption\":1,\"Mode\":null,\"IsExtentLoad\":null,\"IsBoundedSearch\":null,\"ResultSeed\":769486,\"SearchView\":null,\"MapMode\":null,\"Options\":1,\"SavedSearchKey\":null}"

	# data = "{\"Map\":{\"BoundingBox\":{\"LowerRight\":{\"Latitude\":41.87813,\"Longitude\":-87.61083},\"UpperLeft\":{\"Latitude\":41.93077,\"Longitude\":-87.70413}}},\"Geography\":{\"ID\":\"gc87d5z\",\"Display\":\"60642, Chicago, IL\",\"GeographyType\":3,\"Address\":{\"City\":\"Chicago\",\"PostalCode\":\"60642\",\"State\":\"IL\"},\"Location\":{\"Latitude\":41.904,\"Longitude\":-87.656},\"BoundingBox\":{\"LowerRight\":{\"Latitude\":41.88883,\"Longitude\":-87.64478},\"UpperLeft\":{\"Latitude\":41.9185,\"Longitude\":-87.66788}},\"v\":26537},\"Listing\":{\"Style\":#{style},\"MinBeds\":\"#{each_bed_type[0]}\",\"MaxBeds\":#{each_bed_type[1]}},\"Paging\":{\"Page\":\"#{page}\"},\"IsBoundedSearch\":true,\"ResultSeed\":282033,\"Options\":1}"

	# data = "{\"Map\":{\"BoundingBox\":{\"LowerRight\":{\"Latitude\":41.89119,\"Longitude\":-87.61913},\"UpperLeft\":{\"Latitude\":41.92224,\"Longitude\":-87.71243}}},\"Geography\":{\"ID\":\"vyyl9kd\",\"Display\":\"60622, Chicago, IL\",\"GeographyType\":3,\"Address\":{\"City\":\"Chicago\",\"PostalCode\":\"60622\",\"State\":\"IL\"},\"Location\":{\"Latitude\":41.903,\"Longitude\":-87.685},\"BoundingBox\":{\"LowerRight\":{\"Latitude\":41.88873,\"Longitude\":-87.66213},\"UpperLeft\":{\"Latitude\":41.91799,\"Longitude\":-87.70698}},\"v\":26519},\"Listing\": #{listing_filter.reject{|k,v| ["page","type","priceSort","zip","city","state"].include? k }.to_json},\"Paging\":{\"Page\":\"#{listing_filter["page"]}\"},\"IsBoundedSearch\":true,\"ResultSeed\":177273,\"SortOption\":#{listing_filter["priceSort"]},\"Options\":1}"

	data = "{\"Map\":{\"Shape\":null},\"Geography\":{\"ID\":\"mfw6jhk\",\"Display\":\"#{listing_filter["zip"]}, #{listing_filter["city"]}, #{listing_filter["state"]}\",\"GeographyType\":3,\"Address\":{\"City\":\"#{listing_filter["city"]}\",\"PostalCode\":\"#{listing_filter["zip"]}\",\"State\":\"#{listing_filter["state"]}\"}},\"Listing\": #{listing_filter.reject{|k,v| ["page","type","priceSort","zip","city","state"].include? k }.to_json},\"Paging\":{\"Page\":\"#{listing_filter["page"]}\"},\"SortOption\":#{listing_filter["priceSort"]},\"Options\":1}"
	header = {'Content-Type' => 'application/json'}

	# puts "Data : #{data}"

	# begin
		response = post_request(url, header, data)
	# rescue
	# end

	return response
end


def get_pagination_request( listing_filter, check )

	header = "\n------------------------------- Scrapping Style : #{listing_filter["Style"]}"
	header = header + " | Beds : #{listing_filter["MinBeds"]} - #{listing_filter["MaxBeds"]}"  if listing_filter.key? ("MinBeds")  or  listing_filter.key? ("MaxBeds")
	header = header + " | Sq.Ft : #{listing_filter["MinSquareFeet"]} - #{listing_filter["MaxSquareFeet"]}"  if listing_filter.key? ("MinSquareFeet")  or  listing_filter.key? ("MaxSquareFeet")
	header = header + " | Price : #{listing_filter["price"]}"  if listing_filter.key? ("price")

	puts header if !check

	filter_check = -2
	page = 1
	begin
		loop do 		
			listing_filter["page"] = page

			json = {}

			listExcep = 0
			listingRespFlag = true
			3.times do
				begin
					# byebug
					response = get_listing( listing_filter )
					json = JSON.parse(response.body)
					break
				rescue Exception => subEx
					listingRespFlag = false
					puts "\tException at #{listExcep} time trying in listing fetching : #{subEx.message}"   if !check
					# puts "\tException in listing fetching : #{subEx.backtrace}"
					listExcep = listExcep + 1
				end
			end

			if listingRespFlag
				html = Nokogiri::HTML( json["PlacardState"]["HTML"] )

				
				listing = html.css("div#placardContainer > ul > li")

				if listing.count == 0
					
					$connection.query("update us_zip_codes set status = 'done', details = 'No records' where zip_code = '#{listing_filter['zip']}'")
				
				end
	
				if listing.count > 0
					@count_details = @count_details+ json['PinsState']['ResultTitle'].gsub('Available', '').strip+ ','
				end


				# filter required or not , check
				if check
					if ( listing.length > 0 and !listing.last.css(".searchResults").empty? and listing.last.css(".pageRange").text.split(" ").last == "28" )
						filter_check = 1 # filter needed
					elsif listing.length == 0
						filter_check = -1 # no data
					else
						filter_check = 0 # filter not needed
					end

					break
				end

				# puts "Total Listing in this Search filter : #{json["PinsState"]["TotalUnitCount"]}"
				puts "\nTotal listing in Page : #{page} is #{listing.count}"


				lastPage = false
							# byebug
							puts listing.count

				
				listing.each_with_index do |each_list, index|

					lastPage = true if ( !each_list.css(".searchResults").empty? and !each_list.css("#paging > ol > li").last.css("a[aria-label = 'Current Page']").empty? )
					lastPage = true if ( index == listing.count - 1 and each_list.css(".searchResults").empty? )
					$priceFilter = false if ( !each_list.css(".searchResults").empty? and each_list.css(".pageRange").text.split(" ").last == "28" )
					# byebug
					# puts "Price filter : #{$priceFilter}"
					break if ( !each_list.css(".searchResults").empty? )


					begin
						listingId = each_list.css("article").attr("data-listingid").text.strip

						if ( !$listingIds.include? listingId )
							$listingIds << listingId

							puts "List : #{listingId}"
							data = {}
							data["listingId"] = begin listingId rescue "" end
							# data["title"] = begin each_list.css("a.placardTitle").text.strip rescue "" end

							# data["address"] = begin each_list.css(".location").text.strip rescue "" end
							# data["address"] = ( data["address"].gsub(/[^0-9A-Za-z]/,"").downcase.start_with? data["title"].gsub(/[^0-9A-Za-z]/,"").downcase ) ? data["address"] : data["title"] + ", " + data["address"] #combined address


							data["url"] = begin each_list.css("article").attr("data-url").text.strip rescue "" end
							data["image"] = begin each_list.css("div.imageContainer > div.carouselInner > div").attr("style").text.match(/background-image: url\("(.*)?"\)\;/)[1] rescue "" end
							if data["image"] == ""
								data["image"] = begin each_list.css("div.imageContainer > div.carouselInner > div").attr("data-image").text rescue "" end  
							end
							data["reqType"] = listing_filter["type"]
							data["specificType"] = "Apartments" if listing_filter["Style"] == 1
							data["specificType"] = "Condos" if listing_filter["Style"] == 4
							data["specificType"] = "Houses" if listing_filter["Style"] == 2
							data["specificType"] = "Townhouses" if listing_filter["Style"] == 16
							
							propExcep = 0
							3.times do 
								begin
									get_details(data)
									break
								rescue Exception => subEx
									# byebug
									puts "\tException at #{propExcep} time in property block : #{subEx.message}"
									# puts "\tException in property block : #{subEx.backtrace}"
									propExcep = propExcep + 1
								end
							end
						else
							puts "List : #{listingId}  --  Ignored"
						end

					rescue Exception => ex
						# byebug
						puts "\tException in listing block : #{ex.message}"
						# puts "\tException in listing block : #{ex.backtrace}"
					end
					# break
				end
	# byebug
				
			if lastPage
					
					$connection.query("update us_zip_codes set status = 'done', details = '#{@count_details.split(',').uniq.join(',')}' where zip_code = '#{listing_filter['zip']}'")
				end
				break if lastPage or listing.count == 0
				
			end
			
			page = page + 1

			if page > 28 or !listingRespFlag
				# byebug
				$connection.query("update us_zip_codes set status = 'done', details = '#{@count_details.split(',').uniq.join(',')}' where zip_code = '#{listing_filter['zip']}'")

				break
			end
		end
	rescue Exception => ex
		# byebug
		puts "\tException in listing block : #{ex.message}"
		$connection.query("update us_zip_codes set status = 'Failure', details = 'Error' where zip_code = '#{listing_filter['zip']}'")
		# puts "\tException in listing block : #{ex.backtrace}"
	end

	# returns value as per the filter check
	return filter_check

end


def set_price_filter( listing_filter )
	$priceFilter = true
	# price sort
	[1,2].each do |each_price|

		listing_filter["priceSort"] = each_price
		
		get_pagination_request( listing_filter, false )

		break if $priceFilter
	end
end


def set_squarefeet_filter( listing_filter )

	check = get_pagination_request( listing_filter, true )
		
	if ( check == 1 )
		# Sq feet
		[[nil,900],[900,1500],[1500,2500],[2500,nil],[nil,nil]].each do |each_sq|  # [nil,600],[600,900],[900,1200],[1200,1500],[1500,1800],[1800,2500],[2500,nil],[nil,nil]

			listing_filter.delete("MinSquareFeet")
			listing_filter.delete("MaxSquareFeet")
			listing_filter["MinSquareFeet"] = each_sq[0]  if !each_sq[0].nil?
			listing_filter["MaxSquareFeet"] = each_sq[1]  if !each_sq[1].nil?

			set_price_filter( listing_filter )
		end

	elsif ( check == 0 )
		get_pagination_request( listing_filter, false )
	end

end


def set_bed_filter( listing_filter )
# byebug
	check = get_pagination_request( listing_filter, true )
		
	if ( check == 1 )
		# Bed filter
		[[nil,-1],[nil,1],[1,2],[2,3],[3,4],[4,nil]].each do |each_bed_type|  # 
			# puts "\n<---<--------------- Beds : #{each_bed_type[0]} - #{each_bed_type[1]} "
			listing_filter.delete("MinBeds")
			listing_filter.delete("MaxBeds")
			listing_filter["MinBeds"] = each_bed_type[0]  if !each_bed_type[0].nil?
			listing_filter["MaxBeds"] = "#{each_bed_type[1]}"  if !each_bed_type[1].nil?

			set_squarefeet_filter( listing_filter )
		end

	elsif ( check == 0 )
		get_pagination_request( listing_filter, false )
	end
	
end


def get_listing_details( json )

	puts "---------------------------------------------------------- Scrapping Type - #{json["type"]} --------------------------------------------------------------------"
	
	# apartment - 1, houses - 2, condos - 4, Townhouses - 16
	# if multiple options needed, just add the numbers and give in style
	# style = 5 if type == 'apartments'
	# style = 18 if type == 'homes'
	# byebug	
	$listingIds = []
	listing_filter = {}
	listing_filter["zip"] = json["zip"]
	listing_filter["city"] = json["city"]
	listing_filter["state"] = json["state"]

	# Style filter depending upon input
	styles = [1,4] if json["type"] == 'apartments' # 1,4 - 3,3
	styles = [2,16] if json["type"] == 'homes'  # 2,
	styles.each do |style|
		# puts "\n\n<-------------------------------------------------- Style : #{style} "
		listing_filter["Style"] = style
		listing_filter["type"] = json["type"]

		check = get_pagination_request( listing_filter, true )
			
		if ( check == 1 )
			
			set_bed_filter( listing_filter )

		elsif ( check == 0 )
			get_pagination_request( listing_filter, false )
		end

	end

end

	total_iterations =ARGV[0].to_i
    iteration_count =ARGV[1].to_i 

	
	input_data = $connection.query("select count(*) from us_zip_codes where state = 'CA'")
	puts "Total count : #{total_records=input_data.first['count(*)'].to_i}" #total  row count
    offset = (iteration_count-1)*(total_records/total_iterations)
    puts "Iteration : #{iteration_count}"
    puts "Total Iteration : #{total_iterations}"
    puts "Offset for sql : #{offset}"
    puts "Limit for sql : #{limit = (total_iterations==iteration_count)?(total_records-offset):(total_records/total_iterations)}\n\n"
    apartments = $connection.query("select * from us_zip_codes where state = 'CA' and not status = 'done' ORDER BY 1 limit #{limit} offset #{offset}")

	puts "Scrapping started : #{Time.new}"

	json = {}
	apartments.each do |each_data|
		puts "----------------------------ZIP CODE #{each_data['zip_code']}"
		@count_details = ''
		['apartments','homes'].each do |type| # 
		    json["zip"] = each_data['zip_code']
			json["city"] = each_data['city']
			json["state"] = each_data['state']
			json["type"] = type
			get_listing_details( json )
		end

	end

	puts "Scrapping started : #{Time.new}"

	$connection.close if $connection

