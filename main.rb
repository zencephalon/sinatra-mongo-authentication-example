require 'rubygems'
require 'bundler/setup'

require 'bcrypt'
require 'haml'
require 'sinatra'
require 'mongo'
 
enable :sessions
 
userTable = {}
 
helpers do
  
  def login?
    if session[:username].nil?
      return false
    else
      return true
    end
  end
  
  def username
    return session[:username]
  end
  
end
 
get "/" do
  haml :index
end
 
get "/signup" do
  haml :signup
end
 
post "/signup" do
  password_salt = BCrypt::Engine.generate_salt
  password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)
  
  #ideally this would be saved into a database, hash used just for sample
  userTable[params[:username]] = {
    :salt => password_salt,
    :passwordhash => password_hash 
  }
  
  session[:username] = params[:username]
  redirect "/"
end
 
post "/login" do
  if userTable.has_key?(params[:username])
    user = userTable[params[:username]]
    if user[:passwordhash] == BCrypt::Engine.hash_secret(params[:password], user[:salt])
      session[:username] = params[:username]
      redirect "/"
    end
  end
  haml :error
end
 
get "/logout" do
  session[:username] = nil
  redirect "/"
end
 
__END__
@@layout
!!! 5
%html
  %head
    %title Sinatra Authentication
  %body
  =yield
@@index
-if login?
  %h1= "Welcome #{username}!"
  %a{:href => "/logout"} Logout
-else
  %form(action="/login" method="post")
    %div
      %label(for="username")Username:
      %input#username(type="text" name="username")
    %div
      %label(for="password")Password:
      %input#password(type="password" name="password")
    %div
      %input(type="submit" value="Login")
      %input(type="reset" value="Clear")
  %p
    %a{:href => "/signup"} Signup
@@signup
%p Enter the username and password!
%form(action="/signup" method="post")
  %div
    %label(for="username")Username:
    %input#username(type="text" name="username")
  %div
    %label(for="password")Password:
    %input#password(type="password" name="password")
  %div
    %label(for="checkpassword")Password:
    %input#password(type="password" name="checkpassword")
  %div
    %input(type="submit" value="Sign Up")
    %input(type="reset" value="Clear")
@@error
%p Wrong username or password
%p Please try again!
