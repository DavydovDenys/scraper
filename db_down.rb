require_relative 'active_record_connection'
require_relative 'db/migrate/001_create_vacancies.rb'

CreateVacancies.migrate(:down)
