require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Medlive
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.i18n.available_locales = [:en, :nl]

    config.autoload_paths += %W(#{config.root}/lib)

    config.active_record.observers = [
      :consultation_request_observer,
      :consultation_observer,
      :message_observer,
      :favorite_doctor_observer
    ]

    config.action_mailer.default_url_options = {
      host: ENV['APP_HOST']
    }

    config.assets.initialize_on_precompile = true

    config.handlebars.output_type = :amd
    config.handlebars.amd_namespace = 'app'

    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.view_specs false
      g.helper_specs false
      g.controller_specs false
      g.helper = false
    end

    console do
      require 'pry'
      config.console = Pry
    end
  end
end
