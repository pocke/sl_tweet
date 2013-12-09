# -*- coding: utf-8 -*-

require 'twitter'
require 'yaml'
require 'date'

source_path = File.expand_path('../', __FILE__)

token = YAML::load(File.read("#{source_path}/token.yml"))

Twitter.configure do |config|
  config.consumer_key = "GjPfDbAGwnJNEBPBA4RKw"
  config.consumer_secret = "WOE2iq464DcYFo3gEyhRPXmh3oBKrhSgPAnusaTQmU"
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
