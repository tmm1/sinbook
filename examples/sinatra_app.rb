require 'sinatra/base'
require 'sinatra/facebook'

class MyApp < Sinatra::Base
  register Sinatra::Facebook
  facebook do
    api_key  '45796747415d12227f52146b4444cbb0'
    secret   '5106c7409f18d7618dd03433a2f72342'
    app_id   81747826609
    url      'http://apps.facebook.com/sinatrafacebook'
    callback 'http://tmm1.net:4567'
  end

  get '/' do
    fb.require_login!
    "Hi, <fb:name uid=#{fb[:user]} useyou=false />!"
  end
end

MyApp.run!
