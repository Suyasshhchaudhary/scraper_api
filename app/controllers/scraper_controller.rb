class ScraperController < ApplicationController
  def scrape
    n = params[:n].to_i
    filters = params[:filters] || {}

    # Build the URL with filters
    url = build_url(filters)

    # Scrape the data
    scraped_data = scrape_ycombinator(url, n)

    # Convert the data to CSV format
    csv_data = convert_to_csv(scraped_data)

    # Send CSV data as response
    send_data csv_data, filename: 'ycombinator_companies.csv', type: 'text/csv'
  end

  private

  def build_url(filters)
    base_url = 'https://www.ycombinator.com/companies'
    query_params = []

    filters.each do |key, value|
      next if value.nil? || value.empty?

      case key
      when 'batch'
        query_params << "batch=#{value}"
      when 'industry'
        query_params << "industry=#{value}"
      when 'region'
        query_params << "region=#{value}"
      when 'tag'
        query_params << "tag=#{value}"
      when 'company_size'
        query_params << "company_size=#{value}"
      when 'is_hiring'
        query_params << "is_hiring=#{value}"
      when 'nonprofit'
        query_params << "nonprofit=#{value}"
      when 'black_founded'
        query_params << "black_founded=#{value}"
      when 'hispanic_latino_founded'
        query_params << "hispanic_latino_founded=#{value}"
      when 'women_founded'
        query_params << "women_founded=#{value}"
      end
    end

    "#{base_url}?#{query_params.join('&')}"
  end

  def scrape_ycombinator(url, n)
    scraped_data = []
    page_number = 1

    while scraped_data.size < n
      response = HTTParty.get("#{url}&page=#{page_number}")
      document = Nokogiri::HTML(response.body)

      companies = document.css('.company-item')
      companies.each do |company|
        break if scraped_data.size >= n

        name = company.css('.company-name').text.strip
        location = company.css('.company-location').text.strip
        description = company.css('.company-description').text.strip
        batch = company.css('.company-batch').text.strip

        company_link = company.css('a').first['href']
        company_page = HTTParty.get(company_link)
        company_document = Nokogiri::HTML(company_page.body)

        website = company_document.css('.company-website').text.strip
        founders = company_document.css('.founder-name').map(&:text).map(&:strip)
        linkedin_urls = company_document.css('.founder-linkedin').map { |link| link['href'] }

        scraped_data << {
          name: name,
          location: location,
          description: description,
          batch: batch,
          website: website,
          founders: founders.join(', '),
          linkedin_urls: linkedin_urls.join(', ')
        }
      end

      page_number += 1
    end

    scraped_data
  end

  def convert_to_csv(data)
    CSV.generate(headers: true) do |csv|
      csv << ['Company Name', 'Location', 'Description', 'YC Batch', 'Website', 'Founders', 'LinkedIn URLs']
      data.each do |item|
        csv << [item[:name], item[:location], item[:description], item[:batch], item[:website], item[:founders], item[:linkedin_urls]]
      end
    end
  end
end
