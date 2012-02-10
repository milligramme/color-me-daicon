# -*- coding: utf-8 -*-

configure :development do
  enable :sessions, :logging
  config = YAML::load_file("config.yml")
  use OmniAuth::Builder do
    provider :twitter, config['twitter']['consumer_token'], config['twitter']['consumer_secret']
  end
end

configure :production do
  enable :sessions, :logging
  use OmniAuth::Builder do
    provider :twitter, ENV['CONSUMER_TOKEN'],ENV['CONSUMER_SECRET']
  end
end

helpers do
  def convert_hex(str)
    an = []
    str.split(//).each do |s|
      an << format("%x",s.unpack("U*")[0])
    end
    if an.join("").scan(/.../).size == 0
      rgb = ["000"]
    else
      rgb = an.join("").scan(/.../)
    end
    rgb
  end
  
  def login
  end
  
  def logout
  end
end


get '/auth/:name/callback' do
  @auth = request.env['omniauth.auth']
  haml :index2
  # before do
  # 
  #   twitter_oauth = Twitter::OAuth.new(CONSUMER_TOKEN, CONSUMER_SECRET)
  #   twitter_oauth.authorize_from_access(ACCESS_TOKEN, ACCESS_SECRET)
  # 
  #   @twitter = Twitter::Base.new(twitter_oauth)
  #   @twitter.friends_timeline.each {|tweet| puts tweet.inspect }
  #   @twitter.user_timeline.each {|tweet| puts tweet.inspect }
  #   @twitter.replies.each {|tweet| puts tweet.inspect }
  #   # @twitter.update("OAuth で認証して tweet するテスト")
  #   profile = @twitter.verify_credentials
  #   puts profile.id
  #   puts profile.screen_name
  #   puts profile.name
  # end
end


# sass
get '/style.css' do
  sass :style
end

# home public timeline
get '/' do
  @pt = Twitter.public_timeline
  # print @pt
  haml :index
end

get '/meet' do
  "Hello #{params[:name]}"
end

get '/rgb/:str' do
  convert_hex("#{params[:str]}")
end

# user timeline
get '/tweets/:user' do
  # 例外処理する
  # Twitter::Unauthorized
  # Twitter::NotFound
  begin
    @pt = Twitter.user_timeline("#{params[:user]}")
    haml :index
  rescue Twitter::Unauthorized, Twitter::NotFound
    "Unauthorized or NotFound"
    # redirect "/"
  end
end

post '/tweets' do
  user = params[:user_name]
  redirect "/tweets/#{user}"
end
