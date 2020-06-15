Rollbar.configure do |config|
  config.access_token = 'df73edd900bb45fc8a76fea4bf0f6141'

  if Rails.env.test?
    config.enabled = false
  end

  config.environment = ENV['ROLLBAR_ENV'].presence || Rails.env
end
