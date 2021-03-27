# vacancies
namespace :vacancies do
  desc 'Display all vacancies'
  # all
  task :all do
    require_relative 'ar.rb'
    Vacancy.all.each do |v|
      puts "Title: #{v.title}"
      puts "Description: #{v.description}"
      puts "Details: #{v.details}" 
      puts "Uri: #{v.url}"
      puts
    end
  end

  # count
  desc 'Count all vacancies'
  task :count do
    require_relative 'ar.rb'
    puts Vacancy.count
  end

  # ruby
  desc 'Display all ruby vacancies'
  task :ruby do
    require_relative 'ar.rb'
    
    RubyVacancy.all.each do |rv|
      puts "Title: #{rv.title}"
      puts "Description: #{rv.description}"
      puts "Details: #{rv.details}" 
      puts "Uri: #{rv.url}"
      puts
    end
  end

  # ruby count
  desc 'Count all ruby vacancies'
  task :ruby_count do
    require_relative 'ar.rb'
    puts RubyVacancy.count
  end
end

# db
namespace :db do
  # up
  desc 'create vacancies table'
  task :vacancy_up do
    require_relative 'active_record_connection'
    require_relative 'db/migrate/001_create_vacancies.rb'

    CreateVacancies.migrate(:up)
  end

  # down
  desc 'drop vacancies table'
  task :vacancy_down do
    require_relative 'active_record_connection'
    require_relative 'db/migrate/001_create_vacancies.rb'

    CreateVacancies.migrate(:down)
  end

  # ruby up
  desc 'create ruby vacancies table'
  task :ruby_vacancy_up do
    require_relative 'active_record_connection'
    require_relative 'db/migrate/002_create_ruby_vacancies.rb'

    CreateRubyVacancies.migrate(:up)
  end

  # ruby down
  desc 'drop ruby vacancies table'
  task :ruby_vacancy_down do
    require_relative 'active_record_connection'
    require_relative 'db/migrate/002_create_ruby_vacancies.rb'

    CreateRubyVacancies.migrate(:down)
  end

  # seed all
  desc 'save all vacancies from site to database'
  task :seed_vacancies_all do
    require_relative 'my_parser.rb'
    require 'csv'
    
    parser = MyParser.new
    parser.get_login_page
    parser.login
    parser.get_jobs_page
    ruby_page = parser.page
    total_pages = parser.count_vacancies(parser.page) / parser.total_vacancies_on_page(parser.page)

    puts "Total vacancies: #{parser.count_vacancies(parser.page)}"
    puts "Pages: #{total_pages}"

    page = 1

      CSV.open('vacancies.csv', "w") do |csv|
        csv << %w[title details description url]
      end

    while page < 2 # to fetch all pages use - total_pages + 1
      parser.next_page(parser.page, page)
      titles = parser.search_by_element_class('a.profile')
      parser.seed(titles, 'title', opt = {text: true})
      
      parser.page = ruby_page
      
      parser.next_page(parser.page, page)
      parser.search_by_element_class('div.list-jobs__details')
      details = parser.format
      parser.seed(details, 'details', opt = {})

      parser.page = ruby_page

      parser.next_page(parser.page, page)
      parser.search_by_element_class('p')
      descriptions = parser.search_by_element_class('p')
      descriptions.shift
      descriptions.pop
      parser.seed(descriptions, 'description', opt = {text: true})

      parser.page = ruby_page

      parser.next_page(parser.page, page)
      urls = parser.search_by_element_class('a.profile')
      parser.seed(urls, 'url', opt = { href: true })

      parser.page = ruby_page

      parser.get_data.each do |d|
        vacancy = Vacancy.new
        vacancy.title = d[:title]
        vacancy.details = d[:details]
        vacancy.description = d[:description]
        vacancy.url = d[:url]
        vacancy.save

        title = d[:title]
        details = d[:details]
        description = d[:description]
        url = d[:url]

        CSV.open('vacancies.csv', "a") do |csv|
          csv << [title, details, description, url]
        end

      end      

      parser.page = ruby_page

      puts "Processed page: #{page}"
      page += 1
    end
  end

  # seed ruby
  desc 'save all ruby vacancies from site to database'
  task :seed_vacancies_ruby do
    require_relative 'my_parser.rb'
    
    parser = MyParser.new
    parser.get_login_page
    parser.login
    parser.get_jobs_page
    parser.select_category('Ruby')
    ruby_page = parser.page

    total_pages = parser.count_vacancies(parser.page) / parser.total_vacancies_on_page(parser.page)

    puts "Total vacancies: #{parser.count_vacancies(parser.page)}"
    puts "Pages: #{total_pages}"

    page = 1
    
    CSV.open('ruby_vacancies.csv', "w") do |csv|
      csv << %w[title details description url]
    end

    while page < 2  # to fetch all pages use - total_pages + 1
      parser.next_page(parser.page, page)
      titles = parser.search_by_element_class('a.profile')
      parser.seed(titles, 'title', opt = {text: true})

      parser.page = ruby_page

      parser.next_page(parser.page, page)
      parser.search_by_element_class('div.list-jobs__details')
      details = parser.format
      parser.seed(details, 'details', opt = {})

      parser.page = ruby_page

      parser.next_page(parser.page, page)
      parser.search_by_element_class('p')
      descriptions = parser.search_by_element_class('p')
      descriptions.shift
      descriptions.pop
      parser.seed(descriptions, 'description', opt = {text: true})

      parser.page = ruby_page

      parser.next_page(parser.page, page)
      urls = parser.search_by_element_class('a.profile')
      parser.seed(urls, 'url', opt = { href: true })

      parser.get_data.each do |d|
        ruby_vacancy = RubyVacancy.new
        ruby_vacancy.title = d[:title]
        ruby_vacancy.details = d[:details]
        ruby_vacancy.description = d[:description]
        ruby_vacancy.url = d[:url]
        ruby_vacancy.save

        title = d[:title]
        details = d[:details]
        description = d[:description]
        url = d[:url]

        CSV.open('ruby_vacancies.csv', "a") do |csv|
          csv << [title, details, description, url]
        end
      end

      parser.page = ruby_page
      
      puts "Processed page: #{page}"
      page += 1
    end
  end
end

namespace :csv do
  desc 'write all vacancies to vacancies.csv file'
  task :all do
    require_relative 'my_parser.rb'
    parser = MyParser.new
    parser.get_login_page
    parser.login
    parser.get_jobs_page
    page_with_all = parser.page
    total_pages = parser.count_vacancies(parser.page) / parser.total_vacancies_on_page(parser.page)

    puts "Total vacancies: #{parser.count_vacancies(parser.page)}"
    puts "Pages: #{total_pages}"

    page = 1

    CSV.open('vacancies.csv', "w") do |csv|
      csv << %w[title details description url]
    end

    while page < 2 # to fetch all pages use - total_pages + 1
      parser.next_page(parser.page, page)
      titles = parser.search_by_element_class('a.profile')
      parser.seed(titles, 'title', opt = {text: true})
      
      parser.page = page_with_all
      
      parser.next_page(parser.page, page)
      parser.search_by_element_class('div.list-jobs__details')
      details = parser.format
      parser.seed(details, 'details', opt = {})

      parser.page = page_with_all

      parser.next_page(parser.page, page)
      parser.search_by_element_class('p')
      descriptions = parser.search_by_element_class('p')
      descriptions.shift
      descriptions.pop
      parser.seed(descriptions, 'description', opt = {text: true})

      parser.page = page_with_all

      parser.next_page(parser.page, page)
      urls = parser.search_by_element_class('a.profile')
      parser.seed(urls, 'url', opt = { href: true })

      parser.page = page_with_all

      parser.get_data.each do |d|
        title = d[:title]
        details = d[:details]
        description = d[:description]
        url = d[:url]

        CSV.open('vacancies.csv', "a") do |csv|
          csv << [title, details, description, url]
        end

      end      

      parser.page = page_with_all

      puts "Processed page: #{page}"
      page += 1
    end
  end

  desc 'write all ruby vacancies to ruby_vacancies.csv file'
  task :ruby do
    require_relative 'my_parser.rb'
    parser = MyParser.new
    parser.get_login_page
    parser.login
    parser.get_jobs_page
    parser.select_category('Ruby')
    page_with_ruby = parser.page
    total_pages = parser.count_vacancies(parser.page) / parser.total_vacancies_on_page(parser.page)

    puts "Total vacancies: #{parser.count_vacancies(parser.page)}"
    puts "Pages: #{total_pages}"

    page = 1

    CSV.open('ruby_vacancies.csv', "w") do |csv|
      csv << %w[title details description url]
    end

    while page < 2 # to fetch all pages use - total_pages + 1
      parser.next_page(parser.page, page)
      titles = parser.search_by_element_class('a.profile')
      parser.seed(titles, 'title', opt = {text: true})
      
      parser.page = page_with_ruby
      
      parser.next_page(parser.page, page)
      parser.search_by_element_class('div.list-jobs__details')
      details = parser.format
      parser.seed(details, 'details', opt = {})

      parser.page = page_with_ruby

      parser.next_page(parser.page, page)
      parser.search_by_element_class('p')
      descriptions = parser.search_by_element_class('p')
      descriptions.shift
      descriptions.pop
      parser.seed(descriptions, 'description', opt = {text: true})

      parser.page = page_with_ruby

      parser.next_page(parser.page, page)
      urls = parser.search_by_element_class('a.profile')
      parser.seed(urls, 'url', opt = { href: true })

      parser.page = page_with_ruby

      parser.get_data.each do |d|
        title = d[:title]
        details = d[:details]
        description = d[:description]
        url = d[:url]

        CSV.open('ruby_vacancies.csv', "a") do |csv|
          csv << [title, details, description, url]
        end
      end      

      parser.page = page_with_ruby

      puts "Processed page: #{page}"
      page += 1
    end
  end
end