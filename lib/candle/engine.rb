require "slim-rails"
require "jquery-rails"
require "turbolinks"
require "material_icons"
require "bootstrap-sass"
require "rails_autolink"

module Candl
  class Engine < ::Rails::Engine
    isolate_namespace Candl
    initializer 'candl.assets' do |app|
      %w(stylesheets javascripts).each do |sub|
        app.config.assets.paths << root.join('app', 'assets', sub).to_s
      end
    end
  end
end
