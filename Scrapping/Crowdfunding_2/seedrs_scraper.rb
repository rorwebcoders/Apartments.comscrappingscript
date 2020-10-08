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
  url = 'https://www.seedrs.com/investment-opportunities?context=primary&current_page=5&last_page=5&sort=trending_desc&view=card'
  listing_page = Nokogiri::HTML(RestClient.get(url))
  url_lists = listing_page.css('article.card-with-image__Wrapper-sc-15thihl-1>a').collect { |x| 'https://www.seedrs.com' + x.attr('href').to_s }
  url_lists.each do |urls|
    get_individual_company_details(urls, csv)
  end
end

def get_individual_company_details(company_url, csv)
  begin
    deal_number = 1
    resp = Nokogiri::HTML(RestClient.get(company_url)) rescue ''
    company_name = resp.css('h1.favourite').text rescue ''
    facebook = resp.xpath("//a[@class='SocialLink SocialLink--facebookHover SocialLink--normal SocialLink--whiteColor hover']").attr('href').text.gsub('http:', 'https:') rescue ''
    twitter = resp.xpath("//a[@class='SocialLink SocialLink--normal SocialLink--twitterHover SocialLink--whiteColor hover']").attr('href').text.gsub('http:', 'https:') rescue ''
    linkedin = resp.xpath("//a[@class='SocialLink SocialLink--linkedinHover SocialLink--normal SocialLink--whiteColor hover']").attr('href').text.gsub('http:', 'https:') rescue ''
    website = resp.xpath("//a[@class='website']").attr('href').text rescue ''
    other_industries = resp.css('p.campaign-categories>span.CategoryLabel').collect { |x| x.text }.join(',') rescue ''
    money_raised = "£ #{resp.css('dl.investment_already_funded>dd').text.split('for ').first.strip.tr('^0-9', '')}" if resp.css('dl.investment_already_funded>dd').text.split('for ').first.to_s != ''
    premoney_valuation = "£ #{resp.css('dl.valuation>dd').text.tr('^0-9', '')}" if resp.css('dl.valuation>dd').text.tr('^0-9', '').to_s != ''
    capture_date = DateTime.now.strftime('%d/%m/%Y %H:%M:%S')
    source = 'SEEDRS'
    csv << [company_name, '', '', '', '', other_industries, website, facebook, twitter, linkedin, '', '', '', money_raised, premoney_valuation, deal_number, capture_date, source]
    csv.flush
  rescue StandardError => e
    puts "-----\nException in get individual company details------------"
    puts "-----\nException  Exception Type : #{e.class}-----"
    puts "\n   Exception Message : #{e.message}"
    puts "\n  Exception backtrace: #{e.backtrace.join("\n")}"
  end
end

puts "Starting time ======= #{Time.now}"
output_file_name = "outputseedrs_#{Time.now.to_i}.csv"
begin
  CSV.open(output_file_name, 'wb', { col_sep: '~' }) do |csv|
    csv << ['Company Name', 'Legal Entity Name', 'Company Type', 'Security Type', 'Primary industry', 'Other industries', 'Website', 'Facebook', 'Twitter', 'Linkedin', 'Instagram', 'Announced Date', 'Campaign Status', 'Money Raised(in €)', 'Pre-money Valuation(in €)', 'Deal Number', 'Captured Data', 'Source']
    fetch_company_details(csv)
  end
rescue StandardError => e
  puts "-----\nError occured in Fetching Main Program-----\nException Message : #{e.message}"
end
puts "End time ======= #{Time.now}"
