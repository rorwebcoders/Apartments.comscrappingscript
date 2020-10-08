
# -*- encoding : utf-8 -*-
require 'csv'
require 'nokogiri'
require 'open-uri'
# require 'mysql2'
require 'openssl'
# require 'watir'
# require 'watir-webdriver'
# require 'headless'
# require 'headless'
require 'byebug'
require 'json'
 
 def Details()
    lis=["Bellfield-3081-VIC","Bennettswood-3125-VIC","Bentleigh-3204-VIC","Bentleigh-East-3165-VIC","Berwick-3806-VIC","Bittern-3918-VIC","Black-Rock-3193-VIC","Blackburn-3130-VIC","Blackburn-North-3130-VIC","Blackburn-South-3130-VIC","Blairgowrie-3942-VIC","Bonbeach-3196-VIC","Boronia-3155-VIC","Box-Hill-3128-VIC","Box-Hill-North-3129-VIC","Box-Hill-South-3128-VIC","Braeside-3195-VIC","Braybrook-3019-VIC","Briar-Hill-3088-VIC","Brighton-3186-VIC","Brighton-East-3187-VIC","Broadmeadows-3047-VIC","Brookfield-3338-VIC","Brooklyn-3012-VIC","Brunswick-3056-VIC","Brunswick-East-3057-VIC","Brunswick-West-3055-VIC","Bulla-3428-VIC","Bulleen-3105-VIC","Bundoora-3083-VIC","Burnley-3121-VIC","Burnside-3023-VIC","Burnside-Heights-3023-VIC","Burwood-3125-VIC","Burwood-East-3151-VIC","Cairnlea-3023-VIC","Calder-Park-3037-VIC","Camberwell-3124-VIC","Campbellfield-3061-VIC","Canterbury-3126-VIC","Carlton-North-3054-VIC","Carlton-3053-VIC","Carnegie-3163-VIC","Caroline-Springs-3023-VIC","Carrum-3197-VIC","Carrum-Downs-3201-VIC","Caulfield-3162-VIC","Caulfield-East-3145-VIC","Caulfield-North-3161-VIC","Caulfield-South-3162-VIC","Chadstone-3148-VIC","Chelsea-3196-VIC","Chelsea-Heights-3196-VIC","Cheltenham-3192-VIC","Chirnside-Park-3116-VIC","Clarinda-3169-VIC","Clayton-3168-VIC","Clayton-South-3169-VIC","Clematis-3782-VIC","Clifton-Hill-3068-VIC","Coburg-3058-VIC","Coburg-North-3058-VIC","Cocoroc-3030-VIC","Coldstream-3770-VIC","Collingwood-3066-VIC","Coolaroo-3048-VIC","Craigieburn-3064-VIC","Cranbourne-3977-VIC","Cranbourne-East-3977-VIC","Cranbourne-North-3977-VIC","Cranbourne-South-3977-VIC","Cranbourne-West-3977-VIC","Cremorne-3121-VIC","Crib-Point-3919-VIC","Croydon-3136-VIC","Croydon-Hills-3136-VIC","Croydon-North-3136-VIC","Croydon-South-3136-VIC","Dallas-3047-VIC","Dandenong-3175-VIC","Dandenong-North-3175-VIC","Dandenong-South-3175-VIC","Deer-Park-3023-VIC","Delahey-3037-VIC","Derrimut-3026-VIC","Diamond-Creek-3089-VIC","Dingley-Village-3172-VIC","Docklands-3008-VIC","Doncaster-3108-VIC","Doncaster-East-3109-VIC","Donvale-3111-VIC","Doreen-3754-VIC","Doveton-3177-VIC","Dromana-3936-VIC","Eaglemont-3084-VIC","East-Melbourne-3002-VIC","Edithvale-3196-VIC","Elsternwick-3185-VIC","Eltham-3095-VIC","Eltham-North-3095-VIC","Elwood-3184-VIC","Emerald-3782-VIC","Endeavour-Hills-3802-VIC","Epping-3076-VIC","Essendon-Fields-3041-VIC","Essendon-North-3041-VIC","Essendon-West-3040-VIC","Essendon-3040-VIC","Eumemmerring-3177-VIC","Fairfield-3078-VIC","Fawkner-3060-VIC","Ferntree-Gully-3156-VIC","Ferny-Creek-3786-VIC","Fitzroy-3065-VIC","Fitzroy-North-3068-VIC","Flemington-3031-VIC","Footscray-3011-VIC","Forest-Hill-3131-VIC","Frankston-3199-VIC","Frankston-North-3200-VIC","Frankston-South-3199-VIC","Gardenvale-3185-VIC","Gladstone-Park-3043-VIC","Glen-Huntly-3163-VIC","Glen-Iris-3146-VIC","Glen-Waverley-3150-VIC","Glenroy-3046-VIC","Gowanbrae-3043-VIC","Greensborough-3088-VIC","Greenvale-3059-VIC","Guys-Hill-3807-VIC","Hadfield-3046-VIC","Hallam-3803-VIC","Hampton-3188-VIC","Hampton-East-3188-VIC","Hampton-Park-3976-VIC","Harkaway-3806-VIC","Hawthorn-3122-VIC","Hawthorn-East-3123-VIC","Heatherton-3202-VIC","Heathmont-3135-VIC","Heidelberg-3084-VIC","Heidelberg-Heights-3081-VIC","Heidelberg-West-3081-VIC","Highett-3190-VIC","Hillside-3037-VIC","Hoppers-Crossing-3029-VIC","Houston-3128-VIC","Hughesdale-3166-VIC","Huntingdale-3166-VIC","Hurstbridge-3099-VIC","Ivanhoe-3079-VIC","Ivanhoe-East-3079-VIC","Jacana-3047-VIC","Junction-Village-3977-VIC","Kallista-3791-VIC","Kalorama-3766-VIC","Kealba-3021-VIC","Keilor-3036-VIC","Keilor-Downs-3038-VIC","Keilor-East-3033-VIC","Keilor-Lodge-3038-VIC","Keilor-North-3036-VIC","Keilor-Park-3042-VIC","Kensington-3031-VIC","Kerrimuir-3129-VIC","Kew-3101-VIC","Kew-East-3102-VIC","Keysborough-3173-VIC","Kilsyth-3137-VIC","Kilsyth-South-3137-VIC","Kings-Park-3021-VIC","Kingsbury-3083-VIC","Kingsville-3012-VIC","Knoxfield-3180-VIC","Kooyong-3144-VIC","Kurunjang-3337-VIC","Laburnum-3130-VIC","Lalor-3075-VIC","Langwarrin-3910-VIC","Langwarrin-South-3911-VIC","Laverton-3028-VIC","Laverton-North-3026-VIC","Lilydale-3140-VIC","Lower-Plenty-3093-VIC","Lynbrook-3975-VIC","Lyndhurst-3975-VIC","Lysterfield-3156-VIC","Lysterfield-South-3156-VIC","Macclesfield-3782-VIC","Mccrae-3938-VIC","Mckinnon-3204-VIC","Macleod-3085-VIC","Maidstone-3012-VIC","Malvern-3144-VIC","Malvern-East-3145-VIC","Maribyrnong-3032-VIC","Meadow-Heights-3048-VIC","Melbourne-Airport-3045-VIC","Melton-South-3338-VIC","Melton-West-3337-VIC","Mentone-3194-VIC","Menzies-Creek-3159-VIC","Mernda-3754-VIC","Mickleham-3064-VIC","Middle-Park-3206-VIC","Mill-Park-3082-VIC","Mitcham-3132-VIC","Monbulk-3793-VIC","Mont-Albert-3127-VIC","Mont-Albert-North-3129-VIC","Montmorency-3094-VIC","Montrose-3765-VIC","Moonee-Ponds-3039-VIC","Moorabbin-Airport-3194-VIC","Moorabbin-3189-VIC","Moorooduc-3933-VIC","Mooroolbark-3138-VIC","Mordialloc-3195-VIC","Mornington-3931-VIC","Mount-Dandenong-3767-VIC","Mount-Eliza-3930-VIC","Mount-Evelyn-3796-VIC","Mount-Martha-3934-VIC","Mount-Waverley-3149-VIC","Mulgrave-3170-VIC","Narre-Warren-East-3804-VIC","Narre-Warren-North-3804-VIC","Narre-Warren-South-3805-VIC","Narre-Warren-3805-VIC","Newport-3015-VIC","Niddrie-3042-VIC","Noble-Park-3174-VIC","Noble-Park-North-3174-VIC","North-Melbourne-3051-VIC","North-Warrandyte-3113-VIC","Northcote-3070-VIC","Notting-Hill-3168-VIC","Nunawading-3131-VIC","Oak-Park-3046-VIC","Oaklands-Junction-3063-VIC","Oakleigh-3166-VIC","Oakleigh-East-3166-VIC","Oakleigh-South-3167-VIC","Olinda-3788-VIC","Olivers-Hill-3199-VIC","Ormond-3204-VIC","Pakenham-3810-VIC","Panton-Hill-3759-VIC","Park-Orchards-3114-VIC","Parkdale-3195-VIC","Parkville-3052-VIC","Pascoe-Vale-South-3044-VIC","Pascoe-Vale-3044-VIC","The-Patch-3792-VIC","Patterson-Lakes-3197-VIC","Plenty-3090-VIC","Point-Cook-3030-VIC","Port-Melbourne-3207-VIC","Portsea-3944-VIC","Prahran-3181-VIC","Preston-3072-VIC","Princes-Hill-3054-VIC","Ravenhall-3023-VIC","Research-3095-VIC","Reservoir-3073-VIC","Richmond-3121-VIC","Ringwood-3134-VIC","Ringwood-East-3135-VIC","Ringwood-North-3134-VIC","Ripponlea-3185-VIC","Rockbank-3335-VIC","Rosanna-3084-VIC","Rosebud-3939-VIC","Rowville-3178-VIC","Roxburgh-Park-3064-VIC","Rye-3941-VIC","Safety-Beach-3936-VIC","St-Albans-3021-VIC","St-Helena-3088-VIC","St-Kilda-3182-VIC","St-Kilda-East-3183-VIC","St-Kilda-West-3182-VIC","Sandhurst-3977-VIC","Sandringham-3191-VIC","Sassafras-3787-VIC","Scoresby-3179-VIC","Seabrook-3028-VIC","Seaford-3198-VIC","Seaholme-3018-VIC","Seddon-3011-VIC","Selby-3159-VIC","Seville-3139-VIC","Sherbrooke-3789-VIC","Skye-3977-VIC","Somerton-3062-VIC","Sorrento-3943-VIC","South-Kingsville-3015-VIC","South-Melbourne-3205-VIC","South-Morang-3752-VIC","South-Wharf-3006-VIC","South-Yarra-3141-VIC","Southbank-3006-VIC","Spotswood-3015-VIC","Springvale-3171-VIC","Springvale-South-3172-VIC","Strathmore-3041-VIC","Strathmore-Heights-3041-VIC","Sunbury-3429-VIC","Sunshine-3020-VIC","Sunshine-North-3020-VIC","Sunshine-West-3020-VIC","Surrey-Hills-3127-VIC","Sydenham-3037-VIC","Tarneit-3029-VIC","Taylors-Hill-3037-VIC","Taylors-Lakes-3038-VIC","Tecoma-3160-VIC","Templestowe-3106-VIC","Templestowe-Lower-3107-VIC","The-Basin-3154-VIC","Thomastown-3074-VIC","Thornbury-3071-VIC","Toorak-3142-VIC","Tootgarook-3941-VIC","Tottenham-3012-VIC","Travancore-3032-VIC","Tremont-3785-VIC","Truganina-3029-VIC","Tullamarine-3043-VIC","Upper-Ferntree-Gully-3156-VIC","Upwey-3158-VIC","Vermont-3133-VIC","Vermont-South-3133-VIC","Viewbank-3084-VIC","Wantirna-3152-VIC","Wantirna-South-3152-VIC","Warrandyte-3113-VIC","Warrandyte-South-3134-VIC","Warranwood-3134-VIC","Waterways-3195-VIC","Watsonia-3087-VIC","Watsonia-North-3087-VIC","Wattle-Glen-3096-VIC","Werribee-3030-VIC","Werribee-South-3030-VIC","West-Footscray-3012-VIC","West-Melbourne-3003-VIC","Westmeadows-3049-VIC","Wheelers-Hill-3150-VIC","Wildwood-3429-VIC","Williams-Landing-3027-VIC","Williamstown-3016-VIC","Williamstown-North-3016-VIC","Windsor-3181-VIC","Wonga-Park-3115-VIC","Wyndham-Vale-3024-VIC","Yallambie-3085-VIC","Yarrambat-3091-VIC","Yarraville-3013-VIC","Yuroke-3063-VIC"]

  lis.each do |l|
    begin
     @i = 1
     search_url = "https://www.realestate.com.au/find-agent/"+l+"?source=results"
        parsed_doc = Nokogiri::HTML(open(search_url), nil, 'utf-8')
          puts "-------------------------------------#{@num = parsed_doc.at_css("div.PaginationBar div").text.split.last.to_i}"
          
          while @i < @num +1  do
   puts search_url = "https://www.realestate.com.au/find-agent/"+l+"?source=results&page=#{@i}"
        doc_1 = Nokogiri::HTML(open(search_url), nil, 'utf-8')
        temp_1 = doc_1.css("div.agent-card.agent")
        # puts temp_1.count
        temp_1.each do |t_1|
  # byebug
          begin
           name = t_1.css("div.agent-profile__name").text
            rescue Exception => ex
              puts "-----\nException in  name:\n   Exception Type : #{ex.class}\n   Exception Message : #{ex.message}\n-----"
            end
            begin
           puts agent_id = t_1.css("div.agent-card__details a")[0]["href"].split("&origin").first.split("?agentIds=").last
            rescue  Exception => ex
              puts "-----\nException in  agent_id:\n   Exception Type : #{ex.class}\n   Exception Message : #{ex.message}\n-----"
            end
            begin
           puts agent_url = "https://www.realestate.com.au/agent/"+name.split(" ").join("-")+"-"+agent_id
            rescue Exception => ex
              puts "-----\nException in  agent_url:\n   Exception Type : #{ex.class}\n   Exception Message : #{ex.message}\n-----"
            end
            begin
            total_properties = t_1.css("div.agent-card__stats--always-inline div.key-feature")[0].text.gsub("Total"," Total").strip() 
          rescue Exception => ex
              puts "-----\nException in  total_properties:\n   Exception Type : #{ex.class}\n   Exception Message : #{ex.message}\n-----"
            end
            begin
            property_sales_in = t_1.css("div.agent-card__stats--always-inline div.key-feature")[1].text.gsub("Property"," Property").gsub("Properties"," Properties").strip() 
          rescue Exception => ex
              puts "-----\nException in  property_sales_in:\n   Exception Type : #{ex.class}\n   Exception Message : #{ex.message}\n-----"
            end
            begin
            median_sold_price = t_1.css("div.agent-card__stats--always-inline div.key-feature")[2].text.gsub("Median"," Median").strip() 
          rescue Exception => ex
              puts "-----\nException in  median_sold_price:\n   Exception Type : #{ex.class}\n   Exception Message : #{ex.message}\n-----"
            end
            begin
            median_days = t_1.css("div.agent-card__stats--always-inline div.key-feature")[3].text.gsub("Median"," Median").strip() 
          rescue Exception => ex
              puts "-----\nException in  median_days:\n   Exception Type : #{ex.class}\n   Exception Message : #{ex.message}\n-----"
            end
            begin
            no_exp = t_1.css("div.agent-profile__experience").text.strip() 
          rescue Exception => ex
              puts "-----\nException in no_exp:\n   Exception Type : #{ex.class}\n   Exception Message : #{ex.message}\n-----"
            end
            begin
          doc = Nokogiri::HTML(open(agent_url), nil, 'utf-8')
          job_title =  doc.css("h2.hero-description-standard__job-title").text  
        rescue Exception => ex
              puts "-----\nException in  job_title:\n   Exception Type : #{ex.class}\n   Exception Message : #{ex.message}\n-----"
            end
           full = doc.to_s.split('window.__APOLLO_STATE__=').last.split("</script>").first.split("window.__APP_CONFIG__").first.gsub("}};","}}")
          full_json = JSON.parse(full)
      begin
      phone = full_json["$Agent:"+agent_id+".phone"]["mobile"]  
    rescue Exception => ex
              puts "-----\nException in  phone:\n   Exception Type : #{ex.class}\n   Exception Message : #{ex.message}\n-----"
            end
            begin
      sold= doc.css("h4.standard-listings-sub-header")[0].text 
    rescue Exception => ex
              puts "-----\nException in  sold:\n   Exception Type : #{ex.class}\n   Exception Message : #{ex.message}\n-----"
            end
            begin
      for_sale = doc.css("h4.standard-listings-sub-header")[1].text 
    rescue Exception => ex
              puts "-----\nException in  for_sale:\n   Exception Type : #{ex.class}\n   Exception Message : #{ex.message}\n-----"
            end
            begin
      for_rent = doc.css("h4.standard-listings-sub-header")[2].text 
    rescue Exception => ex
              puts "-----\nException in  for_rent:\n   Exception Type : #{ex.class}\n   Exception Message : #{ex.message}\n-----"

        end
           puts ["#{l}","#{name}","#{agent_id}","#{agent_url}","#{no_exp.to_s}","#{phone}","#{sold}","#{for_sale}","#{for_rent}","#{property_sales_in}","#{median_sold_price}","#{median_days}","#{total_properties}","#{job_title}"]

       $csv << ["#{l}","#{name}","#{agent_id}","#{agent_url}","#{no_exp.to_s}","#{phone}","#{sold}","#{for_sale}","#{for_rent}","#{property_sales_in}","#{median_sold_price}","#{median_days}","#{total_properties}","#{job_title}"]
       $csv.flush
        

        end


        @i=@i+1
      end
      rescue Exception => ex
          puts "-----\nException in  main block:\n   Exception Type : #{ex.class}\n   Exception Message : #{ex.message}\n-----"
      end
      # byebug
  end
end

CSV.open("real_estate_new_output_1.csv", "wb",{:col_sep => "~"}) do |csv|
  csv << ["Suburb","Name","agent_id","agent_url","no_exp", "phone","sold","for_sale","for_rent","property_sales_in","median_sold_price","median_days","total_properties","job_title"]
    $csv = csv
  Details()
end


