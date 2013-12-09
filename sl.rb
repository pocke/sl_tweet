# -*- coding: utf-8 -*-

require 'twitter'
require 'yaml'
require 'date'
require 'oauth'

def get_oauth(oauth_key, token_file)
  oauth = OAuth::Consumer.new(
    oauth_key[:key],
    oauth_key[:secret],
    site: "https://api.twitter.com"
  )

  request_token = oauth.get_request_token

  puts "Please, access this URL: #{request_token.authorize_url}"
  puts "and get the PIN code."

  print "Enter your PIN code: "
  pin = gets.to_i

  access_token = request_token.get_access_token(
    oauth_verifier: pin
  )

  result = {
    token: access_token.token,
    secret: access_token.secret
  }

  File.open token_file, 'w' do |f|
    f.write result.to_yaml
  end
end

# 定数の宣言
SourcePath = File.expand_path('../', __FILE__)
TokenFile = "#{SourcePath}/token.yml"
# 見ないでーヽ( >ヮ<)ﾉ
OAuthKey = {
  key: "GjPfDbAGwnJNEBPBA4RKw",
  secret: "WOE2iq464DcYFo3gEyhRPXmh3oBKrhSgPAnusaTQmU"
}

if !File::exist?(TokenFile) then
  get_oauth(OAuthKey, TokenFile)
end

token = YAML::load(File.read(TokenFile))

Twitter.configure do |config|
  config.consumer_key = OAuthKey[:key]
  config.consumer_secret = OAuthKey[:secret]
  config.oauth_token = token[:token]
  config.oauth_token_secret = token[:secret]
end

# ^C 対策
Signal.trap(:INT){}

sl_command = "sl"
ARGV.each{|argv|
  sl_command << " #{argv}"
}

system(sl_command)

Process.daemon

home = ENV["HOME"]
filename = "#{home}/.sl/sl.yml"
hash = YAML::load File.read filename
now_sec = DateTime.now.to_time.to_i
sec_def = now_sec - hash["old_sec"]

if sec_def < 60 then
  time_def = sec_def
  unit = "秒"
elsif sec_def < 3600 then
  time_def = sec_def / 60
  unit = "分"
elsif sec_def < 86400 then
  time_def = sec_def / 3600
  unit = "時間"
else
  time_def = sec_def / 86400
  unit = "日"
end

Twitter.update("slコマンドが走りました(#{time_def}#{unit}振り#{hash["num"]}回目)")

hash["num"] += 1
hash["old_sec"] = now_sec

File.open filename, 'w' do |f|
  f.write hash.to_yaml
end
