require_relative '../my_parser'
require_relative '../lib/parser'

RSpec.describe MyParser do
  let(:my_parser) { MyParser.new }
  
  describe '.new' do
    context 'create instance' do
      it 'returns the object' do
        expect(my_parser).to be_instance_of(MyParser)
      end
    end
  end

  describe '#get_login_page' do
    context 'go to the login page' do
      it 'returns the login page object' do
        my_parser.get_login_page
        expect(my_parser.page.uri.to_s).eql?('https://djinni.co/login?from=frontpage_main')
      end
    end
  end

  describe '#get_jobs_page' do
    context 'go to the jobs page' do
      it 'returns the jobs page object' do
        my_parser.get_jobs_page
        expect(my_parser.page.uri.to_s).to eql('https://djinni.co/jobs/')
      end
    end
  end

  describe '#get_next_page' do
    context 'go to the specific page' do
      it 'returns the object with specific page' do
        my_parser.get_jobs_page
        my_parser.next_page(my_parser.page, 2)
        expect(my_parser.page.uri.to_s).to eql('https://djinni.co/jobs/?page=2')
      end
    end
  end

  describe '#search_by_element_class' do
    context 'get all data from the page with specific attributes' do
      it 'returns all data from the page with tag <a class=profile>' do
        my_parser.get_jobs_page
        my_parser.search_by_element_class('a.profile')
        expect(my_parser.page[0].name).to eql('a')
        expect(my_parser.page[0].attributes.values[0].value).to eql('profile')
      end
    end
  end

  describe '#format' do
    context 'get formatted string' do
      it 'returns new string without spaces and new line symbols' do
        my_parser.get_jobs_page
        details = my_parser.search_by_element_class('div.list-jobs__details')
        expect(details[0].text.include?("\n")).to eql(true)
        expect(details[0].text.include?(" ")).to eql(true)
        details = my_parser.format
        expect(details[0].include?("\n")).to eql(false)
        expect(details[0].include?(" ")).to eql(false)
      end
    end
  end

  describe '#seed' do
    context 'save data' do
      it 'retrieves data and saves to @data variable' do
        my_parser.get_jobs_page
        my_parser.search_by_element_class('div.list-jobs__details')
        details = my_parser.format
        my_parser.seed(details, 'details', opt = {})
        expect(my_parser.data[0].key?(:details)).to eql(true)
      end
    end
  end

  describe '#count_vacancies' do
    context 'count all vacancies' do
      it 'returns integer of all vacancies' do
        my_parser.get_jobs_page
        expect(my_parser.count_vacancies(my_parser.page).is_a? Integer).to eql(true)
      end
    end
  end

  describe '#total_vacancies_on_page' do
    context 'count all vacancies on page' do
      it 'returns integer of vacancies on page' do
        my_parser.get_jobs_page
        expect(my_parser.total_vacancies_on_page(my_parser.page).is_a? Integer).to eql(true)
      end
    end
  end

  describe '#select_category' do
    context 'search all vacancies of chosen technology' do
      it 'returns url with ruby' do
        my_parser.get_jobs_page
        my_parser.select_category('Ruby')
        expect(my_parser.page.uri.to_s.match?('Ruby')).to eql(true)
      end
    end
  end

  describe '#get_data' do
    context 'return all data stored in @data variable' do
      it 'returns the array with hash as an element' do
        my_parser.get_jobs_page
        titles = my_parser.search_by_element_class('a.profile')
        my_parser.seed(titles, 'title', opt = {text: true})
        expect(my_parser.get_data.is_a? Array).to eql(true)
        expect(my_parser.get_data[0].is_a? Hash).to eql(true)
      end
    end
  end
end