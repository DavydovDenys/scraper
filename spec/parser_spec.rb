require_relative '../lib/parser'
require 'spec_helper'

RSpec.describe Parser do
  describe 'Agent' do
    describe '.new' do
      it 'returns Mechanize object' do
        expect(Parser::Agent.new).to be_instance_of(Mechanize)
      end
    end
  end

  describe 'Page' do
    describe '.with_login' do
      it 'returns login page' do
        expect(Parser::Page.with_login.uri.to_s).to eql('https://djinni.co/login?from=frontpage_main')
      end
    end

    describe '.with_signup' do
      it 'returns signup page' do
        expect(Parser::Page.with_signup.uri.to_s).to eql('https://djinni.co/signup?from=frontpage_main')
      end
    end

    describe '.with_jobs' do
      it 'returns page with jobs' do
        expect(Parser::Page.with_jobs.uri.to_s).to eql('https://djinni.co/jobs/')
      end
    end

    describe '.next' do
      it 'returns specific page' do
        page = Parser::Page.with_jobs
        number = 1
        expect(Parser::Page.next(page, number).uri.to_s).to eql("https://djinni.co/jobs/?page=#{number}")
      end
    end

    describe '.to' do
      it 'returns page with chosen technology' do
        page = Parser::Page.with_jobs
        keyword = 'Ruby'
        expect(Parser::Page.to(keyword).uri.to_s).to eql("https://djinni.co/jobs/?keywords=#{keyword}")
      end
    end
  end

  describe 'Link' do
    describe '.to_login' do
      it 'returns login link' do
        expect(Parser::Link.to_login).to eql('https://djinni.co/login?from=frontpage_main')
      end
    end

    describe '.to_signup' do
      it 'returns signup link' do
        expect(Parser::Link.to_signup).to eql('https://djinni.co/signup?from=frontpage_main')
      end
    end

    describe '.to_jobs' do
      it 'returns link to jobs' do
        expect(Parser::Link.to_jobs).to eql('https://djinni.co/jobs/')
      end
    end

    describe '.to_next_page' do
      it 'returns link to specific page' do
        page = Parser::Page.with_jobs
        number = 1
        expect(Parser::Link.to_next_page(page, number)).to eql(page.uri.to_s + "?page=#{number}")
      end
    end

    describe '.to' do
      it 'returns link to specific technology' do
        page = Parser::Page.with_jobs
        keyword = 'Ruby'
        expect(Parser::Link.to(keyword)).to eql( "https://djinni.co/jobs/?keywords=#{keyword}")
      end
    end
  end

  describe 'Form' do
    describe '.get_all' do
      it 'returns all forms on the page' do
        expect(Parser::Form.get_all).to be_instance_of(Array)
      end
    end

    describe '.use' do
      it 'returns form to fill' do
        expect(Parser::Form.use).to be_instance_of(Mechanize::Form)
      end
    end

    describe '.fill' do
      it 'fills the form' do
        password = Parser::Form.fill('test@email', 'password', opt = {})
        expect(password).to eql('password')
      end
    end
  end
end