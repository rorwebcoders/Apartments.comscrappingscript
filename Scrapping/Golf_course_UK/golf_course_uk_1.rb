require 'nokogiri'
require 'byebug'
require 'csv'
require 'rest-client'

CSV.open('Golf_course_top100.csv', 'wb', { col_sep: '~' }) do |csv|
	csv << ['URL', 'Club Name', 'Address', 'Telephone', 'Website', 'Visitor Info', 'Secretary', 'Architect', 'Head Professional', 'Championships']

	url = 'https://www.top100golfcourses.com'

	doc = Nokogiri::HTML(RestClient.get(url))

	doc.css("li.dropdown.parent-1 > div > ul >li > a").each_with_index do |data, i|
		begin
			puts listing_url = url + data.attr('href')
			page = 1
			loop do
				parsed_page = Nokogiri::HTML(RestClient.get(listing_url + "?page=#{page}"))
				parsed_page.css("header.col-sm-12.course-listing-ranking > h1 > a").each_with_index do |each_data, j|
					begin
						course_url = url + each_data.attr('href')
						title = each_data.text.strip
						course_parsed_page = Nokogiri::HTML(RestClient.get(course_url))
						address = begin course_parsed_page.css('address > strong').text.strip rescue '' end
						telephone = begin course_parsed_page.at_css("li[@itemprop = 'telephone']").text.strip rescue '' end
						website = begin course_parsed_page.at_css("li[@class = 'website'] > p > a").attr('href') rescue '' end
						visitor_info = begin course_parsed_page.at_css("li[@class = 'visitor-info'] > p").text.strip rescue '' end
						secretary = begin course_parsed_page.at_css("li[@class = 'secretary'] > p").text.strip rescue '' end
						architect = begin course_parsed_page.at_css("li[@class = 'architect'] > p").text.strip rescue '' end
						head_professional = begin course_parsed_page.at_css("li[@class = 'head-professional'] > p").text.strip rescue '' end
						championships = begin course_parsed_page.css('div.championship').text.split("\n").join.gsub('Championships hosted:', '') rescue '' end
						csv << [course_url, title, address, telephone, website, visitor_info, secretary, architect, head_professional, championships]
					rescue Exception => e
						puts "------Exception in course url: #{course_url}-----------\n Exception message: #{e.message}"
					end
					
					
				end
				
				break if page >= 10 || parsed_page.css("ul.pagination").empty?
				if !parsed_page.css("ul.pagination").empty? && page > 1
					
					break if !parsed_page.css("li.page-item.disabled").empty?
				end
				puts page += 1
			end
		rescue Exception => e
			puts "------Exception in listing url: #{listing_url}-----------\n Exception message: #{e.message}"
		end
		
		

	end
end

# byebug

# puts url