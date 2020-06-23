require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module TaskManager
  class Application < Rails::Application
    config.active_job.queue_adapter = :sidekiq
    config.load_defaults 6.0
    config.assets.paths << Rails.root.join('node_modules')
  end
end
