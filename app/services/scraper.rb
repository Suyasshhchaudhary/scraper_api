require 'selenium-webdriver'
require 'webdrivers'
class Scraper

  BASE_URL = 'https://www.ycombinator.com'
  COMPANIES_URL = BASE_URL + '/companies'

  API_QUERY_PARAMETER_NAMES = {
    'top companies': :top_company,
    'is hiring': :isHiring,
    'nonprofit': :nonprofit,
    'black founded': :highlight_black,
    'hispanic & latino founded': :highlight_latinx,
    'women founded': :highlight_women,
    'public application video': :app_video_public,
    'public demo day video': :demo_day_video_public,
    'has application answers': :app_answers,
    'has bonus questions': :question_answers
  }

  PER_PAGE=40

  def initialize(number_of_records: PER_PAGE, filters: {})
    @number_of_records = number_of_records.to_i
    @filters = process_filters(filters)
  end


  def scrape
    begin
      load_page
      sleep 2
      load_desire_content
      get_companies_details
    ensure
      driver.quit
      @driver = nil
    end
  end

  private

  def get_companies_details
    first_page_code = """
    return Array.from(document.querySelectorAll('a._company_86jzd_338')).slice(0,#{@number_of_records}).map(function(a){
    let name = a.querySelector('._coName_86jzd_453').innerText;
    let url = a.getAttribute('href');
    let location = a.querySelector('._coLocation_86jzd_469').innerText;
    let short_description = a.querySelector('._coDescription_86jzd_478').innerText;
    let batch = a.querySelector('._pill_86jzd_33').innerText;
    return {name: name, url: url, location: location, short_description: short_description, batch: batch};})
    """
    second_page_code = """
    let website = document.querySelector('a.mb-2.whitespace-nowrap').getAttribute('href');
    let founders = Array.from(document.querySelectorAll('div.leading-snug')).map(function(f){let name = f.querySelector('div.font-bold').innerText; let linkedIn_node = f.querySelector('a.bg-image-linkedin'); let linkedIn_profile = ''; if(linkedIn_node !== null){linkedIn_profile =  linkedIn_node.getAttribute('href');} return {name: name, linkedIn_profile: linkedIn_profile}; })
    return {website: website, founders: founders}
    """

    companies_data = driver.execute_script(first_page_code)
    companies_data.each do|company_data|
      company_url = BASE_URL + company_data.delete('url')
      driver.get(company_url)
      company_data.merge!driver.execute_script(second_page_code)
    end
    companies_data
  end

  def scroll_to_bottom
    driver.execute_script('window.scrollTo(0, document.body.scrollHeight);')
    sleep 2
  end

  def load_desire_content
    return if @number_of_records <= 40
    scroll_count = 1
    last_height = driver.execute_script('return document.body.scrollHeight')
    loop do
      scroll_to_bottom
      scroll_count +=1
      new_height = driver.execute_script('return document.body.scrollHeight')
      break if new_height == last_height || scroll_count * PER_PAGE >= @number_of_records
      last_height = new_height
    end
  end

  def process_filters(filters)
    filters.keys.each do |key|
      if new_key = API_QUERY_PARAMETER_NAMES[key.to_s.downcase.to_sym]
        filters[new_key] = filters.delete(key)
      end
    end
    filters['team_size'] = filters['team_size'].to_json if filters['team_size'].is_a?(Array)
    filters

  end

  def url
    uri = URI(COMPANIES_URL)
    uri.query = URI.encode_www_form(@filters) if @filters.any?
    uri.to_s
  end

  def load_page
    driver.get(url)
  end

  def driver
    return @driver if @driver
    options = Selenium::WebDriver::Firefox::Options.new
    options.add_argument('--headless')
    @driver = Selenium::WebDriver.for :firefox, options: options
    @driver
  end
end
