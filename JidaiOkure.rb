#!/bin/ruby
# -*- coding: utf-8 -*-

require 'rubygems'

require 'twitter'
require 'tweetstream'

require 'oauth'
require 'oauth/consumer'

require 'json'

require 'optparse'

def authed_file_path
  './.authed'
end

def input_with_message(str)
  print "#{str} > "
  gets.chomp
end

def auth
  data ={
    "con_key"    => "rdbKRAFhKZQflJ4p6TEwOnGr3" ,
    "con_secret" => "dSVf2Urw9sDsCMnPliCowddvDYFRQtNcQQdvW5vVX56h73u49T"
  }
  # どうなっても僕はしらない

  consumer = OAuth::Consumer.new(data["con_key"], data["con_secret"], site: 'https://api.twitter.com')

  request_token = consumer.get_request_token
  puts "Please access: #{request_token.authorize_url}"

  pin = input_with_message("PIN")

  access_token = request_token.get_access_token(oauth_verifier: pin)
  data["acc_token"]  = access_token.token
  data["acc_secret"] = access_token.secret

  File.write authed_file_path, JSON.dump(data)
  puts "done."
  data
end

def authed?
  File.exist?(authed_file_path)
end

def get_data
  if authed?
    JSON.parse File.read authed_file_path
  else
    auth
  end
end

def conncect_twitter(data)
  @client = Twitter::REST::Client.new do |config|
    config.consumer_key        = data["con_key"]
    config.consumer_secret     = data["con_secret"]
    config.access_token        = data["acc_token"]
    config.access_token_secret = data["acc_secret"]
  end

  TweetStream.configure do |config|
    config.consumer_key       = data["con_key"]
    config.consumer_secret    = data["con_secret"]
    config.oauth_token        = data["acc_token"]
    config.oauth_token_secret = data["acc_secret"]
    config.auth_method        = :oauth
  end

  @stream = TweetStream::Client.new
  @screen_name = @client.user.screen_name
end

def update_name(rep_id, rep_sn, str)
  if str
    @client.update_profile(:name => str)
    @client.update("@#{rep_sn} 「#{str.slice(0, 20).gsub(/@/, 'at_')}」にあっぷでーとねーむっ！",
                   :in_reply_to_status_id => rep_id)
    itiban str
  end
end

def itiban(str)
  if str =~ /^甘寧一番乗り$/
    @client.update_with_media "itiban nori!", File.open("./itiban.jpg")
  end
end

def parse(str)
  if str =~ /^RT\s*@\w+:/
    nil
  elsif str =~ /^@#{@screen_name}[[:blank:]]+update_name[[:blank:]]+/
    $'
  elsif str =~ /[[:blank:]]*[\(（][[:blank:]]*@#{@screen_name}[[:blank:]]*[\)）]$/
    $`
  end
end

def streaming_start
  @stream.userstream(:replies => 'all') do |status|
    if $is_debug_mode
      puts status.text
      p parse(status.text)
      puts
    end
    update_name status.id, status.user.screen_name, parse(status.text)
  end
end

def main
  conncect_twitter get_data
  if $is_daemonize && (not $is_debug_mode) then Process.daemon(true, true) end
  streaming_start
end

opt = OptionParser.new
opt.on('-a', '--auth-only',  'running only auth and make .auth file'){|v| auth; exit}
opt.on('-d', '--daemonize',  'daemonize(release mode only)'){|v| $is_daemonize = v}
opt.on('-D', '--debug-mode', 'run in debug mode'){|v| $is_debug_mode = v}

opt.parse!(ARGV)
main
