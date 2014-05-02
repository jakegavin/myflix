source 'https://rubygems.org'
ruby '2.0.0'

gem 'bootstrap-sass'
gem 'bootstrap_form', github: 'bootstrap-ruby/rails-bootstrap-forms'
gem 'coffee-rails'
gem 'rails'
gem 'haml-rails'
gem 'sass-rails'
gem 'uglifier'
gem 'jquery-rails'
gem 'bcrypt-ruby'

gem 'sidekiq'
gem 'unicorn'

gem 'sentry-raven'
gem 'paratrooper'

group :development, :staging do
  gem 'letter_opener_web', '~> 1.2.0'
  gem 'letter_opener'
end

group :development do
  gem 'sqlite3'
  gem 'pry'
  gem 'pry-nav'
  gem 'thin'
  gem "better_errors"
  gem "binding_of_caller"
  gem 'letter_opener'
end

group :production, staging do
  gem 'pg'
  gem 'rails_12factor'
end

group :test, :development do 
  gem 'rspec-rails'
  gem 'fabrication'
  gem 'faker'
end

group :test do
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'capybara-email'
  gem 'launchy'
end
