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
  url = 'https://www.symbid.com/ideas?selection=funded'
  parsed_page = Nokogiri::HTML(RestClient.get(url))
  parsed_page.css('div#recent-ideas-tab>div').each_with_index do |c_list, index|
    if index.to_i > 0
      company_name = c_list.css('a').text.strip
      company_url = 'https://www.symbid.com' + c_list.css('a').attr('href').text.to_s
      get_individual_company_details(company_name, company_url, csv)
     end
  end
end

def get_individual_company_details(company_name, company_url, csv)
    money_raised = ''
    deal_number = 1
    resp = Nokogiri::HTML(RestClient.get(company_url))
    security_type = resp.css('div.corner-text').text.strip rescue ''
    money_raised = "€ #{resp.css('div.sum-invested').text.tr('^0-9', '')}" if resp.css('div.sum-invested').text.tr('^0-9', '').to_s != ''
    legal_entity_name = resp.css('div.btm>strong').text rescue ''
    capturedate = DateTime.now.strftime('%d/%m/%Y %H:%M:%S')
    source = 'SYMBID'
    csv << [company_name, legal_entity_name, '', security_type, '', '', '', '', '', '', '', '', '', money_raised, '', deal_number, capturedate, source]
end

puts "Starting time ======= #{Time.now}"
output_file_name = "outputsybmid_#{Time.now.to_i}.csv"
begin
  CSV.open(output_file_name, 'wb', { col_sep: '~' }) do |csv|
    csv << ['Company Name', 'Legal Entity Name', 'Company Type', 'Security Type', 'Primary industry', 'Other industries', 'Website', 'Facebook', 'Twitter', 'Linkedin', 'Instagram', 'Announced Date', 'Campaign Status', 'Money Raised(in €)', 'Pre-money Valuation(in €)', 'Deal Number', 'Captured Data', 'Source']
    fetch_company_details(csv)
  end
rescue StandardError => e
puts "-----\nError occured in Fetching Main Program-----\nException Message : #{e.message}"
end
puts "End time ======= #{Time.now}"
