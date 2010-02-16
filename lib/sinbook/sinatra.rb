begin
  require 'sinatra/base'
rescue LoadError
  retry if require 'rubygems'
  raise
end

require 'sinbook'

module Sinatra
  class FacebookResponse
    def initialize(app)
      @app = app
    end
    def redirect(url)
      @app.redirect(url)
    end
    def response(body)
      @app.body(body)
      throw :halt
    end
  end

  module FacebookHelper
    def facebook
      unless env.has_key?('facebook.helper')
        sinbook = Sinbook.new(
          :api_key => options.facebook_api_key,
          :secret => options.facebook_secret,
          :app_id => options.facebook_app_id,
          :url => options.facebook_url,
          :callback => options.facebook_callback,
          :symbolize_keys => options.facebook_symbolize_keys
        )
        sinbook.request = request
        sinbook.response = FacebookResponse.new(self)
        env['facebook.helper'] = sinbook
      end

      env['facebook.helper']
    end
    alias fb facebook
  end

  class FacebookSettings
    def initialize app, &blk
      @app = app
      @app.set :facebook_symbolize_keys, false
      instance_eval &blk
    end
    %w[ api_key secret app_id url callback symbolize_keys ].each do |param|
      class_eval %[
        def #{param} val, &blk
          @app.set :facebook_#{param}, val
        end
      ]
    end
  end

  module Facebook
    def facebook &blk
      FacebookSettings.new(self, &blk)
    end

    FixRequestMethod = proc{
      if method = request.params['fb_sig_request_method']
        request.env['REQUEST_METHOD'] = method
      end
    }

    def self.registered app
      app.helpers FacebookHelper
      app.before(&FixRequestMethod)
    end
  end

  Application.register Facebook
end
