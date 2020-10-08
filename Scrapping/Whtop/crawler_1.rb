
require 'mechanize'


# -*- encoding : utf-8 -*-
require 'csv'
require 'nokogiri'
require 'open-uri'
# require 'mysql2'
# require 'openssl'
# require 'watir'
# require 'watir-webdriver'
# require 'headless'
# require 'logger'
# require 'final_redirect_url'

STDOUT.sync = true



def get_request(url)
  agent = Mechanize.new
  # agent.set_proxy("p.webshare.io", 80, 'unzwtclv-US-rotate', 'kfxy0xfz4i29')
  search_url = URI::encode(url)
  agent.user_agent_alias = "Windows Mozilla"
  res = agent.get(search_url)

  return res
end



CSV.open("whtop_listing.csv", 'wb', { col_sep: '~' }) do |csv|
	csv << ['Details_url', 'Name', 'Alexa Rating', 'Link Count']

	
	 
	        @i = 2049
	        # @num = 2
	        @num = 300
	        
	loop  do
	 begin
		 puts url = "https://www.whtop.com/directory/pageno/#{@i}" 
		

			res = get_request(url)
			 number = rand(10..20)
			sleep number
		 doc = Nokogiri::HTML.parse(res.body)

			temp_1 = doc.css("div.companies div.company")
			temp_1.each do |t_1|
				detail_url =  "https://www.whtop.com"+t_1.css("div.company-title a")[0]["href"] rescue ""
				name =  t_1.css("div.company-title a")[0].text.strip() rescue ""
				# full_country = t_1.at("span.gray").text.gsub('(',"").gsub(')',"").gsub('-',"").strip() rescue ""
				alexa_rating = t_1.at("span:contains('Alexa Rating')").text.gsub("Alexa Rating","").gsub("▼","").gsub("▲","").strip() rescue ""
				link_count = t_1.at("span:contains('Links Count: ')").parent .text.gsub("Links Count:","").gsub("▼","").gsub("▲","").strip() rescue ""
				puts detail_url.to_s+"~"+name.to_s+"~"+alexa_rating.to_s+"~"+link_count.to_s
				
				csv << [detail_url.to_s, name.to_s, alexa_rating, link_count.to_s]
				csv.flush
			end
	rescue Exception => e
		puts e.message
	end
	break if @i <= @num
	@i=@i-1
	end
end