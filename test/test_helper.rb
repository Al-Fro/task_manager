require 'simplecov'
require 'coveralls'
require 'sidekiq/testing'

SimpleCov.start
Coveralls.wear!

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include FactoryBot::Syntax::Methods
  include AuthHelper
  parallelize(workers: :number_of_processors)

  fixtures :all
end
