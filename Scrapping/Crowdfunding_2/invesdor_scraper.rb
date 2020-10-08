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
  begin
    inti_page = 0
    page_limit = 13
    loop do
      inti_page += 1
      url = "https://www.invesdor.com/en/pitches/closed?page=#{inti_page}"
      listing_page = Nokogiri::HTML(RestClient.get(url))
      listing_page.xpath("//div[@class='grid-box-container discover pitches']/a").each do |urls|
        puts company_url = "https://www.invesdor.com#{urls.attr('href')}"
        get_individual_company_details(company_url, csv)
      end
      break if inti_page.to_i >= page_limit.to_i
    end
  rescue StandardError => e
    puts "-----\n  Exception Message : #{e.message}\n"
  end
end

def get_individual_company_details(company_url, csv)
  deal_number = 1
  begin
    resp = Nokogiri::HTML(RestClient.get(company_url))
    company_name = resp.css('h1.pitch-title').text rescue ''
    security_type = resp.css('div.header-label>span').text rescue ''
    campaign_status = resp.css('div.deadline>div.value').text rescue ''
    captured_date = DateTime.now.strftime('%d/%m/%Y %H:%M:%S')
    source = 'INVESDOR'
    website = resp.css('tr.web>td>a').attr('href').to_s rescue ''
    socresp = Nokogiri::HTML(RestClient.get(website))
    facebook = socresp.css('a').collect { |x| x.attr('href') if x.attr('href').to_s.include?('facebook') && x.attr('href').to_s != '' }.uniq.reject { |c| c.nil? }.join(',') rescue ''
    linkedin = socresp.css('a').collect { |x| x.attr('href') if x.attr('href').to_s.include?('linkedin') && x.attr('href').to_s != '' }.uniq.reject { |c| c.nil? }.join(',') rescue ''
    twitter = socresp.css('a').collect { |x| x.attr('href') if x.attr('href').to_s.include?('twitter') && x.attr('href').to_s != '' }.uniq.reject { |c| c.nil? }.join(',') rescue ''
    instagram = socresp.css('a').collect { |x| x.attr('href') if x.attr('href').to_s.include?('instagram') && x.attr('href').to_s != '' }.uniq.reject { |c| c.nil? }.join(',') rescue ''
    annnounced_date = resp.css('tr.emission-date>td').text.strip rescue ''
    premoney_valuation = "€ #{resp.css('tr.pre-money-valuation').text.tr('^0-9.', '')}" rescue '' if resp.css('tr.pre-money-valuation').text.tr('^0-9.', '').to_s != ''
    money_raised = "€ #{resp.css('div.amount-invested>span').text.tr('^0-9.', '')}" rescue '' if resp.css('div.amount-invested>span').text.tr('^0-9.', '').to_s != ''
    primary_industries = resp.css('tr.business-field>td').text rescue ''
    csv << [company_name, '', '', security_type, primary_industries, '', website, facebook, twitter, linkedin, instagram, annnounced_date, campaign_status, money_raised, premoney_valuation, deal_number, captured_date, source]
    csv.flush
  rescue StandardError => e
    puts "-----\nException in get individual company details------------"
    puts "-----\n  Exception Message : #{e.message}\n"
  end
end

puts "Starting time ======= #{Time.now}"
output_file_name = "outputinvesdor_#{Time.now.to_i}.csv"
begin
  CSV.open(output_file_name, 'wb', { col_sep: '~' }) do |csv|
    csv << ['Company Name', 'Legal Entity Name', 'Company Type', 'Security Type', 'Primary industry', 'Other industries', 'Website', 'Facebook', 'Twitter', 'Linkedin', 'Instagram', 'Announced Date', 'Campaign Status', 'Money Raised(in €)', 'Pre-money Valuation(in €)', 'Deal Number', 'Captured Data', 'Source']
    fetch_company_details(csv)
  end
rescue StandardError => e
  puts "-----\nError occured in Fetching Main Program-----\nException Message : #{e.message}"
end
puts "End time ======= #{Time.now}"
