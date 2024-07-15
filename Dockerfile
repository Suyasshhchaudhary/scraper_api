# Use the official Ruby image
FROM ruby:3.1.1

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock ./

# Install the gems
RUN bundle install --without development test

# Copy the rest of the application code
COPY . .

# Expose port 3000 to the host
EXPOSE 3000

# Start the main process
CMD ["bundle", "exec", "./bin/rails", "server", "-b", "0.0.0.0"]