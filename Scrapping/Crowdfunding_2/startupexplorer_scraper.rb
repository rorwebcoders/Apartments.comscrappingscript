# frozen_string_literal: false

require 'csv'
require 'openssl'
require 'byebug'
require 'selenium-webdriver'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'csv'
require 'watir'
require 'cgi'
require 'rest-client'

def fetch_company_details(csv)
  url = 'https://startupxplore.com/en/investors/syndicates/previous'
  parsed_page = Nokogiri::HTML(RestClient.get(url))
  parsed_page.css('div.syndicate-opened').each do |c_list|
    get_individual_company_details(c_list, csv)
  end
end

def get_individual_company_details(c_list, csv)
  deal_number = 1
  compaign_status = ''
  company_name = c_list.css('div.content-startup>h3').text.strip rescue ''
  money_raised = "€ #{c_list.css('p.orange').text.strip.tr('^0-9', '')}" if c_list.css('p.orange').text.strip.tr('^0-9', '').to_s != ''
  compaign_status = c_list.css('ul.list-inline>li').first.text.tr('0-9/', '').strip rescue ''
  annnounced_date = c_list.css('ul.list-inline>li').first.css('span.number').text rescue ''
  capture_date = DateTime.now.strftime('%d/%m/%Y %H:%M:%S')
  source = 'STARTUPEXPLORER'
  csv << [company_name, '', '', '', '', '', '', '', '', '', '', annnounced_date, compaign_status, money_raised, '', deal_number, capture_date, source]
end

puts "Starting time ======= #{Time.now}"
output_file_name = "outputstartupexplorer_#{Time.now.to_i}.csv"
begin
  CSV.open(output_file_name, 'wb', { col_sep: '~' }) do |csv|
    csv << ['Company Name', 'Legal Entity Name', 'Company Type', 'Security Type', 'Primary industry', 'Other industries', 'Website', 'Facebook', 'Twitter', 'Linkedin', 'Instagram', 'Announced Date', 'Campaign Status', 'Money Raised(in €)', 'Pre-money Valuation(in €)', 'Deal Number', 'Captured Data', 'Source']
    fetch_company_details(csv)
  end
rescue StandardError => e
  puts "-----\nError occured in Fetching Main Program-----\nException Message : #{e.message}"
end
puts "End time ======= #{Time.now}"
