# frozen_string_literal: false

require 'csv'
require 'nokogiri'
require 'open-uri'
require 'openssl'
require 'roo'
require 'optparse'
require 'cgi'

options = {}
optparse = OptionParser.new do |opts|
  # Define the options, and what they do
  opts.on('-c', '--country COUNTRYNAME', 'Please enter countryname in sheet to process') do |countryname|
    options[:countryname] = countryname
  end
  opts.on('-h', '--help', 'To get the list of available options') do
    puts opts
    exit
  end
end
optparse.parse!
puts input_country_name = options[:countryname]
accept_to_process = ''
if !input_country_name.nil?
  workbook = Roo::Spreadsheet.open('companies.xlsx') # reading the xlsx to process
  if workbook.sheets.map(&:downcase).include?(input_country_name.downcase)
    accept_to_process = true
  else
    puts 'This countryname is not in the sheet'
  end
else
  puts 'Please check for the parameter to pass'
end
if accept_to_process == true
  csv = CSV.open("#{input_country_name}_output_data.csv", 'wb')
  csv << ['ID', 'Company Name', 'Capture company Name reference', 'Company Url', 'Founded year', 'Status', 'Description', 'Website', 'Twitter', 'Facebook', 'LinkedIn', 'Primary Industry', 'Investor Names (comma separated values)', 'Country']
  workbook = Roo::Spreadsheet.open('companies.xlsx') # reading the xlsx to process
  worksheet_all = workbook.sheets.map(&:downcase).index(input_country_name.downcase)
  puts workbook.default_sheet = workbook.sheets[worksheet_all]
  headers = {}
  workbook.row(1).each_with_index { |header, i| headers[header] = i }
  ((workbook.first_row + 1)..workbook.last_row).each do |row|
    begin
      id = workbook.row(row)[headers['ID']].to_s if headers['ID']
      company_name = workbook.row(row)[headers['Company Name']].to_s if headers['Company Name']
      puts "Processing Sheet #{input_country_name} #{id} #{company_name}"
      company_temp_url = ''
      err = ''
      is_available = ''
      begin
        @i = 1
        @num = 10
        while @i < @num
          url = URI.encode("https://pitchbook.com/profiles/search?q=#{company_name}&page=#{@i}")
          sleep 2
          doc = Nokogiri::HTML(URI.parse(url).open)
          doc.css('ul.profile-list.list-type-none li').each do |t1|
            puts name = t1.css('a').text.gsub('Company', '').strip
            begin
              begin
                company_temp_url = t1.css('a')[0]['href']
              rescue StandardError
                company_temp_url = ''
              end
              company_url = "https://pitchbook.com#{company_temp_url}"
              doc_two = Nokogiri::HTML(URI.parse(company_url).open)
              temp_two = doc_two.css('div.container.flex-container.flex-wrap')
              if temp_two.at('div.primary-font.primary-dark-text-color.semi-font-weight:contains("Primary Office")')
                country_temp = temp_two.at('div.primary-font.primary-dark-text-color.semi-font-weight:contains("Primary Office")').next_element.text.split(' ').last
              end
            rescue StandardError
              err = 'error'
            end
            if err != 'error' && (name.downcase == company_name.downcase) && (country_temp.to_s.downcase == input_country_name.downcase)
              is_available = true
              @i = 200
              break
            end
          end
          @i += 1
        end
      rescue StandardError => e
        puts e.message
        puts "we could not find this #{company_name} in this website"
        csv << [id, company_name, 'not found', 'not found', 'not found', 'not found', 'not found', 'not found', 'not found', 'not found', 'not found', 'not found', 'not found', 'not found']
        err = 'error'
      end
      if is_available == true && err != 'error'
        company_url = "https://pitchbook.com#{company_temp_url}"
        doc_one = Nokogiri::HTML(URI.parse(company_url).open)
        temp_one = doc_one.css('div.container.flex-container.flex-wrap')

        if temp_one.at('li:contains("Founded")')
          begin
            founded = temp_one.at('li:contains("Founded")').next_element.text
          rescue StandardError
            founded = ''
          end
        end
        if temp_one.at('li:contains("Status")')
          begin
            status = temp_one.at('li:contains("Status")').next_element.text
          rescue StandardError
            status = ''
          end
        end
        if temp_one.at('h3:contains("Description")')
          begin
            description = temp_one.at('h3:contains("Description")').next_element.text
          rescue StandardError
            description = ''
          end
        end
        if temp_one.at('div.primary-font.primary-dark-text-color.semi-font-weight:contains("Website")')
          begin
            website = temp_one.at('div.primary-font.primary-dark-text-color.semi-font-weight:contains("Website")').next_element.text
          rescue StandardError
            website = ''
          end
        end
        if temp_one.at('div.primary-font.primary-dark-text-color.semi-font-weight:contains("Primary Industry")')
          begin
            primary_industry = temp_one.at('div.primary-font.primary-dark-text-color.semi-font-weight:contains("Primary Industry")').next_element.attr('title')
          rescue StandardError
            primary_industry = ''
          end
        end

        if temp_one.at('div.primary-font.primary-dark-text-color.semi-font-weight:contains("Primary Office")')
          begin
            country = temp_one.at('div.primary-font.primary-dark-text-color.semi-font-weight:contains("Primary Office")').next_element.text.split(' ').last
          rescue StandardError
            country = ''
          end
        end
        begin
          captured_company_name = temp_one.css('h2.pp-overview_title span').text
        rescue StandardError
          captured_company_name = ''
        end
        begin
          twitter = temp_one.css('div.twitter a')[0]['href']
        rescue StandardError
          twitter = ''
        end
        begin
          linkedin = temp_one.css('div.linkedin a')[0]['href']
        rescue StandardError
          linkedin = ''
        end
        begin
          facebook = temp_one.css('div.facebook a')[0]['href']
        rescue StandardError
          facebook = ''
        end
        temp_investor_name = []
        temp_two = temp_one.css('div#investors table tbody tr')
        temp_two.each do |t_two|
          temp_investor_name << t_two.css('td')[0].text
        end
        investor_name = temp_investor_name.join(', ')
        csv << [id, company_name, captured_company_name, company_url, founded, status, description, website, twitter, facebook, linkedin, primary_industry, investor_name, country]
      else
        csv << [id, company_name, 'not found', 'not found', 'not found', 'not found', 'not found', 'not found', 'not found', 'not found', 'not found', 'not found', 'not found', 'not found']
      end
    rescue StandardError => e
      puts e
    end
  end
  csv.close
end
