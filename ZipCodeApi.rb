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
  results = statement.execute(zip_codes["zip_code"], zip_codes["prefecture"], zip_codes["city"], zip_codes["town_area"])
  if(results == nil)
    'status:400' 
  end
    'status:201 created'
end

post '/search' do
  ID = params[:ID]
  statement = client.prepare('SELECT * FROM zip_codes WHERE id = ?;')
  @results = statement.execute(ID)
  if(@results == nil)
    'status:400 not found'
  else
    @results
    erb :index
  end
end

put '/update' do
  zip_codes = params[:zip_codes]
  statement = client.prepare('UPDATE FROM zip_codes WHERE id = ?;' )
  results = statement.execute(zip_codes["zip_code"], zip_codes["prefecture"], zip_codes["city"], zip_codes["town_area"])
  



post '/delete' do
  ID = params[:ID]
  statement = client.prepare('DELETE FROM zip_codes WHERE id = ?;' )
  @result = statement.execute(ID)
  if(@result == nil)
    'status:400 not found'
  end
  'status:200 success'
end



  







