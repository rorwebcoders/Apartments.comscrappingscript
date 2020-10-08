# frozen_string_literal: false

require 'csv'
require 'openssl'
require 'byebug'
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'rest-client'

# This block is for iterating the different category to fetch forum urls
def get_category_list(csv)
  begin
    url = 'https://feedback.procore.com/forums/183340-customer-feedback-for-procore-technologies-inc'
    listing_category = Nokogiri::HTML(RestClient.get(url))
    listing_category.css('select#uvFieldSelect-category>option').each_with_index do |lp, i|
      if i.to_i > 0
        puts category = lp.text.tr('0-9()','').strip rescue ''
        category_url = 'https://feedback.procore.com' + lp.attr('value').to_s rescue ''
        get_forum_messages(url, category, category_url, csv) # This block is for getting forum details
      end
    end
  rescue StandardError => e
    puts "-----\nException Message : #{e.message}\n-----"
  end
end

def get_forum_messages(url, category, category_url, csv)
  begin
    init_page = 0
    loop do
      init_page += 1
      forum_url = "#{category_url}&filter=hot&page=#{init_page}"
      listing_forums = Nokogiri::HTML(RestClient.get(forum_url))
        listing_forums.css('ol.uvList-ideas>li').each do |lf|
          begin
            feedback_url = 'https://feedback.procore.com' + lf.css('a').attr('href').to_s rescue ''
            sleep 1
            listing_feebacks = Nokogiri::HTML(RestClient.get(feedback_url))
            topic_header = listing_feebacks.css('h1.uvIdeaTitle').text.strip rescue ''
            message = listing_feebacks.css('div.uvIdeaDescription').text.strip rescue ''
            attachements = listing_feebacks.css('a.uvAttachmentLink').collect { |x| 'https://feedback.procore.com' + x.attr('href').to_s }.join(',') rescue ''
            name = listing_feebacks.css('span.uvCustomLink-color').first.text.strip.gsub(/\(.*?\)/, '').strip rescue ''
            user_url = 'https://feedback.procore.com' + listing_feebacks.css('a.url').attr('href').to_s rescue ''
            if name.split(' ').length > 1
              first_name = name.split(' ').reverse.drop(1).reverse.join(' ') rescue '' 
              last_name = name.split(' ').last.to_s.strip rescue ''
            else
              first_name = name rescue '' 
              last_name = ''
            end
            date = listing_feebacks.css('time').first.text.to_s.strip rescue ''
            csv << [feedback_url, name, user_url, first_name, last_name, topic_header, message , attachements, '', date, category]
            csv.flush
            feed_init_page = 0
            loop do
              feed_init_page += 1 
              feedbacks_url = feedback_url + "?page=#{feed_init_page}&per_page=20" rescue ''
              sleep 1
              parse_listing_feebacks = Nokogiri::HTML(RestClient.get(feedbacks_url))
              parse_listing_feebacks.xpath("//ul[@class='uvList uvList-comments']/li").each do |lis|
                name = lis.css('span.uvCustomLink-color').text.strip.gsub(/\(.*?\)/, '').strip rescue ''
                comment = lis.css('div.uvUserActionBody').text.strip rescue ''
                if name.split(' ').length > 1
                  first_name = name.split(' ').reverse.drop(1).reverse.join(' ') rescue '' 
                  last_name = name.split(' ').last.to_s.strip rescue ''
                else
                  first_name = name rescue '' 
                  last_name = ''
                end
                date = lis.css('time').text.strip rescue ''
                user_url = 'https://feedback.procore.com' + lis.css('a.url').attr('href').to_s rescue ''
                csv << [feedback_url, name, user_url, first_name, last_name, topic_header, message, attachements, comment, date, category]
                csv.flush
              end
              break if parse_listing_feebacks.xpath("//ul[@class='uvList uvList-comments']/li").length == 0
            end
          rescue StandardError => e
            puts "-----\nException in #{feedback_url}  : #{e.message}\n-----"
          end
        end
      break if listing_forums.text.to_s.include? ('No ideas found')
    end
  rescue StandardError => e
    puts "-----\nException Message  : #{e.message}\n-----"
  end
end

puts "Starting time ======= #{Time.now}"
output_file_name = "output_procore_#{Time.now.to_i}.csv"
begin
  CSV.open(output_file_name, 'wb', { col_sep: '~' }) do |csv|
    csv << ['URL', 'Name', 'User Url', 'First Name', 'Last Name', 'Topic Header', 'Message', 'Attachements', 'Comment', 'Date', 'Category']
    get_category_list(csv)
  end
rescue StandardError => e
  puts "-----\nError occured in Fetching Main Program-----\nException Message : #{e.message}"
end
puts "End time ======= #{Time.now}"
