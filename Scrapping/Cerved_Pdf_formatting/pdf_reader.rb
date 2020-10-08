# frozen_string_literal: false

require 'pdf-reader'
require 'csv'
require 'date'
require 'nokogiri'
require 'byebug'

directories = Dir["PDF/LOVEThESIGN"]

directories.each_with_index do |each_directory, directory_index|
  puts "Working on directory #{directory_index+1}) #{each_directory}"
  
  CSV.open("Output/extracted_output_#{each_directory.split('/').last}.csv", 'w', { col_sep: '~' }) do |csv|
    csv << ['Data atto', 'Denominazione/ Nominativo', 'Quote/Azioni', 'Data atto', 'Denominazione/ Nominativo', 'Quote/Azioni']

    array_1 = []
    array_2 = []
    empty_data = []
    
    pdf_files = Dir["#{each_directory}/*.pdf"].sort

    pdf_files.each_with_index do |each_pdf,i|
      reader = PDF::Reader.new(each_pdf)

      data_atto = reader.pages[0].text.split("\n").select{|e| e.include? 'Data atto'}.first.sub('Data atto','').strip

      Dir.mkdir("HTML_out/#{each_directory.gsub('PDF/','')}") unless File.exists?("HTML_out/#{each_directory.gsub('PDF/','')}")

      puts "pdftohtml -enc UTF-8 -noframes \"#{each_pdf}\" extracted_pdf_html.html"

      `pdftohtml.exe \"#{each_pdf}\" "HTML_out/#{each_directory.gsub('PDF/','')}/#{each_directory.gsub('PDF/','')}"`

       html_page = Nokogiri::HTML (open("HTML_out/#{each_directory.gsub('PDF/','')}/#{each_directory.gsub('PDF/','')}s.html"))

       # byebug

      reader.pages[1..-1].each do |each_page|
        main_data = each_page.text.split("\n").select{|e| e =~ /^[0-9]*\. /}

        data_array = each_page.text.split("\n").reject{|e| e=="" || e.strip=="Realizzato da Cerved su informazioni di Soci ed altri Archivi"}
        main_data_index = []
        main_data.each_with_index do |each_main,index|
          main_data_index << data_array.index{|e| e == each_main}
        end
        main_data_index << data_array.count

        main_data.each_with_index do |each_main,index|
          html_start_word = each_main.gsub(/^[0-9]*\./,"").split("    ").first.gsub(/\([a-z\d]*\)/,"").strip.gsub("'","\\'").split(" ").first
          
          html_contains_text = each_main.gsub(/^[0-9]*\./,"").split("    ").first.gsub(/\([a-z\d]*\)/,"").strip.split(" ").reject{|e| e.include? "'"}.join("'):contains('")
          
          main_data[index] = html_page.xpath("//b[starts-with(text(),'#{html_start_word}')]").css(":contains('#{html_contains_text}')").first.text.split(" ").join(" ")
        end
        # byebug
        if main_data_index.count > 1
          
          main_data_index.each_with_index do |each_data,index|
            search_array = data_array[each_data..main_data_index[index+1]]
            
            data_index = search_array.index{|e| e =~ (/[0-9,]*%/)}
            
            begin 
              key = main_data[index].gsub(/^[0-9]*\./,"").split("    ").first.gsub(/\([a-z\d]*\)/,"").strip
              key = "PROGRAMMA 101 SOCIETA' DI INVESTIMENTO A CAPITALEFISSO S.P.A. O, IN FORMA ABBREVIATA, \"P 101 SICAF S.P.A.\"" if key=="PROGRAMMA 101 SOCIETA' DI INVESTIMENTO A CAPITALEFISSO S.P.A. O, IN FORMA ABBREVIATA, \"P 101 SICAFS.P.A.\"" 
              quote = search_array[data_index].scan(/[0-9,]*%/).first

              if i==0
                
                array_1.push([data_atto,key,quote])
                
                array_2.push(["","","",""])
              
              end

              if i > 0

                if array_1.select{|e| e.include? key}.count > 0

                	if array_2.select{|e| e.include? key}.count > 0
                		
                		value = array_2.select{|e| e.include? key}

                  else
                  	
                  	value = array_1.select{|e| e.include? key}

                  end

                  if value.last.flatten[2].gsub(',','.').gsub('%','').to_f < quote.gsub(',','.').gsub('%','').to_f

                    number = quote.gsub(',','.').gsub('%','').to_f - value.last.flatten[2].gsub(',','.').gsub('%','').to_f

                    increased_quote = "#{sprintf('%.2f', number).gsub('.',',')}%"
                  
                    array_2.push([data_atto,key,quote,increased_quote])
                    
                    array_1.push([data_atto,"",""])
                  
                  end

                else
                  
                  array_1.push([data_atto,key,quote])
                  
                  array_2.push(["","","",""])
                  
                end

              end

              rescue
                key = main_data[index].gsub(/^[0-9]*\./,"").split("    ").first.gsub(/\([a-z\d]*\)/,"").strip

                empty_data.push("Issue in #{each_directory}in #{key}")

              end

            break if index == main_data_index.count - 2
          end
        end

      end
    end

    array_1.zip array_2.each do |a1, a2|

      csv << [a1[0],a1[1],a1[2],a2[0],a2[1],a2[3]]

    end

    puts empty_data

  end

end

