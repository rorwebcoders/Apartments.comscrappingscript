require 'csv'
require 'nokogiri'
require 'watir'

browser = Watir::Browser.new :firefox

input_data = CSV.read('output_details.csv', headers: true)

input_data.each do |data|
	begin
		url = data['url']
		browser.goto(url)
		sleep 3
		name = 'Dan Lazar'
		browser.forms(class: 'enquiry-form')[1].input(name: 'name').send_keys name.to_s
		email = 'dan@propertieshero.com.au'
		browser.forms(class: 'enquiry-form')[1].input(name: 'email').send_keys email.to_s
		postcode = '3182'
		browser.forms(class: 'enquiry-form')[1].input(name: 'postcode').send_keys postcode.to_s
		phone = '0450308198'
		browser.forms(class: 'enquiry-form')[1].input(name: 'phone').send_keys phone.to_s
		browser.forms(class: 'enquiry-form')[1].select(name: 'request_type').option(value: 'other').select
		browser.forms(class: 'enquiry-form')[1].select(name: 'level').option(value: 'Year 12').select
		comments = "Hi,\nThis is Dan from www.covershero.com.au\nWe're a company offering Artificial Grass & Permanent/Temporary Tents, allowing schools to offer a better experience to their students.\nWhat are your plans to upgrade your facilities in 2020?\n\nKind regards,\nDan Lazar"
		browser.forms(class: 'enquiry-form')[1].textarea(name: 'comments').send_keys comments.to_s

		browser.forms(class: 'enquiry-form')[1].input(type: 'submit').click

		sleep 5
		puts "------Completed #{url}----------"
	rescue Exception => ex
		puts "------\n Exception in #{url} Exception Type : #{ex.class}\n   Exception Message : #{ex.message}\n-----"
	end

end