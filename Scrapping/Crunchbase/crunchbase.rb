# frozen_string_literal: false

require 'csv'
require 'nokogiri'
require 'watir'
require 'watir-webdriver'
require 'json'
require 'si'
require 'wtf_lang'

Selenium::WebDriver::Chrome.driver_path = 'C:/chrome driver/chromedriver.exe'

puts "Program Starting Time : #{Time.now}"

browser = Watir::Browser.new :chrome

browser.window.maximize

lis = ['https://www.crunchbase.com/organization/velasca', 'https://www.crunchbase.com/organization/milkman-deliveries']

CSV.open('Crunchbase_output_1.csv', 'wb', { col_sep: '~' }) do |csv|
  csv << ['Company Name', 'Last Funding Type', 'IPO Status', 'Website', 'Total Funding', 'Industries', 'Legal Name', 'Headquarters location', 'Founded Date', 'Status', 'Company Type', 'Email', 'Funding Round', 'Announced Date', 'Transaction Name', 'Money Raised', 'No. of Investors', 'Funding Investors', 'Investors', 'News Date', 'News', 'News Link', 'Article Language']

  lis.each do |url|
    begin
      browser.goto(url)

      sleep 3

      doc = Nokogiri::HTML.parse(browser.html)

      json = JSON.parse(doc.to_s.split('type="application/json">').last.split('</script>').first.to_s.gsub('&q;', '"'))
      
      k = json['HttpState'].keys[0]

      summary = json['HttpState'][k]['data']['cards']

      company_name = begin doc.css('span.profile-name').text rescue '' end

      puts "\nCapturing details for : #{company_name}\n"

      last_funding_type = begin summary['company_about_fields2']['last_funding_type'] rescue '' end

      ipo_status = begin summary['company_about_fields2']['ipo_status'] rescue '' end

      website = begin summary['company_about_fields2']['website']['value'] rescue '' end

      total_funding = begin summary['funding_rounds_headline']['funding_total']['value'].si rescue '' end

      begin
        categories = summary['overview_fields_extended']['categories']

        industries = ''

        categories.each do |each_category|
          industries = industries + each_category['value'] + ','
        end

        industries = industries.split(',').join(', ')
      rescue Exception => e
        puts "--- Exception in getting categories for #{url} :\n Exception Message: #{e.message}"
      end

      legal_name = begin summary['overview_fields_extended']['legal_name'] rescue '' end

      begin
        locations = summary['overview_fields_extended']['location_identifiers']

        head_quarters_loc = ''

        locations.each do |each_location|
          head_quarters_loc = head_quarters_loc + each_location['value'] + ','
        end

        head_quarters_loc = head_quarters_loc.split(',').join(', ')
      rescue Exception => e
        puts "--- Exception in getting location for #{url} :\n Exception Message: #{e.message}"
      end

      founded_date = begin Date.parse(summary['overview_fields_extended']['founded_on']['value']).strftime('%b %d, %Y') rescue '' end

      status = begin summary['overview_fields_extended']['operating_status'] rescue '' end

      company_type = begin summary['overview_company_fields']['company_type'] rescue '' end

      email = begin summary['contact_fields']['contact_email'] rescue '' end

      funding_rounds = begin summary['company_financials_highlights']['num_funding_rounds'] rescue '' end

      csv << [company_name, last_funding_type, ipo_status, website, total_funding, industries, legal_name, head_quarters_loc, founded_date, status, company_type, email, funding_rounds]
      begin
        browser.goto(url + '/signals_and_news/timeline')

        sleep 3

        news_page = Nokogiri::HTML.parse(browser.html)

        funding_rounds_list = summary['funding_rounds_list']

        funding_rounds_list.each do |each_round|
          begin
            announced_date = begin Date.parse(each_round['announced_on']).strftime('%b %d, %Y') rescue '' end

            transaction_name = begin each_round['identifier']['value'] rescue '' end

            money_raised = begin each_round['money_raised']['value'].si rescue '' end

            num_of_investors = begin each_round['num_investors'] rescue '' end

            lead_investors_list = begin each_round['lead_investor_identifiers'] rescue '' end

            funding_investors = ''

            begin

              lead_investors_list.each do |each_investor|
                funding_investors = funding_investors + each_investor['value'] + ','
              end
              
              funding_investors = funding_investors.split(',').join(', ')
            rescue Exception
            end

            begin
              permalink = each_round['identifier']['permalink']

              investors_link = 'https://www.crunchbase.com/funding_round/' + permalink

              browser.goto(investors_link)

              sleep 3

              investor_page = Nokogiri::HTML.parse(browser.html)

              investor_json = JSON.parse(investor_page.to_s.split('type="application/json">').last.split('</script>').first.to_s.gsub('&q;', '"'))

              j = investor_json['HttpState'].keys[0]

              investors_list = investor_json['HttpState'][j]['data']['cards']['investors_list']

              investors = ''

              investors_list.each do |each_investor|
                investors = investors + each_investor['investor_identifier']['value'] + ','
              end

              investors = investors.split(',').join(', ')
            rescue Exception => e
              puts "--- Exception in getting Investors for #{url} :\n Exception Message: #{e.message}"
            end

            news_list = news_page.css("div[class*='activity-row']")

            news = ''
            article_link = ''
            published_date = ''

            csv_flag = true

            news_list.each do |each_news|
              date_array = [(Date.parse(announced_date) - 1).strftime('%b %d, %Y'), Date.parse(announced_date).strftime('%b %d, %Y'), (Date.parse(announced_date) + 1).strftime('%b %d, %Y')]

              news_date = begin each_news.css('span.component--field-formatter.field-type-date.ng-star-inserted').text rescue '' end

              news_link = begin each_news.css('a.link-accent.flex').attr('href').value rescue '' end
                
              if date_array.include? news_date
                
                news = begin each_news.css('div.activity-details').text.gsub('Discover more funding rounds', '').strip rescue '' end
                
                published_date = begin each_news.css('span.component--field-formatter.field-type-date.ng-star-inserted').text rescue '' end
                
                article_link = begin each_news.css('a.link-accent.flex').attr('href').value rescue '' end

                WtfLang::API.key = '37062912f1fd108c040540b581c6a69d'


                if !article_link.nil? && article_link != ''
                	article_lang = begin (article_link.gsub('https://', '').gsub('www.', '').gsub('http://', '')).full_lang rescue '' end
                  csv_flag = false
                  csv << ['', '', '', '', '', '', '', '', '', '', '', '', '', announced_date, transaction_name, money_raised, num_of_investors, funding_investors, investors, published_date, news, article_link, article_lang]
                end

              end
            end
            if csv_flag
              
              csv << ['', '', '', '', '', '', '', '', '', '', '', '', '', announced_date, transaction_name, money_raised, num_of_investors, funding_investors, investors]

            end
          rescue Exception => e
            puts "--- Exception in each Funding rounds block for #{url} :\n Exception Message: #{e.message}"
          end
        end
      rescue StandardError => e
        puts "--- Exception in Funding rounds block for #{url} :\n Exception Message: #{e.message}"
      end

    rescue StandardError => e
      puts "--- Exception in main block for #{url} :\n Exception Message: #{e.message}"
    end

  end
end

puts "Program Ending Time : #{Time.now}"
