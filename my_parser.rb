require_relative 'lib/Parser'
require_relative 'ar.rb'
require 'csv'

# collect data from site
class MyParser
  include Parser
  attr_accessor :page
  attr_reader :data

  def initialize
    @page = ''
    @data = []
  end


  # assigns an object with login url to a variable
  def get_login_page
    @page = Page.with_login
  end

  # assigns an object with jobs url to a variable
  def get_jobs_page
    @page = Page.with_jobs
  end

  # assigns an object with a specific page url to a variable
  def next_page(page, number)
    @page = Page.next(page, number)
  end

  # fill email and password on login page
  def login
    Login.fill(ENV['EMAIL'], ENV['PASSWORD'])
  end

  # fill email, password and radiobuttons(candidate by default) on signup page
  def signup
    SignUp.fill(ENV['EMAIL'], ENV['PASSWORD'], opt = {candidate: true})
  end

  # return an array with specific attributes
  # and assign to the veriable
  def search_by_element_class(options)
    @page = @page.css(options)
  end

  # delete \n-symbol
  # delete spaces
  # return an array with formatted strings
  def format
    fpage = @page.map{ |el| el.text.gsub("\n", '') }
    ffpage = fpage.map{ |el| el.gsub(/\s/, '') }
  end

  # take an array from
  # 'search_by_element_class(options)' function
  # retrieve data and save to @data
  def seed(object, title, opt = {})
    if opt.empty?
      if @data.empty?
        object.each do |el|
          @data << { title.to_sym => el }
        end
      else
        object.each_with_index do |el, i|
          @data[i][title.to_sym] = el
        end
      end
    elsif opt 
      if @data.empty?
        object.each do |el|
          @data << { title.to_sym => opt.key?(:text) ? el.text.strip : 'https://djinni.co' + el.attributes['href'].value }
        end
      else
        object.each_with_index do |el, i|
          @data[i][title.to_sym] = opt.key?(:text) ? el.text.strip : 'https://djinni.co' + el.attributes['href'].value
        end
      end
    end
  end

  # return int number of all vacancies on a page
  def count_vacancies(page)
    page.css('h1 > small.text-muted').text.to_i
  end

  # return int number of all vacancies
  def total_vacancies_on_page(page)
    page.css('a.profile').count
  end

  # assign to the @page variable an object
  # with page of chosen technology(category)
  def select_category(category)
    @page = Page.to(category)
  end

  # return an array of vacancies
  # each element is a hash
  def get_data
    @data
  end
end
