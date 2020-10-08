require 'csv'
require 'byebug'
require 'nokogiri'
require 'watir'
require 'rest-client'

CSV.open("Bayut_Output.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['URL', 'Company Name', 'Name', 'Email', 'Proxy Mobile', 'Proxy Phone', 'Phone', 'Mobile', 'Languages', 'Specialities', 'Area', 'Country', 'Experience', 'About']
	page = 1

	loop do
		if page == 1
			url = 'https://www.bayut.com/companies/search/'
			
		else
			url = "https://www.bayut.com/companies/search/page-#{page}"
			puts "---------------------#{url}----------------------"
		end

			doc = Nokogiri::HTML(RestClient.get(url))

			doc.css('article').each do |each_data|
				puts agency_url = "https://www.bayut.com" + each_data.at('a').attr('href')
				
				agency_doc =  Nokogiri::HTML(RestClient.get(agency_url))

				json_data = JSON.parse(agency_doc.css('script')[6].text.gsub('window.state = ', '').split('window.webpackBundles').first.strip.gsub(';',''))

				json_data['agency']['data']['agents'].each do |each_agents|
					name = begin each_agents['name'] rescue '' end

					about = begin each_agents['about_user'] rescue '' end

					email = begin each_agents['email'] rescue '' end

					proxy_mobile = begin each_agents['proxy_mobile'] rescue '' end

					proxy_phone = begin each_agents['proxy_phone'] rescue '' end

					phone_number = begin each_agents['phone_numbers'] rescue '' end

					cell_number = begin each_agents['cell_numbers'] rescue '' end

					landline = ''
					begin
						phone_number.each do |each_phone|
							landline = landline + each_phone + ','
						end

						landline = landline.split(',').join(', ')
					rescue
					end
					
					mobile = ''

					begin
						cell_number.each do |each_phone|
							mobile = mobile + each_phone + ','
						end

						mobile = mobile.split(',').join(', ')
					rescue					
					end
					

					languages = begin each_agents['user_langs'] rescue '' end 

					lang = ''
					begin
						languages.each do |each_phone|
							lang = lang + each_phone + ','
						end
						lang = lang.split(',').join(', ')
					rescue
					end
					

					speciality = begin each_agents['specialities'] rescue '' end

					spec = ''
					begin
						speciality.each do |each_phone|
							spec = spec + each_phone + ','
						end

						spec = spec.split(',').join(', ')
					rescue
					end
					

					service_area = begin each_agents['service_areas'] rescue '' end

					area = ''
					begin
						service_area.each do |each_phone|
							area = area + each_phone + ','
						end

						area = area.split(',').join(', ')

					rescue
					end
					
					company_name = begin each_agents['agency']['name'] rescue '' end

					country = begin each_agents['country'] rescue '' end

					experience = each_agents['experience'].to_i
 
					begin experience =  2020 - each_agents['experience'].to_i if experience > 100 rescue '' end

					url = begin 'https://www.bayut.com/brokers/' + each_agents['slug'] + '.html' rescue '' end

					csv << [url, company_name, name, email, proxy_mobile, proxy_phone, landline, mobile, lang, spec, area, country, experience, about]
				end
			end
			
		break if doc.at_css("div[@title ='Next']").nil?
		page += 1
	end
end

# puts url