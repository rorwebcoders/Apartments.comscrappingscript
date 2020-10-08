# frozen_string_literal: false

require 'csv'
require 'byebug'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'watir'
require 'cgi'
require 'rest-client'
require 'json'

Selenium::WebDriver::Chrome.driver_path = 'C:/chrome driver/chromedriver.exe'

def fetch_company_details(csv)
  product_limit = 15
  begin
    driver = Watir::Browser.new :chrome
    product_count = 0
    url = 'https://www.crowdcube.com/companies'
    loop do
      driver.goto(url)
      sleep 5
      listing_page = Nokogiri::HTML(driver.html)
      total_companies = JSON.parse(listing_page.css('body').css('script')[0].text.strip.gsub('window.__INITIAL_STATE__ =', '').gsub(';', '').strip)['list']['cursor']['total'].to_i
      listing_page.css('section.cc-card').each do |c_data|
        company_url = 'https://www.crowdcube.com' + c_data.css('a.cc-card__link').attr('href').text.to_s rescue ''
        company_name = c_data.css('div.cc-card__body>h1').text rescue ''
        get_individual_company_details(company_name, company_url, csv)
        product_count += 1
      end
      if product_limit.to_i >= product_count.to_i
        driver.button(id: 'loadMoreCompanies').click
        sleep 10
      # else
        break if product_count == 30
      end
      url = ''
      url = driver.url
    end
  rescue Exception => e
    puts "-----\nException  Exception Message : #{e.message}-----"
  end
end

def get_individual_company_details(company_name, company_url, csv)
  begin
    website = ''
    facebook = ''
    instagram = ''
    twitter = ''
    annnounced_date = ''
    security_type = ''
    company_type = ''
    money_raised = ''
    premoney_valuation = ''
    deal_number = 0
    resp = Nokogiri::HTML(RestClient.get(company_url)) rescue ''
    resp.css('ul.cc-companyDetails>li').each do |co_details|
      if co_details.css('strong').text.to_s.downcase == 'industry type'
        company_type = co_details.css('p.cc-companyDetails__itemContent').text.strip rescue ''
      end
    end
    resp.xpath("//ul[@class='row cc-iconLabel']/li").each do |s_links|
      if s_links.css('span.cc-iconLabel__label').text.to_s.downcase == 'website'
        website = s_links.css('a').attr('href').text.strip rescue ''
      elsif s_links.css('span.cc-iconLabel__label').text.to_s.downcase == 'twitter profile'
        twitter = s_links.css('a').attr('href').text.strip rescue ''
      elsif s_links.css('span.cc-iconLabel__label').text.to_s.downcase == 'instagram'
        instagram = s_links.css('a').attr('href').text.strip rescue ''
      elsif s_links.css('span.cc-iconLabel__label').text.to_s.downcase == 'facebook page'
        facebook = s_links.css('a').attr('href').text.strip rescue ''
      end
    end
    captured_date = DateTime.now.to_date.strftime('%d/%m/%Y')
    source = 'CROWDCUBE'
    resp.xpath("//section[@class='cc-company__history']").css('table').each do |f_ur|
      annnounced_date = f_ur.css('tbody>tr>td').first.text rescue ''
      hisresp = Nokogiri::HTML(RestClient.get(f_ur.css('a').attr('href').text)) rescue ''
      security_type = hisresp.css('span.cc-tag').text.strip.split("\n").first rescue ''
      hisresp.css('div.cc-pitchHead__statsMain>dl').each do |h_data|
        if h_data.css('dt').text.to_s.downcase == 'raised'
          money_raised = "€ #{h_data.css('dd').text.strip.tr('^0-9', '')}" rescue ''
        end
      end
      hisresp.css('div.cc-pitchHead__statsSecondary>dl').each do |h_data|
        if h_data.css('dt').text.to_s.downcase == 'pre-money valuation'
          premoney_valuation = "€ #{h_data.css('dd').text.strip.tr('^0-9', '')}" rescue ''
        end
      end
      deal_number += 1
      csv << [company_name, '', company_type, security_type, '', '', website, facebook, twitter, '', instagram, annnounced_date, '', money_raised, premoney_valuation, deal_number, captured_date, source]
      csv.flush
    end
  rescue StandardError => e
    puts "-----\nException in get individual company details------------"
    puts "-----\nException Message : #{e.message}-----"
  end
end

puts "Starting time ======= #{Time.now}"
output_file_name = "outputcrowdcube_#{Time.now.to_i}.csv"
begin
  CSV.open(output_file_name, 'wb', { col_sep: '~' }) do |csv|
    csv << ['Company Name', 'Legal Entity Name', 'Company Type', 'Security Type', 'Primary industry', 'Other industries', 'Website', 'Facebook', 'Twitter', 'Linkedin', 'Instagram', 'Announced Date', 'Campaign Status', 'Money Raised(in €)', 'Pre-money Valuation(in €)', 'Deal Number', 'Captured Data', 'Source']
    fetch_company_details(csv)
  end
rescue StandardError => e
  puts "-----\nError occured in Fetching Main Program-----\nException Message : #{e.message}"
end
puts "End time ======= #{Time.now}"
