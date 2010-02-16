require 'rubygems'
require 'sinatra/facebook'
require 'sinatra'

facebook do
  api_key  '858593842e5a3cefe59b72ddc7ffdd56'
  secret   '56ce1b26bf48ac8bac927c7d280b18f8'
  app_id   185945096655
  url      'http://tmm1.net:4568/'
  callback 'http://tmm1.net:4568/'
end

set :port, 4568

get '/' do
  haml :main
end

get '/receiver' do
  %[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
  <html xmlns="http://www.w3.org/1999/xhtml" >
  <body>
      <script src="http://static.ak.connect.facebook.com/js/api_lib/v0.4/XdCommReceiver.js" type="text/javascript"></script>
  </body>
  </html>]
end

__END__

@@ layout
%html{:xmlns=>"http://www.w3.org/1999/xhtml", :'xmlns:fb'=>"http://www.facebook.com/2008/fbml"}
  %head
    %title Welcome to my Facebook Connect website!
    %script{:type => 'text/javascript', :src => 'http://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php/en_US'}
  %body
    = yield
    :javascript
      FB.init("#{fb.api_key}", "/receiver")

@@ main
- if fb[:user]
  Hi,
  %fb:profile-pic{:uid => fb[:user]}
  %fb:name{:uid => fb[:user], :useyou => 'false', :firstnameonly => 'true'}
  !
  %br/
  Do you want to <a href="javascript:FB.Connect.logoutAndRedirect('/')">logout</a>?
- else
  Please login:
  %fb:login-button{:onlogin => 'document.location.reload(true)'}
