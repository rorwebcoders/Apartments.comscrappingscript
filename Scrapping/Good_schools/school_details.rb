## Web Scrapping Task - 11/05/2020

## URL: https://www.goodschools.com.au
## pagination_url: https://www.goodschools.com.au/compare-schools/search?autocomplete_type=+&distance=10&fee_grade=&keywords=&page=1 

## school_details.rb

## Adding Dependencies

require 'nokogiri'
require 'open-uri'
require 'csv'
begin
    csv = CSV.open("output_details.csv",'w')
    csv << ["url","name","location","contact_person1","name","contact_person2","name","address","tel no","website"]

    current_page = 1
    last_page = 610

    base_url = "https://www.goodschools.com.au"

    while current_page <= last_page do
        begin
            puts "At page: #{current_page}"

            page_url = "https://www.goodschools.com.au/compare-schools/search?autocomplete_type=+&distance=10&fee_grade=&keywords=&page=#{current_page}"

            doc = Nokogiri::HTML(open(page_url))

            lists = doc.xpath("//div[@class='row row-search-result']//div[@class='col-md-12 clear-fix']")

            lists.each do |list|

                p_url = "#{base_url}#{list.css('h3/a').attribute("href").value}"
                s_name = "#{list.css('h3/a').text.strip}"
                s_loc = "#{list.css('p').text.strip}"

                doc_sch = Nokogiri::HTML(open(p_url))

                details = doc_sch.xpath("//div[@class='visible-sm visible-xs margin-t-10']//div[@class='box border-grey']//div[@class='box-content']")

                details.each do |detail|
                    begin
                      begin school_website = detail.css("p[@class='margin-t-20']/a[class='underline']/@href").text rescue "" end
                        address = ''
                       detail.css("span[@class='address']").each do |each_address|
                         address = address + each_address.text + ','
                       end
                       address = address.split(',').join(', ')
                       begin school_tel = detail.css("p[@class='margin-t-20']")[1].text.strip rescue "" end
                       begin school_emp = detail.css('p')[0].text.strip rescue "" end

                         if school_emp.include? "\n"
                            empSetArray = school_emp.split("\n")
                            empRole_1 = empSetArray[0].strip
                            empRole_2 = empSetArray[1].strip

                            arr_1 = empRole_1.split(":")

                            begin  emp_1_role = arr_1[0] rescue "" end
                            begin emp_1_name = arr_1[1].strip rescue "" end
                            
                            arr_2 = empRole_2.split(":")

                            begin emp_2_role = arr_2[0] rescue "" end
                            begin emp_2_name = arr_2[1].strip rescue "" end

                            csv << [p_url,s_name,s_loc,emp_1_role,emp_1_name,emp_2_role,emp_2_name,address,school_tel,school_website]
                        else
                            empArray = school_emp.split(":")

                           begin  emp_1_role = empArray[0] rescue "" end
                           begin emp_1_name = empArray[1].strip rescue "" end

                            csv << [p_url,s_name,s_loc,emp_1_role,emp_1_name,'','',address,school_tel,school_website]
                        end 
                    rescue Exception => e
                       puts "------\n Exception in details\n Exception Type : #{e.class}\n   Exception Message : #{e.message}\n-----" 
                    end
                
                end
            end
        rescue Exception => e
            puts "------\n Exception in while loop\n Exception Type : #{e.class}\n   Exception Message : #{e.message}\n-----"
        end
    current_page += 1
        
    end 
rescue Exception => e
    puts "------\n Exception in Main block\n Exception Type : #{e.class}\n   Exception Message : #{e.message}\n-----"
end
