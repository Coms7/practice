require "bundler/setup"

require 'mysql2'
require 'sinatra'
require 'json'

#本来秘匿情報なのでどこかに分けて記述したい
client = Mysql2::Client.new(host: "localhost", username: "root", password: '', database: 'ruby_tutorial')

# #全件取得
 get '/show' do
   @results = client.query('SELECT zip_code, prefecture, city, town_area FROM zip_codes ORDER BY id DESC;')
   erb :index
 end


# レコード新規登録
 post '/insert' do
  @params = {}
    statement = client.prepare('INSERT INTO zip_codes(
                                zip_code, 
                                prefecture, 
                                city, 
                                town_area,)
                                VALUES (?, ?, ?, ?, current_time, current_time);')
    result = statment.execute()
  
  end







