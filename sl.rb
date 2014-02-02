# -*- coding: utf-8 -*-

# Copryright 2013-2014, pocke
# Licensed MIT
# http://opensource.org/licenses/mit-license.php

# 定数の宣言
SourcePath = File.expand_path('../', __FILE__)
TokenFile = "#{SourcePath}/token.yml"
HistoryFile = "#{SourcePath}/his.yml"
# 見ないでーヽ( >ヮ<)ﾉ
OAuthKey = {
  key: "GjPfDbAGwnJNEBPBA4RKw",
  secret: "WOE2iq464DcYFo3gEyhRPXmh3oBKrhSgPAnusaTQmU"
}
# ^C 対策
Signal.trap(:INT, :IGNORE)

begin
  ENV['BUNDLE_GEMFILE'] = File::join(SourcePath, 'Gemfile')
  require 'bundler/setup'
  Bundler.require
rescue LoadError, SystemExit
  require 'twitter'
  require 'oauth'
end

require 'yaml'
require 'optparse'

def get_oauth(oauth_key)
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

  {
    token: access_token.token,
    secret: access_token.secret
  }
end

unless File::exist?(TokenFile) then
  File.open TokenFile, 'w' do |f|
    f.write get_oauth(OAuthKey).to_yaml
  end
end

unless File::exist?(HistoryFile) then
  h = {
    num: 0,
  }
  File.open HistoryFile, 'w' do |f|
    f.write h.to_yaml
  end
end

OPTS = {}
debug = false
OptionParser.new do |o|
  %w[-a -l -F -c].each do |opt|
    o.on(opt){OPTS[opt.to_sym] = true}
  end
  # optparseのお節介を無効化
  o.on('-h', '--h', '--help'){}
  o.on('-v', '--v', '--version'){}
  o.on('--debug'){debug = true}
  begin
    o.parse!(ARGV)
  rescue OptionParser::InvalidOption
    # 存在しないoptionが指定された場合
    # 握り潰します。
  end
end

sl_command = "sl"
OPTS.each do |key, val|
  sl_command << " #{key}"
end

system(sl_command)

# 以下バックグラウンドで実行
Process.daemon unless debug

hash = YAML::load(File::read(HistoryFile))
now_sec = Time.now.to_i
sec_diff = now_sec - (hash[:old_sec] || now_sec)

hash[:num] += 1
hash[:old_sec] = now_sec

File.open HistoryFile, 'w' do |f|
  f.write hash.to_yaml
end

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

client = Twitter::REST::Client.new do |config|
  token = YAML::load(File.read(TokenFile))

  config.consumer_key = OAuthKey[:key]
  config.consumer_secret = OAuthKey[:secret]
  config.oauth_token = token[:token]
  config.oauth_token_secret = token[:secret]
end

msg = "slコマンドが走りました(#{time_diff}#{unit}振り#{hash[:num]}回目)"
msg = "@null #{msg}" if debug
client.update(msg)
