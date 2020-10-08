require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'watir'
require 'byebug'
require 'csv'

Selenium::WebDriver::Chrome.driver_path = 'C:/chrome driver/chromedriver.exe'

CSV.open('procore_community.csv', 'wb', col_sep: '~') do |csv|
  csv << ['Name', 'Title', 'Manager', 'Company Name', 'About me', 'Email', 'Phone', 'Mobile', 'Fax', 'Address']

	driver = Watir::Browser.new :chrome

	url = "https://community.procore.com/s/topiccatalog"

	# doc = Nokogiri::HTML(open(url))
	# puts doc

	driver.goto(url)

	sleep 5

	# parsed_page =  Nokogiri::HTML(driver.html)

	loop do

		driver.button(text: 'View More').click

		break if !driver.button(text: 'View More').exists?

	end

	url_array = []

	driver.as(class: ["cuf-entityLink", "cuf-entityLink"]).each do |urls|
		url_array.push(urls.attribute('href'))
	end
	puts url_array.count
	url_array.each_with_index do |each_url, i|

		puts "-----------count = #{i}------------"

		driver.goto(each_url)


		sleep 10

		data_array = driver.divs(class: ["slds-form-element", "slds-form-element_readonly", "slds-grow", "slds-hint-parent", "override--slds-form-element"])

		name = ''
		title = ''
		manager = ''
		company = ''
		about = ''
		email = ''
		phone = ''
		mobile = ''
		fax = ''
		address = ''

		data_array.each do |data|
	    if data.text.split('Name').first ==  ""
	    	begin name = data.text.split('Name').last.strip rescue "" end

	    elsif data.text.include? 'Title'

	    	begin title = data.text.split('Title').last.strip rescue "" end

	  	elsif data.text.include? 'Manager'

	  	  begin manager = data.text.split('Manager').last.strip rescue "" end

	  	elsif data.text.include? 'Company Name'

	  	  begin company = data.text.split('Company Name').last.strip rescue "" end

	  	elsif data.text.include? 'About Me'

	  	  begin about = data.text.split('About Me').last.strip rescue "" end

	  	elsif data.text.include? 'Email'

	  	  begin email = data.text.split('Email').last.strip rescue "" end

	  	elsif data.text.include? 'Phone'

	  	  begin phone = data.text.split('Phone').last.strip rescue "" end

	  	elsif data.text.include? 'Mobile'

	  	  begin mobile = data.text.split('Mobile').last.strip rescue "" end

	  	elsif data.text.include? 'Fax'

	  	  begin fax = data.text.split('Fax').last.strip rescue "" end

	  	elsif data.text.include? 'Address'

	  	  begin address = data.text.split('Address').last.strip rescue "" end

	  	end

	  	
	  	 
	  end

	  csv << [name, title, manager, company, about, email, phone, mobile, fax, address]

	  csv.flush
	  
	end
end

