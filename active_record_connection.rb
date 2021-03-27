require 'active_record'
require 'dotenv/load'

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  host: 'localhost',
  username: ENV['DB_USERNAME'],
  password: ENV['DB_PASSWORD'],
  database: 'vacancies'
)
