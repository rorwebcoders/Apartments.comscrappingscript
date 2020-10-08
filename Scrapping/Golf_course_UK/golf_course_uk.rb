require 'nokogiri'
require 'byebug'
require 'csv'
require 'rest-client'

CSV.open('Golf_course.csv', 'wb', { col_sep: '~' }) do |csv|
	csv << ['URL', 'Club Name', 'Address', 'Telephone', 'Website', 'Email', 'Type', 'Length', 'Par']

	url = 'https://www.englishgolf-courses.co.uk/atoz.html'

	doc = Nokogiri::HTML(RestClient.get(url))

	doc.css("div.row > div.col-sm-4 > a").each_with_index do |data, i|
		begin
			course_url = 'https://www.englishgolf-courses.co.uk' + data.attr('href')
			parsed_page = Nokogiri::HTML(RestClient.get(course_url))
			title = begin parsed_page.css("div.col-sm-8 > h1").text rescue '' end
			address =  begin parsed_page.css("div.col-sm-8 > strong").text.split('Address:').last.strip rescue '' end
			website = begin parsed_page.at('p:contains("Website:")').text.split(':').last.strip rescue '' end
			email = begin parsed_page.at('p:contains("Email:")').text.split(':').last.strip rescue '' end
			type = begin parsed_page.at('span:contains("Type:")').text.split(':').last.strip rescue '' end
			length = begin parsed_page.at('span:contains("Length:")').text.split(':').last.strip rescue '' end
			par = begin parsed_page.at('span:contains("Par:")').text.split(':').last.strip rescue '' end
			telephone = begin parsed_page.at('span:contains(" Telephone:")').text.split(':').last.strip rescue '' end
			csv << [course_url, title, address, telephone, website, email, type, length, par]
		rescue Exception => e
			puts "-------------Exception in url: #{course_url}---------\n Exception message: #{e.message}"
		end
		# break if i >= 10
			

	end
end

# byebug

# puts doc