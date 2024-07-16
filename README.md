# Y Combinator Companies Scraper

This Ruby on Rails application scrapes data from Y Combinator's publicly listed companies. It allows users to fetch a specified number of records with various filters applied through an API endpoint in csv as well as json format.

## Installation

1. **Clone the repository:**

   ```sh
   git clone https://github.com/your-username/yc-companies-scraper.git
   cd yc-companies-scraper
   ```

2. **Install dependencies:**

   ```sh
   bundle install
   ```

3. **Set up the database:**

   ```sh
   rails db:create
   rails db:migrate
   ```

4. **Run the server:**

   ```sh
   rails server
   ```

## API Endpoint

### GET api/companies

Fetches a specified number of company records with optional filters.

#### Parameters

- `n` (optional default 40): Number of records to fetch.
- `filters` (optional): A hash of filter parameters.

#### Filter Parameters

| Parameter                  | Type                     | Description                                                   |
|----------------------------|--------------------------|---------------------------------------------------------------|
| top companies              | Boolean (default: false) | Filters for top companies                                     |
| is hiring                  | Boolean (default: false) | Filters for companies that are hiring                         |
| nonprofit                  | Boolean (default: false) | Filters for nonprofit companies                               |
| black founded              | Boolean (default: false) | Filters for black-founded companies                           |
| hispanic & latino founded  | Boolean (default: false) | Filters for Hispanic and Latino-founded companies             |
| women founded              | Boolean (default: false) | Filters for women-founded companies                           |
| public application video   | Boolean (default: false) | Filters for companies with public application videos          |
| public demo day video      | Boolean (default: false) | Filters for companies with public demo day videos             |
| has application answers    | Boolean (default: false) | Filters for companies with application answers                |
| has bonus questions        | Boolean (default: false) | Filters for companies with bonus questions                    |
| team_size                  | Array                    | Filters for companies by team size                            |
| batch                      | Array                    | Filters for companies by batch                                |
| industry                   | Array                    | Filters for companies by industry                             |
| regions                    | Array                    | Filters for companies by region                               |
| tags                       | Array                    | Filters for companies by tags                                 |

#### Example Request

```sh
curl -G 'http://localhost:3000/scrape' \
  --data-urlencode 'n=50' \
  --data-urlencode 'filters[top companies]=true' \
  --data-urlencode 'filters[is hiring]=true' \
  --data-urlencode 'filters[team_size][]=1-10' \
  --data-urlencode 'filters[team_size][]=11-50' \
  --data-urlencode 'filters[batch][]=W21' \
  --data-urlencode 'filters[industry][]=software' \
  --data-urlencode 'filters[regions][]=North America' \
  --data-urlencode 'filters[tags][]=B2B'
```

### Response

The response will be a JSON array of company objects with the following attributes:

- `name`: String. The name of the company.
- `location`: String. The location of the company.
- `short_description`: String. A short description of the company.
- `batch`: String. The batch of the company.
- `website`: String. The website of the company.
- `founders`: Array. An array of founder objects, each containing:
- `name`: String. The name of the founder.
- `linkedIn_profile`: String. The LinkedIn profile URL of the founder.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Suyasshhchaudhary/scraper_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the Contributor Covenant code of conduct.

