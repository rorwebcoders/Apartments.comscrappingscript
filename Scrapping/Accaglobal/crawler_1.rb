
# -*- encoding : utf-8 -*-
require 'csv'
require 'nokogiri'
require 'open-uri'
require 'mysql2'
require 'openssl'
require 'watir'
require 'byebug'

input_data = CSV.read('Acca_input.csv', headers: true)
input_data.each do |data|


	name = data['Name']
	url = data['URL']

	CSV.open("AccaGlobal_Output_#{name}_test.csv", "wb") do |csv|
		csv << ['URL', 'Name', 'Address', 'Website', 'Email', 'Phone', 'Partners']

	 
		@i = 1
		@num = 100
		@req = 1
		        
		loop do

			if @i % 5 == 0
				@req = @req+1
			
			end	

			
				puts search_url = url.to_s.gsub('pagenumber=1',"pagenumber=#{@i}").gsub('requestcount=1',"requestcount=#{@req}").gsub('resultsperpage=5','resultsperpage=25')
				# byebug

		 	  # search_url = "https://www.accaglobal.com/uk/en/member/find-an-accountant/find-firm/results.html?isocountry=GB&location=Slough&country=UK&firmname=&organisationid=ACCA&hid=&pagenumber=#{@i}&resultsperpage=25&requestcount=#{@req}"  
		      doc = Nokogiri::HTML(open(search_url))
		      
		 	 temp_1 = doc.css("table.table-responsive.firm-search-results.expandable-rows tr")     
		 	temp_1.each do |t_1|
	 		if !t_1.to_s.include?'expandable'
	 		
		 		
		 		 puts detail_url = "https://www.accaglobal.com"+t_1.css("a.detailsLink")[0]["href"] rescue ""
		 		 puts name = t_1.css("a.detailsLink")[0].text rescue ""
		 		 address = t_1.css("td")[0].to_s.split("</h5>").last.split("</td>").first.split("<p>").first.gsub("<br>"," ").gsub('<div style="text-transform: capitalize">'," ").gsub("</div>"," ").gsub("\n"," ").gsub("\t","").gsub("  "," ").strip() rescue  ""
		 		 email = t_1.css("a.no-external")[0]["href"].gsub("mailto:","") rescue  ""
		 		 website = t_1.css("a.no-external")[1]["href"] rescue  ""

		 		 phone_temp = t_1.css("td")[1].css("ul").to_s.split("<li>").last rescue ""

		 		 if(phone_temp != "" && !phone_temp.include?("</a>"))

		 		 	 phone = phone_temp.split("</li>").first rescue ""
		 		 end
		 		 # .split("li").last rescue ""

		 		if detail_url != ""
		 			doc_1 = Nokogiri::HTML(open(detail_url))
					if doc_1.at('h5:contains("Firm partners")')
						partners =  doc_1.at('h5:contains("Firm partners")').next_element.text.strip()

					end
						csv << [detail_url.to_s, name.to_s, address.to_s, website.to_s, email.to_s, phone.to_s, partners.to_s]
						csv.flush
		 		end
		 	end
		 	end
		 	
# byebug
		 break if !doc.at_css('li.next.inactive').nil?

		@i=@i+1
	end
		
	end
end