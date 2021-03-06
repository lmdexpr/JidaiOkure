#!/bin/ruby

require 'rubygems'

require 'twitter'
require 'tweetstream'

require 'oauth'
require 'oauth/consumer'

require 'json'

require 'optparse'

require 'pp'

def authed_file_path
  './.authed'
end

def input_with_message(str)
  print "#{str} > "
  gets.chomp
end

def auth
  data = {
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

class JidaiNoOkure
  class << self
    def run(str, target)
      debug_print "super origin: #{str}"
      self.parse str, target
    end

    def parse(str, target, fltr = /^RT\s*@\w+:/)
      if str =~ fltr
        nil
      elsif str =~ target
        $+
      end
    end

    def conncect_twitter(data)
      @@client = Twitter::REST::Client.new do |config|
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

      @@stream = TweetStream::Client.new
      @@screen_name = @@client.user.screen_name
      @@my_name = @@client.user.name.gsub(/@/, 'at_')
    end

    def stream
      @@stream
    end

    def log_file
      "log.txt"
    end
  end
end

class UpdateName < JidaiNoOkure
  class << self
    def target
      /^[[:blank:]]*
        (@#{@@screen_name}[[:blank:]\n]+update(_|[[:blank:]])name[[:blank:]\n]+(.+?)|
        (.+?)[[:blank:]\n]*[\(（][[:blank:]\n]*@#{@@screen_name}[[:blank:]\n]*[\)）])
      [[:blank:]\n]*$/x
    end

    def run(str, rep_id, rep_sn)
      debug_print "UpdateName origin: #{str}"
      str = super str, self.target
      debug_print "UpdateName parsed: #{str}"
      return unless str
      @@client.update_profile(:name => str)
      @@my_name = str.slice(0, 20).gsub(/@/, 'at_')
      @@client.update("@#{rep_sn} 「#{@@my_name}」にあっぷでーとねーむっ！",
                      :in_reply_to_status_id => rep_id)
    end
  end
end

class Itiban < JidaiNoOkure
  class << self
    def target
      UpdateName.target
    end

    def run(str, fname = "./itiban.jpg")
      debug_print "Itiban origin: #{str}"
      str = super str, self.target
      debug_print "Itiban parsed: #{str}"
      return unless str == "甘寧一番乗り"
      @@client.update_with_media "#{str}", File.open(fname)
    end
  end
end

class Kireru < JidaiNoOkure
  class << self
    def target
      /^(#{@@my_name}|@?#{@@screen_name})が(何|なに)を(言|い)っ(たところで|ても).*
      (といった|という|っていう|って)(感|かん)じだ$/xu
    end

    def run(str, rep_id, rep_sn)
      debug_print "Kireru origin: #{str}"
      str = super str, self.target
      debug_print "Kireru parsed: #{str}"
      return unless str
      @@client.update("@#{rep_sn} キレそう",:in_reply_to_status_id => rep_id)
    end
  end
end

class JikoSyoukai < JidaiNoOkure
  class << self
    def target
      /^[[:blank:]]*
        @#{@@screen_name}[[:blank:]\n]+((誰|だれ)|(w|W)ho[[:blank:]]*are[[:blank:]]*(u|you))(\?|？)
      [[:blank:]\n]*$/x
    end

    def run(str, rep_id, rep_sn)
      debug_print "JikoSyoukai origin: #{str}"
      str = super str, self.target
      debug_print "JikoSyoukai parsed: #{str}"
      return unless str
      @@client.update("@#{rep_sn} 私は#{@@my_name}",:in_reply_to_status_id => rep_id)
    end
  end
end

def debug_print(str)
  if $is_debug_mode
    puts str
    puts
  end

  File.write JidaiNoOkure.log_file, (File.read JidaiNoOkure.log_file) + str + "\n"
end

# main

File.write JidaiNoOkure.log_file, ""

opt = OptionParser.new
opt.on('-a', '--auth-only', 'running only auth and make .auth file') {|v| auth; exit}
opt.on('-D', '--debug',     'run in debug mode') {|v| $is_debug_mode = v}
opt.on('-d', '--daemonize', 'daemonize(release mode only)') {|v| $is_daemonize = v && (not $is_debug_mode)}
opt.parse!(ARGV)

debug_print "connecting ..."
JidaiNoOkure.conncect_twitter get_data
debug_print "connected"

if $is_daemonize
  Process.daemon true, true
end

debug_print "streaming start"

JidaiNoOkure.stream.userstream(:replies => 'all') do |status|
  tw, id, sn = status.text, status.id, status.user.screen_name
  debug_print "tweet: #{tw}"
  debug_print "id: #{id}"
  debug_print "sn: #{sn}"
  [
    Thread.new {UpdateName.run  tw, id, sn},
    Thread.new {Kireru.run      tw, id, sn},
    Thread.new {JikoSyoukai.run tw, id, sn},
    Thread.new {Itiban.run      tw}
  ].each {|t| t.join}
end
