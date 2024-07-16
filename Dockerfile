# Use the official Ruby image
FROM ruby:3.1.1

ENV GECKODRIVER_VERSION='v0.34.0'
# Install dependencies
RUN apt-get update && \
    apt-get install -y \
        firefox-esr \
        curl \
        unzip \
        xvfb \
        libxi6 \
        libgconf-2-4

# Install Geckodriver
RUN wget -q "https://github.com/mozilla/geckodriver/releases/download/${GECKODRIVER_VERSION}/geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz" && \
    tar -xzf "geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz" -C /usr/local/bin && \
    rm "geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz"

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