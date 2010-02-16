begin
  require 'action_controller'
rescue LoadError
  retry if require 'rubygems'
  raise
end

require 'sinbook'

class Sinbook
  class RailsFacebookResponse
    def initialize(app)
      @app = app
    end
    def redirect(url)
      @app.redirect(url)
    end
    def response(body)
      @app.render :text => body
    end
  end

  module RailsFacebookSettings
    def self.included(klass)
      klass.const_set :FacebookSettings, {}
    end
    def facebook(&blk)
      instance_eval(&blk)
    end
    %w[ api_key secret app_id url callback symbolize_keys ].each do |param|
      class_eval %[
        def #{param} val, &blk
          FacebookSettings[:#{param}] = val
        end
      ]
    end
  end

  module Rails
    def self.included(controller)
      if controller.respond_to?(:helper_method)
        controller.helper_method :fb, :facebook
        controller.extend(RailsFacebookSettings)
      end
    end
    def facebook
      unless request.env['facebook.helper']
        fb = Sinbook.new(self.class::FacebookOptions)
        fb.request = request
        fb.response = FacebookResponse.new(self)
        env['facebook.helper'] = fb
      end

      env['facebook.helper']
    end
    alias fb facebook
  end
end
