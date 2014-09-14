require 'capybara'
require 'capybara/rspec'
require 'capybara-screenshot'
require 'capybara-screenshot/spinach'
require 'spinach/capybara'
require '../../spec/support/test_app'

Spinach.config.failure_exceptions = [ Capybara::ElementNotFound ]

class Spinach::Features::Failure < Spinach::FeatureSteps
  before do
    ::Capybara.app = TestApp
    ::Capybara.save_and_open_page_path = 'tmp'
    ::Capybara::Screenshot.append_timestamp = false
    ::Capybara::Screenshot.register_filename_prefix_formatter(:spinach) do | failed_step |
      raise 'expected failing step' unless failed_step.name.include? @expected_failed_step
      'my_screenshot'
    end
  end

  step 'I visit "/"' do
    visit '/'
  end

  step 'I click on a missing link' do
    @expected_failed_step = 'I click on a missing link'
    click_on "you'll never find me"
  end

  step 'I trigger an unhandled exception' do
    @expected_failed_step = "I trigger an unhandled exception"
    raise "you can't handle me"
  end

  step 'I click on a missing link on a different page in a different session' do
    using_session :different_session do
      visit '/different_page'
      @expected_failed_step = 'I click on a missing link on a different page in a different session'
      click_on "you'll never find me"
    end
  end
end
