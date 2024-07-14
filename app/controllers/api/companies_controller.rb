class Api::CompaniesController < ApplicationController
  def index
    scraper = Scraper.new(number_of_records: filter_params[:n], filters: filter_params[:filters].to_h)
    companies = scraper.scrape

    respond_to do |format|
      format.csv { render csv: companies, filename: "companies-#{Date.today}", default_headers: %i(batch location name short_description founders website) }
      format.json {render json: companies }
    end
  end


  private

  def filter_params
    params.permit(:n, filters: [
      :'top companies',
      :'is hiring',
      :'nonprofit',
      :'black founded',
      :'hispanic & latino founded',
      :'women founded',
      :'public application video',
      :'public demo day video',
      :'has application answers',
      :'has bonus questions',
      :team_size,
      batch: [],
      industry: [],
      regions:[],
      tags: [],
    ])
  end
end
