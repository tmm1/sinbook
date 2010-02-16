begin
  require 'action_controller'
rescue LoadError
  retry if require 'rubygems'
  raise
end

require 'sinbook'

class Sinbook
  module RailsFacebookSettings
    def self.extended(klass)
      klass.cattr_accessor :facebook_settings
      klass.facebook_settings = {}
    end
    def facebook(&blk)
      instance_eval(&blk)
      include Sinbook::Rails
    end
    %w[ api_key secret app_id url callback symbolize_keys ].each do |param|
      class_eval %[
        def #{param} val, &blk
          facebook_settings[:#{param}] = val
        end
      ]
    end
  end

  class RailsFacebookResponse
    def initialize(app)
      @app = app
    end
    def redirect(url)
      @app.redirect_to(url)
    end
    def body(msg)
      @app.render :text => msg
    end
  end

  module Rails
    def self.included(controller)
      if controller.respond_to?(:helper_method)
        controller.helper_method :fb, :facebook
      end
    end
    def facebook
      unless request.env['facebook.helper']
        fb = Sinbook.new(self.class.facebook_settings)
        fb.request = request
        fb.response = RailsFacebookResponse.new(self)
        env['facebook.helper'] = fb
      end

      env['facebook.helper']
    end
    alias fb facebook
  end
end

ActionController::Base.extend Sinbook::RailsFacebookSettings
