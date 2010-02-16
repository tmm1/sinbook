require 'rubygems'
require 'sinatra/facebook'
require 'sinatra'

facebook do
  api_key  '45796747415d12227f52146b4444cbb0'
  secret   '5106c7409f18d7618dd03433a2f72342'
  app_id   81747826609
  url      'http://apps.facebook.com/sinatrafacebook'
  callback 'http://tmm1.net:4567'
end

get '/' do
  if not facebook.valid?
    # not accessed via facebook, redirect to the facebook app url
    redirect fb.url

  elsif fb[:logged_out_facebook]
    # user is not logged into facebook
    "Hey there! This is an awesome facebook app, but you must login to facebook to see it."

  elsif not fb[:added]
    # user is logged into facebook, but not our app

    if not fb[:canvas_user]
      # user navigated to the app directly, we know nothing about them
      "
      Hey there, you should add this <b>awesome</b> app! <br>
      Go <a href='#{fb.addurl}'>here</a> or just click <a href='#' requirelogin=true>here</a>! <br>
      Or, if you don't want to add the app, click <a href='#{fb.url('/')}'>here</a> so I know who you are.
      "

    else
      # user came via a feed/notification or clicked on a link in the app, so we know who they are
      "
      Hey <fb:name uid=#{fb[:canvas_user]} useyou=false />. <br>
      All I know about you is that you have #{fb[:friends].size} friends. <br>
      Maybe you'll <a href='#{fb.addurl}'>add this app</a> so I can tell you more?
      "
    end

  elsif fb[:user]
    # logged into facebook and our app, we can get all their info
    "
    Hey <fb:name uid=#{fb[:user]} useyou=false />! <br>
    Check out the special <a href='#{fb.url('/members')}'>members-only area</a>. <br>
    And don't forget to tell your #{fb[:friends].size} friends to add this app too!
    "
  end
end

get '/members' do
  fb.require_login!

  groups = fb.groups.get :uid => fb[:user]
  "
  Hey there, now that you're a member I can tell what groups you're in on Facebook: <br>
  #{groups.map{|g| g['name'] }.join('<br>')}
  "
end
