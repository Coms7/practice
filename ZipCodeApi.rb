require "bundler/setup"

require 'mysql2'
require 'sinatra'
require 'json'

#本来秘匿情報なのでどこかに分けて記述したい
client = Mysql2::Client.new(host: "localhost", username: "root", password: '', database: 'ruby_tutorial')

# #全件取得
 get '/show' do
   @results = client.query('SELECT id, zip_code, prefecture, city, town_area FROM zip_codes;')
   erb :index
 end 

# レコード新規登録
post '/insert' do
  zip_codes = params[:zip_codes]
  statement = client.prepare('INSERT INTO zip_codes(zip_code, prefecture, city, town_area, created_at, updated_at)
                                VALUES (?, ?, ?, ?, current_time, current_time);')
  result = statement.execute(zip_codes["zip_code"], zip_codes["prefecture"], zip_codes["city"], zip_codes["town_area"])
  redirect 'views/index.erb'
end







