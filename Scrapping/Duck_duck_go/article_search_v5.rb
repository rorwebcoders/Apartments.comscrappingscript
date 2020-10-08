# frozen_string_literal: false

require 'watir'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'csv'
require 'si'
require 'wtf_lang'

$driver = Watir::Browser.new :chrome

WtfLang::API.key = '37062912f1fd108c040540b581c6a69d'

puts "Program Starting Time: #{Time.now}"

def get_article(site, date_value, name, investor, money_raised)
  date_array = [(Date.parse(date_value) - 1).strftime('%d %b, %Y'), Date.parse(date_value).strftime('%d %b, %Y'), (Date.parse(date_value) + 1).strftime('%d %b, %Y')]

  article_url = ''

  date_array.each do |date|
    if investor == true

      url = "https://duckduckgo.com/?q=#{site}+#{name}+#{date}&t=hk&ia=web"

    else

      url = "https://duckduckgo.com/?q=site:#{site}+#{name}+#{date}&t=hk&ia=web"

    end

    $driver.goto(url)

    sleep 5

    parsed_page = Nokogiri::HTML($driver.html)

    parsed_page.css("div[@class='result__body links_main links_deep']").each do |parsed_data|
      begin
        link = parsed_data.at_css("a[@class = 'result__url js-result-extras-url']").attr('href')
        if parsed_data.text.downcase.include? name.to_s.downcase

          if parsed_data.text.downcase.include? site.to_s.downcase

            if (link.downcase.include? money_raised.to_i.si.to_s.downcase) || (link.downcase.include? money_raised.to_i.si.gsub('0', '').to_s.downcase) || (link.downcase.include? money_raised.to_i.si.to_s.downcase.gsub('0', '').gsub('.', '-').gsub(',', '-')) || (link.downcase.include? money_raised.to_i.si.to_s.downcase.gsub('.', '-').gsub(',', '-')) || (link.downcase.gsub('-', '').include? money_raised.to_i.si.gsub('0', '').downcase.gsub('.', '')) || (link.downcase.gsub('-', '').include? money_raised.to_i.si.downcase.gsub('.', '')) || (link.downcase.include? Date.parse(date).strftime('%Y/%m/%d')) || (parsed_data.text.downcase.include? date.to_s.gsub(',', '').downcase)

              article_url = parsed_data.at_css("a[@class = 'result__a']").attr('href')

              break if article_url != '' && !article_url.nil?

            end

          end

        end
      rescue Exception => e
        puts "------\n Exception in main block:\n Exception Type : #{e.class}\n   Exception Message : #{e.message}\n-----"
      end
    end
  end

  return article_url if article_url != '' && !article_url.nil?
end

CSV.open('article_search_output.csv', 'wb', col_sep: '~') do |csv|
  csv << ['Organization Name', 'Money Raised', 'Money Raised Currency', 'Announced Date', 'Lead Investors', 'Investor Names', 'Article', 'Article Language']

  input_data = CSV.read('search_input.csv', headers: true)

  general_sources = %w[unquote.com bebeez.it startupitalia.eu legalcommunity.it ilsole24ore.com aifi.it economyup.it eu-startups.com techcrunch.com technation.io venturebeat.com]


  input_data.each_with_index do |data, i|
    finmes_flag = false

    name = data['Organization Name']

    money_raised = data['Money Raised']

    money_raised_curr = data['Money Raised Currency']

    announced_date = data['Announced Date']

    lead_investors = data['Lead Investors']

    investors_name = data['Investor Names']

    date = data['Announced Date']

    if i.positive?

      if input_data[i - 1]['Organization Name'] != name
     
        finmes_flag = true

      end

    end

    if i.zero? || finmes_flag
      
      $driver.goto("http://www.finsmes.com/?s=#{name}")

      sleep 3
      
      $driver.articles.each do |each_article|
        fin_url = each_article.h2(class: 'entry-title').a.attribute('href')

        article_lang = begin (fin_url.gsub(/[^a-zA-Z]/, '').gsub('https', '').gsub('www', '').gsub('http', '')).full_lang rescue '' end

        begin
          published_date = Date.parse(each_article.time(class: 'entry-date published updated').text).strftime('%d/%m/%Y')
        rescue 
          published_date = nil
        end
        

        begin
          published_date = Date.parse(each_article.time(class: 'entry-date published').text).strftime('%d/%m/%Y') if published_date.nil?
          rescue 
          published_date = nil
        end

        csv << [name, '', '', published_date, '', '', fin_url, article_lang]
      end

    end

    general_sources.each do |gs|
      investor = false

      article_url = get_article(gs, date, name, investor, money_raised)

      if article_url != '' && !article_url.nil?

        article_lang = begin (article_url.gsub(/[^a-zA-Z]/, '').gsub('https', '').gsub('www', '').gsub('http', '')).full_lang rescue '' end

        csv << [name, money_raised, money_raised_curr, announced_date, lead_investors, investors_name, article_url, article_lang]

        csv.flush

      end

      sleep 5
    end
  end
end

puts "Program Ending Time: #{Time.now}"
