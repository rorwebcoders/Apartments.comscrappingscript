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
  url = 'https://www.thecrowdangel.com/muestrario-de-operaciones'
  @driver.goto(url)
  @driver.window.maximize
  sleep 2
  listing_urls = @driver.divs(class: 'project-card').collect { |x| x.a.href }
  listing_urls.each do |urls|
    get_individual_company_details(urls, csv)
  end
end

def get_individual_company_details(companyurl, csv)
  website = ''
  facebook_url = ''
  instagram_url = ''
  linkedin_url = ''
  twitter_url = ''
  money_raised = ''
  premoney_valuation = ''
  deal_number = 1
  security_type = ''
  company_name = ''
  begin
    @driver.goto(companyurl)
    sleep 2
    company_resp = Nokogiri::HTML(@driver.html)
    premoney_valuation = '€ ' + company_resp.xpath("//div[@class='col-md-4 border-right-dashed border-left-dashed']/div[@class='icon-content']").collect { |x| x.text.tr('^0-9', '') if x.to_s.include?('Pre-money') && x.text.tr('^0-9', '').to_s != '' }.uniq.reject { |c| c.nil? }.first
    companyid = companyurl.split('/').last
    resp = RestClient.get("https://api.thecrowdangel.com/api/projects/#{companyid}")
    jsonresp = JSON.parse(resp)
    company_name = jsonresp['company']['name'].to_s
    website = jsonresp['company']['website'].to_s
    if website.to_s != ''
      parsed_page = Nokogiri::HTML(RestClient.get(website))
      facebook_url = parsed_page.css('a').collect { |x| x.attr('href') if x.attr('href').to_s.include?('facebook') && x.attr('href').to_s != '' }.uniq.reject { |c| c.nil? }.first
      twitter_url = parsed_page.css('a').collect { |x| x.attr('href') if x.attr('href').to_s.include?('twitter') && x.attr('href').to_s != '' }.uniq.reject { |c| c.nil? }.first
      instagram_url = parsed_page.css('a').collect { |x| x.attr('href') if x.attr('href').to_s.include?('instagram') && x.attr('href').to_s != '' }.uniq.reject { |c| c.nil? }.first
      linkedin_url = parsed_page.css('a').collect { |x| x.attr('href') if x.attr('href').to_s.include?(company_name.downcase().split(' ').first.to_s) && x.attr('href').to_s.include?('linkedin') && x.attr('href').to_s.include?('company') && x.attr('href').to_s != '' }.uniq.reject { |c| c.nil? }.first
    end
    if jsonresp['cash'].to_s != ''
      money_raised = '€ ' + jsonresp['cash'].to_s
      security_type = 'equity'
    end
    capture_date = DateTime.now.strftime('%d/%m/%Y %H:%M:%S')
    source = 'THECROWDANGEL'
    campaign_status = jsonresp['status'].to_s
    csv << [company_name, '', '', security_type, '', '', website, facebook_url, twitter_url, linkedin_url, instagram_url, '', campaign_status, money_raised, premoney_valuation, deal_number, capture_date, source]
    csv.flush
  rescue StandardError => e
    puts "-----\nException in get individual company details------------"
    puts "-----\nException  Exception Type : #{e.class}-----"
    puts "\n   Exception Message : #{e.message}"
    puts "\n  Exception backtrace: #{e.backtrace.join("\n")}"
  end
end

puts "Starting time ======= #{Time.now}"
@driver = Watir::Browser.new :chrome
output_file_name = "outputthecrowdangel_#{Time.now.to_i}.csv"
begin
  CSV.open(output_file_name, 'wb', { col_sep: '~' }) do |csv|
    csv << ['Company Name', 'Legal Entity Name', 'Company Type', 'Security Type', 'Primary industry', 'Other industries', 'Website', 'Facebook', 'Twitter', 'Linkedin', 'Instagram', 'Announced Date', 'Campaign Status', 'Money Raised(in €)', 'Pre-money Valuation(in €)', 'Deal Number', 'Captured Data', 'Source']
    fetch_company_details(csv)
  end
rescue StandardError => e
  puts "-----\nError occured in Fetching Main Program-----\nException Message : #{e.message}"
end
puts "End time ======= #{Time.now}"
