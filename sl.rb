# -*- coding: utf-8 -*-

# Copryright 2013, pocket
# Licensed MIT
# http://opensource.org/licenses/mit-license.php

require 'twitter'
require 'yaml'
require 'oauth'
require 'optparse'

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
HistoryFile = "#{SourcePath}/his.yml"
# 見ないでーヽ( >ヮ<)ﾉ
OAuthKey = {
  key: "GjPfDbAGwnJNEBPBA4RKw",
  secret: "WOE2iq464DcYFo3gEyhRPXmh3oBKrhSgPAnusaTQmU"
}

if !File::exist?(TokenFile) then
  get_oauth(OAuthKey, TokenFile)
end

if !File::exist?(HistoryFile) then
  h = {
    num: 0,
  }
  File.open HistoryFile, 'w' do |f|
    f.write h.to_yaml
  end
end

token = YAML::load(File.read(TokenFile))

Twitter.configure do |config|
  config.consumer_key = OAuthKey[:key]
  config.consumer_secret = OAuthKey[:secret]
  config.oauth_token = token[:token]
  config.oauth_token_secret = token[:secret]
end

# ^C 対策
Signal.trap(:INT, :IGNORE)

sl_command = "sl"
begin
  OptionParser.new do |o|
    o.on('-a'){|v| sl_command << ' -a'}
    o.on('-l'){|v| sl_command << ' -l'}
    o.on('-F'){|v| sl_command << ' -F'}
    o.on('-c'){|v| sl_command << ' -c'}
    # optparseのお節介を無効化
    o.on('-h', '--h', '--help'){}
    o.on('-v', '--v', '--version'){}

    o.parse!(ARGV)
  end
rescue OptionParser::InvalidOption
  # 存在しないoptionが指定された場合
  # 握り潰します。
end

system(sl_command)

Process.daemon

hash = YAML::load File.read HistoryFile
now_sec = Time.now.to_i
sec_diff = now_sec - (hash[:old_sec] || now_sec)

hash[:num] += 1
hash[:old_sec] = now_sec

time_diff, unit = case sec_diff
  when 0...60 then
    [sec_diff, '秒']
  when 60...3600 then
    [sec_diff / 60, '分']
  when 3600...86400 then
    [sec_diff / 3600, '時間']
  else
    [sec_diff / 86400, '日']
  end

Twitter.update("slコマンドが走りました(#{time_diff}#{unit}振り#{hash[:num]}回目)")

File.open HistoryFile, 'w' do |f|
  f.write hash.to_yaml
end
