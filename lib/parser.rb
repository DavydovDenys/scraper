require 'mechanize'
require 'byebug'

module Parser
  # manage agents
  class Agent
    # create mechanize object
    def self.new
      Mechanize.new
    end
  end

  # generate parsing pages
  class Page
    # return login page
    def self.with_login
      Agent.new.get(Link.to_login)
    end

    # return signup page
    def self.with_signup
      Agent.new.get(Link.to_signup)
    end

    # return page with jobs
    def self.with_jobs
      Agent.new.get(Link.to_jobs)
    end

    # go to the chosen page
    # page-mechanize object, number-integer
    def self.next(page, number)
      Agent.new.get(Link.to_next_page(page, number))
    end

    # go to the chosen technology
    def self.to(keyword)
      Agent.new.get(Link.to(keyword))
    end
  end

  # manage login data
  class Login
    # fill in and submit login data
    def self.fill(email, password)
      Form.get_all
      Form.use
      Form.fill(email, password, opt ={})
      Form.submit
    end
  end

  # manage signup data
  class SignUp
    # fill in signup data with radiobuttons
    # email-string, password-string, opt for radiobuttons
    def self.fill(email, password, opt = {})
      Form.get_all
      Form.use
      if opt.key?(:candidate)
        Form.fill(email, password, opt = {candidate: true})
      elsif opt.key?(:recruiter)
        Form.fill(email, password, opt = {recruiter: true})
      end
    end
  end

  # generate links
  class Link
    # return login link
    def self.to_login
      login_link
    end

    # return signup link
    def self.to_signup
      signup_link
    end

    # return link with jobs
    def self.to_jobs
      jobs_link
    end

    # go to the chosen page
    def self.to_next_page(page, number)
      url = page.uri.to_s
      if url.include?('keywords')
        url = page.uri.to_s + "&page=#{number}"
      else
        url = page.uri.to_s + "?page=#{number}"
      end
      url
    end

    # link to chosen technology
    # keyword-string
    def self.to(keyword)
      keyword_link(keyword)
    end

    private

    def self.login_link
      'https://djinni.co/login?from=frontpage_main'
    end

    def self.signup_link
      'https://djinni.co/signup?from=frontpage_main'
    end

    def self.jobs_link
      'https://djinni.co/jobs/'
    end

    def self.keyword_link(keyword)
      "https://djinni.co/jobs/?keywords=#{keyword}"
    end
  end

  # manage forms
  class Form
    # return all forms in a page
    def self.get_all
      Page.with_login.forms
    end

    # select needed form
    def self.use
      get_all.first
    end

    # fill form with user credentials and/or radiobuttons
    def self.fill(email, password, opt = {})
      if opt.empty?
        Credential.email(email)
        Credential.password(password)
      elsif opt.key?(:candidate)
        Credential.email(email)
        Credential.password(password)
        Radiobutton.candidate
      elsif opt.key?(:recruiter)
        Credential.email(email)
        Credential.password(password)
        Radiobutton.recruiter
      end
    end

    # submit the form
    def self.submit
      use.submit
    end
  end

  # manage form fields
  class Field
    # return all form fields
    def self.get_all
      Form.use.fields
    end
  end

  # manage radiobuttons
  class Radiobutton
    # return all form's radiobuttons
    def self.get_all
      Form.use.radiobuttons
    end

    # check candidate radiobutton
    def self.candidate
      Form.use.all.radiobutton_with(value: 'candidate').check
    end

    # check recruiter radiobutton
    def self.recruiter
      get.all.radiobutton_with(value: 'recruiter').check
    end

  end

  # manage user credentials
  class Credential
    # fill in email field
    def self.email(email)
      Field.get_all[0].value = email
    end

    # fill in password field
    def self.password(password)
      Field.get_all[1].value = password
    end
  end
end
