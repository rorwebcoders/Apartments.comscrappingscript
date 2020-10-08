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
  url = 'https://www.companisto.com/en/login/login'
  @driver.goto(url)
  sleep 5
  resp = Nokogiri::HTML(@driver.html)
  loginurl = resp.css('a.social-login-btn-google').attr('href').to_s
  @driver.goto(loginurl)
  @driver.window.maximize
  @driver.input(type: 'email').send_keys(email)
  @driver.div(class: 'VfPpkd-dgl2Hf-ppHlrf-sM5MNb').click
  sleep 5
  @driver.input(type: 'password').send_keys(password)
  @driver.div(class: 'VfPpkd-dgl2Hf-ppHlrf-sM5MNb').click
  sleep 5
end

def fetch_company_details(csv)
  begin
    primary_industries = ''
    url = 'https://www.companisto.com/en/investments'
    @driver.goto(url)
    @driver.window.maximize
    @driver.driver.execute_script('window.scrollBy(0,2300)')
    loop do
      @driver.a(class: "btn-default-new-layout btn-new-layout-wb load-more-startups").click rescue break
      sleep 5
    end
    resp = Nokogiri::HTML(@driver.html) rescue ''
    sleep 5
    resp.css('section#investments-list>div.col-xs-12').each do |lis|
      company_url = lis.css('a').attr('href').text rescue ''
      company_name = lis.css('h2.mb-5px').text.strip rescue ''
      primary_industries = lis.css('span.gray-box').text.strip rescue ''
      get_individual_company_details(company_name, company_url, primary_industries, csv)
    end
  rescue StandardError => e
    puts "-----\nException    Exception Type : #{e.class}\n   Exception Message : #{e.message}\n  Exception backtrace: #{e.backtrace.join("\n")}-----"
  end
end

def get_individual_company_details(company_name, company_url, primary_industries, csv)
  company_type = ''
  annnounced_date = ''
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
  campaign_status = ''
  begin
    @driver.goto(company_url)
    if @driver.url.to_s.include?('login')
      url = 'https://www.companisto-investments.de/en/login/login'
      @driver.goto(url)
      sleep 5
      resp = Nokogiri::HTML(@driver.html)
      loginurl = resp.css('a.social-login-btn-google').attr('href').to_s
      @driver.goto(loginurl)
      @driver.div(class: 'lCoei YZVTmd SmR8').click
      sleep 5
      @driver.goto(company_url)
    end
    sleep 5
    respo = Nokogiri::HTML(@driver.html) rescue ''
    respo.xpath("//div[@class='col-md-6 hide-sm hide-xs']/div[@class='overview-kpi-box']/div").each do |lis|
      if lis.css('div.row').text.strip.include?('Company Valuation')
        premoney_valuation = "€ #{lis.css('div.row>div.stat-value').text.strip.tr('^0-9', '')} " rescue '' if lis.css('div.row>div.stat-value').text.strip.tr('^0-9', '').to_s != ''
      elsif lis.css('div.row').text.strip.include?('Invested')
        money_raised = "€ #{lis.css('div.row>div.stat-value').text.strip.tr('^0-9', '')} " rescue '' if lis.css('div.row>div.stat-value').text.strip.tr('^0-9', '').to_s != ''
      end
    end
    if money_raised.to_s == ''
      respo.xpath("//div[@class='sidebarBox graysidebarBox startup-info-box']/div[@class='body']").each do |res|
        if res.css('p').text.include?('Invested')
          money_raised = "€ #{res.css('span.amount').text.gsub('\n', '').gsub('\t', '').gsub('\r', '').strip.tr('^0-9', '')} " rescue '' if res.css('span.amount').text.gsub('\n', '').gsub('\t', '').gsub('\r', '').strip.tr('^0-9', '').to_s != ''
        end
      end
    end
    campaign_status = respo.css('div.body.text-center>p').text.gsub('Campaign ', '') rescue ''
    security_type = respo.xpath("//div[@class='equity_badge equity_badge_blue']").text.strip rescue ''
    captured_date = DateTime.now.strftime('%d/%m/%Y %H:%M:%S')
    source = 'COMPANISTO'
    csv << [company_name, '', company_type, security_type, primary_industries, '', website, facebook, twitter, linkedin, instagram, annnounced_date, campaign_status, money_raised, premoney_valuation, deal_number, captured_date, source]
    csv.flush
  rescue StandardError => e
    puts "-----\nException in get individual company details------------"
    puts "-----\nException    Exception Type : #{e.class}\n   Exception Message : #{e.message}\n  Exception backtrace: #{e.backtrace.join("\n")}-----"
  end
end

puts "Starting time ======= #{Time.now}"
@driver = Watir::Browser.new :chrome
username = ''
password = ''
output_file_name = "outputcompanisto_#{Time.now.to_i}.csv"
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
