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
  campaign_status = ''
  @driver = Watir::Browser.new :chrome
  begin
    url = 'https://www.angelsden.com/investment-opportunities/'
    @driver.goto(url)
    listing_page = Nokogiri::HTML(@driver.html)
    listing_page.xpath("//div[@class='row']/div[@class='col-sm-6 col-md-4 trending-advert-outer']").each do |driv|
      company_name = driv.css('h4.trending-company-title').text rescue ''
      company_url = driv.css('a').attr('href').to_s rescue ''
      campaign_status = driv.css('action-button').text rescue ''
      get_individual_company_details(company_name, company_url, campaign_status, csv)
    end
  rescue StandardError => e
    puts "-----\nException Message : #{e.message}\n-----"
  end
end

def get_individual_company_details(company_name, company_url, campaign_status, csv)
  company_type = ''
  website = ''
  facebook = ''
  instagram = ''
  linkedin = ''
  twitter = ''
  money_raised = ''
  deal_number = 1
  security_type = ''
  captured_date = ''
  source = ''
  begin
    resp = Nokogiri::HTML(RestClient.get(company_url))
    if resp.css('span.statside-val').text.to_s.include?('Visit site')
      website = resp.css('span.statside-val').css('a').attr('href').to_s rescue ''
      parsed_page = Nokogiri::HTML(RestClient.get(website)) rescue ''
      facebook = parsed_page.css('a').collect { |x| x.attr('href') if x.attr('href').to_s.include?('facebook') && x.attr('href').to_s != '' }.uniq.reject { |c| c.nil? }.first rescue ''
      twitter = parsed_page.css('a').collect { |x| x.attr('href') if x.attr('href').to_s.include?('twitter') && x.attr('href').to_s != '' }.uniq.reject { |c| c.nil? }.first rescue ''
      instagram = parsed_page.css('a').collect { |x| x.attr('href') if x.attr('href').to_s.include?('instagram') && x.attr('href').to_s != '' }.uniq.reject { |c| c.nil? }.first rescue ''
      linkedin = parsed_page.css('a').collect { |x| x.attr('href') if x.attr('href').to_s.include?(company_name.downcase.split('  ').first.to_s) && x.attr('href').to_s.include?('linkedin') && x.attr('href').to_s.include?('company') && x.attr('href').to_s != '' }.uniq.reject { |c| c.nil? }.first rescue ''
    end
    resp.css('div.invest-single-stats-holder>ul>li').each do |re|
      if re.css('span.invest-single-stat-title').text.include?('FUNDED SO FAR')
        if re.css('span.invest-single-stat-number').text.tr('^0-9.', '').to_s != ''
          money_raised = "€ #{re.css('span.invest-single-stat-number').text.tr('^0-9.', '')}" rescue ''
        end
      elsif re.css('span.invest-single-stat-title').text.include?('EQUITY')
        security_type = re.css('span.invest-single-stat-title').text rescue ''
      end
    end
    captured_date = DateTime.now.strftime('%d/%m/%Y %H:%M:%S')
    source = 'ANGELSDEN'
    csv << [company_name, '', '', security_type, '', '', website, facebook, twitter, linkedin, instagram, '', campaign_status, money_raised, '', deal_number, captured_date, source]
    csv.flush
  rescue StandardError => e
    puts "-----\nException in get individual company details------------"
    puts "-----\n Exception Message : #{e.message}\n"
  end
end

puts "Starting time ======= #{Time.now}"
output_file_name = "outputangelsden_#{Time.now.to_i}.csv"
begin
  CSV.open(output_file_name, 'wb', { col_sep: '~' }) do |csv|
    csv << ['Company Name', 'Legal Entity Name', 'Company Type', 'Security Type', 'Primary industry', 'Other industries', 'Website', 'Facebook', 'Twitter', 'Linkedin', 'Instagram', 'Announced Date', 'Campaign Status', 'Money Raised(in €)', 'Pre-money Valuation(in €)', 'Deal Number', 'Captured Data', 'Source']
    fetch_company_details(csv)
  end
rescue StandardError => e
  puts "-----\nError occured in Fetching Main Program-----\nException Message : #{e.message}"
end
puts "End time ======= #{Time.now}"
