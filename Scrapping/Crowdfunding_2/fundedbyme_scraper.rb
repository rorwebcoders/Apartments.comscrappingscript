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

def login(email, password)
  url = 'https://www.fundedbyme.com/en/accounts/login/?next=%2Fbrowse'
  @driver.goto(url)
  sleep 5
  @driver.a(class: 'button button--xs button--google button--linkedin--fill fullWidth').click
  @driver.input(id: 'identifierId').send_keys(email)
  @driver.div(class: 'VfPpkd-dgl2Hf-ppHlrf-sM5MNb').click
  @driver.input(type: 'password').send_keys(password)
  @driver.div(class: 'VfPpkd-dgl2Hf-ppHlrf-sM5MNb').click
  sleep 5
end

def fetch_company_details(csv)
  begin
    init_page = 0
    c_status = ['live', 'upcoming', 'closed']
    c_status.each do |stat|
      loop do
        init_page += 1
        jsonres = JSON.parse(RestClient.get("https://www.fundedbyme.com/en/browse/campaign_list/?user_country=IN&page=#{init_page}&state=#{stat}")) rescue ''
        if jsonres != ''
          jsonres['results'].each do |r|
            company_url = 'https://www.fundedbyme.com/' + r['absolute_url'].to_s rescue ''
            if stat == 'live'
              status = 'STILL FUNDING'
            elsif stat == 'upcoming'
              status = 'LAUNCHING SOON'
            elsif stat == 'closed'
              status = 'SUCCESSFULLY FUNDED'
            end
            get_individual_company_details(status, company_url, csv)
          end
        else
          break
        end
      end
    end
  rescue StandardError => e
    puts "-----\nException Message : #{e.message}\n}-----"
  end
end

def get_individual_company_details(status, company_url, csv)
  website = ''
  facebook = ''
  instagram = ''
  linkedin = ''
  twitter = ''
  money_raised = ''
  premoney_valuation = ''
  deal_number = 1
  security_type = ''
  captured_date = ''
  source = ''
  primary_industries = ''
  campaign_status = status
  begin
    @driver.goto(company_url)
    sleep 5
    resp = Nokogiri::HTML(@driver.html) rescue ''
    company_name = resp.css('h1.pb10').text rescue ''
    resp.css('ul.company-online-presence-links>li').each do |s_list|
      if s_list.text.gsub('\n', '').strip.include?('Website')
        website = s_list.css('a').attr('href').text rescue ''
      elsif s_list.text.gsub("\n", '').strip.include?('Facebook')
        facebook = s_list.css('a').attr('href').text.gsub('http:', 'https:') rescue ''
      elsif s_list.text.gsub('\n', '').strip.include?('LinkedIn')
        linkedin = s_list.css('a').attr('href').text.gsub('http:', 'https:') rescue ''
      elsif s_list.text.gsub('\n', '').strip.include?('Instagram')
        instagram = s_list.css('a').attr('href').text.gsub('http:', 'https:') rescue ''
      end
    end
    primary_industries = resp.xpath("//ul[@class='left campaign-tags colorText']/li").last.text.strip rescue ''
    captured_date = DateTime.now.strftime('%d/%m/%Y %H:%M:%S') rescue ''
    source = 'FUNDEDBYME'
    resp.css('div#sticky-card-wrapper>div.card>div.sidebar-item').each_with_index do |l_item, i|
      if l_item.text.include?('pre-money valuation')
        premoney_valuation = "€ #{l_item.text.split('EUR').last.tr('^0-9.', '')}" rescue '' if l_item.text.split('EUR').last.tr('^0-9.', '').to_s != ''
      end
      if i.to_i.zero?
        money_raised = "€ #{l_item.css('span.colorHeading').text.tr('^0-9.', '')}" rescue '' if l_item.css('span.colorHeading').text.tr('^0-9.', '').to_s != ''
      end
    end
    csv << [company_name, '', '', security_type, primary_industries, '', website, facebook, twitter, linkedin, instagram, '', campaign_status, money_raised, premoney_valuation, deal_number, captured_date, source]
    csv.flush
  rescue StandardError => e
    puts "-----\nException in get individual company details------------"
    puts "-----\nException    Exception Type : #{e.class}\n   Exception Message : #{e.message}\n  Exception backtrace: #{e.backtrace.join("\n")}-----"
  end
end

puts "Starting time ======= #{Time.now}"
@driver = Watir::Browser.new :chrome
output_file_name = "outputfundedbyme_#{Time.now.to_i}.csv"
username = ''
password = ''
begin
  CSV.open(output_file_name, 'wb', { col_sep: '~' }) do |csv|
    csv << ['Company Name', 'Legal Entity Name', 'Company Type', 'Security Type', 'Primary industry', 'Other industries', 'Website', 'Facebook', 'Twitter', 'Linkedin', 'Instagram', 'Announced Date', 'Campaign Status', 'Money Raised(in €)', 'Pre-money Valuation(in €)', 'Deal Number', 'Captured Data', 'Source']
    login(username, password)
    fetch_company_details(csv)
  end
rescue StandardError => e
  puts "-----\nError occured in Fetching Main Program-----\nException Message : #{e.message}"
end
puts "End time ======= #{Time.now}"
