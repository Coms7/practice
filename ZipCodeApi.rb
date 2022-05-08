require "bundler/setup"

require 'mysql2'
require 'sinatra'
require 'uri'
require 'net/http'
require "json/add/core"





#本来秘匿情報なのでどこかに分けて記述したい
client = Mysql2::Client.new(host: "localhost", username: "root", password: '', database: 'ruby_tutorial')

# 全件取得
 get '/zip_codes' do
   @results = client.query('SELECT id, zip_code, prefecture, city, town_area FROM zip_codes;')
   @results.to_json
  end
 

#  get '/show' do
#   comments = Comment.all

#   output = ""
#   comments.each do |comment|
#     output << "#{comment.body} <br />"
#   end

#   return output
# end

# レコード新規登録
post '/zip_codes' do
  result_hash = Struct.new(:status, :status_code )
  zip_codes = params[:zip_codes]
  statement = client.prepare('INSERT INTO zip_codes(zip_code, prefecture, city, town_area, created_at, updated_at)
                                VALUES (?, ?, ?, ?, current_time, current_time);')
  @results = statement.execute(zip_codes["zip_code"], zip_codes["prefecture"], zip_codes["city"], zip_codes["town_area"])
  if(@results.size == 0)
    result_hash.new("bad request", 400)
    result_hash.to_json
  end
    result_hash.new("created", 200)
    result_hash.to_json
end

get '/zip_codes/:id' do
  result_hash = Struct.new(:status, :status_code )

  statement = client.prepare('SELECT * FROM zip_codes WHERE id = ?;')
  @results = statement.execute(params['id'])
  if(@results.size == 0)
    result_hash.new("not found", 400)
    result_hash.to_json
  else
    @results.to_json
  end
end

put '/zip_codes/:id' do
  result_hash = Struct.new(:status, :status_code )
   statement = client.prepare('SELECT * FROM zip_codes WHERE id = ? ;' )
   results = statement.execute(params['id'])
   #存在チェック
    if(results.size == 0)
     result_hash.new("not found",400)
     result_hash.to_json
    else
    #登録処理
   statement = client.prepare('UPDATE zip_codes SET zip_code = ?, prefecture = ?, city = ?, town_area = ? WHERE id = ?;')
   results = statement.execute(zip_codes["zip_code"], zip_codes["prefecture"], zip_codes["city"], zip_codes["town_area"], zip_codes["id"])
   @results = client.query('SELECT id, zip_code, prefecture, city, town_area FROM zip_codes;')
   erb :index
   end
 end

post '/throw_api/:zip_code' do
  result_hash = Struct.new(:status, :status_code )
  uri = URI("https://zipcloud.ibsnet.co.jp/api/search?zipcode=#{params['zip_code']}")
  res = Net::HTTP.get_response(uri)
  results = res.body
  p results
  if res.is_a?(Net::HTTPSuccess)
    result_hash.new("bad request", 400)
    result_hash.to_json
end
  if(results['status'] == 500)
    result_hash.new("api internal error", 500)
    result_hash.to_json
  elsif(results['status'] == 400)
    result_hash.new("not found", 400)
    result_hash.to_json
  else
    #登録処理
   query_obj = Struct.new(:zip_code, :prefecture, :city, :town_area )
   query_obj['zip_code'] = results.fetch(:"zipcode")
   query_obj['prefecture'] = results.fetch(:"address1")
   query_obj['city'] = results.fetch(:"address2")
   query_obj['town_area'] = results.fetch(:"address3")
   statement = client.prepare('INSERT INTO zip_codes(zip_code, prefecture, city, town_area, created_at, updated_at)
                                VALUES (?, ?, ?, ?, current_time, current_time);')
   quiry_obj = statement.execute(quiry_obj["zip_code"], query_obj["prefecture"], quiry_obj["city"], quiry_obj["town_area"])
  end
   @results = client.query('SELECT id, zip_code, prefecture, city, town_area FROM zip_codes;')
   @results.to_json
end


 delete '/zip_codes/:id' do
  result_hash = Struct.new(:status, :status_code )
  statement = client.prepare('DELETE FROM zip_codes WHERE id = ?;' )
  @result = statement.execute(params['id'])
  if(@result.count == 0)
   result_hash.new("not found", 400)
   result_hash.to_json
  end
   result_hash.new("deleted", 200)
   result_hash.to_json
end



  







