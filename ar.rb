require 'pg'
require_relative 'active_record_connection.rb'
# Load all of our ActiveRecord::Base objects.
require_relative 'models/vacancy.rb' # vacancies table
require_relative 'models/ruby_vacancy.rb' # ruby_vacancies table
