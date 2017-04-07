class CityController < ApplicationController
	def index
		@city =City.paginate(:page => params[:page], :per_page => 10)
    end	

    def crawl_address
		browser = Watir::Browser.new :chrome
		headless = Headless.new
		headless.start
		browser.goto "http://www.latlong.net/category/cities-102-15.html"
        extract_datas(browser)		

		l = browser.link(:href =>"/category/cities-102-15-2.html")
		count = 2
		while l.exists?
		l.click
		sleep 3
		 extract_datas(browser)
		 count += 1
		 break if count == 5
		 l = browser.link(:href =>"/category/cities-102-15-#{count}.html")
		end

		browser.close
		redirect_to root_path
    end
   
    def extract_datas(browser)
    	page = Nokogiri::HTML(browser.html)
		rows = page.xpath("html/body/main/div/div[1]/table/tbody/tr")

		details = rows.collect do |row|
		  detail = {}
		  [
		    [:name, 'td[1]/a/text()'],
		    [:latitude, 'td[2]/text()'],
		    [:longitude, 'td[2]/text()']
		  ].each do |name, xpath|
		    detail[name] = row.at_xpath(xpath).to_s.strip
		  end
		  detail
		end
		details.delete_at(0)

		save_extracted details
    end 

    def save_extracted data_to_save
    	data_to_save.each do |city_params|
          @city = City.new(city_params)
          splited_address = @city.name.split(",")
          @city.name = splited_address[0 .. -3].join
          @city.state = splited_address[-2]
          @city.country = splited_address[-1]
          @city.save!
    	end
    end

    def destroy_addresses
    	@city =City.delete_all
    	redirect_to root_path
    end

end
