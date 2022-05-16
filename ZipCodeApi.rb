require "bundler/setup"

require 'mysql2'
require 'sinatra'
require 'uri'
require 'net/http'


client = Mysql2::Client.new(host: "localhost", username: "root", password: '', database: 'ruby_tutorial')


def not_found()
  data = [
    {
      status: 'not found',
      status_code: 400
    }
  ]
  return
end

def bad_request()
  data = [
    {
      status: 'bad request',
      status_code: 400
    }
  ]
end

# 全件取得
get '/zip_codes' do
results = client.query('SELECT id, zip_code, prefecture, city, town_area FROM zip_codes;')
  data =  results.map do |row| 
    hash = {
      id: row ['id'],
      zip_code: row ['zip_code'],
      prefecture: row ['prefecture'],
      city: row['city'],
      town_area: row ['town_area']
    }
  end
  data.to_json
end

# レコード新規登録
post '/zip_codes' do
  zip_codes = params[:zip_codes]
  statement = client.prepare('INSERT INTO zip_codes(zip_code, prefecture, city, town_area, created_at, updated_at)
                                VALUES (?, ?, ?, ?, current_time, current_time);')
  results = statement.execute(zip_codes["zip_code"], zip_codes["prefecture"], zip_codes["city"], zip_codes["town_area"])
  bad_request().to_json = if results.size.zero? 
  else
    data = [
      {
      status: 'created',
      status_code: 201
      }
    ]
  end
    data.to_json
end


#id指定get
get '/zip_codes/:id' do
  statement = client.prepare('SELECT * FROM zip_codes WHERE id = ? ;')
  results = statement.execute(params['id'])
  not_found().to_json = if results.size.zero?
  else
    data = results.map do |row|
      hash = {
      id: row ['id'],
      zip_code: row ['zip_code'],
      prefecture: row ['prefecture'],
      city: row['city'],
      town_area: row ['town_area']
    }
    end
  end
    data.to_json
end

#id指定アップデート
put '/zip_codes/:id' do
  zip_codes = params['zip_code', 'prefecture', 'city', 'town_area']
  statement = client.prepare('SELECT * FROM zip_codes WHERE id = ? ;' )
  results = statement.execute(params['id'])
  #存在チェック
  not_found().to_json = if results.size.zeroz?
  else
    #登録処理
    statement = client.prepare('UPDATE zip_codes SET zip_code = ?, prefecture = ?, city = ?, town_area = ? WHERE id = ?;')
    results = statement.execute(zip_codes["zip_code"], zip_codes["prefecture"], zip_codes["city"], zip_codes["town_area"], zip_codes["id"])
    data = []
    hash = {
      status: 'updated',
      status_code: 200
    }
    data.push(hash).to_json
  end
end

post '/request_zip_cloud/:zip_code' do
  result_hash = Struct.new(:status, :status_code )
  uri = URI("https://zipcloud.ibsnet.co.jp/api/search?zipcode=#{params['zip_code']}")
  res = Net::HTTP.get_response(uri)
  results = res.body
  bad_request().to_json = if res.is_a?(Net::HTTPSuccess)
  return

  if(results['status'] == 500)
    data = [
      {
      status: 'api internal error',
      status_code: 500
    }
  ]
    data.to_json
  elsif(results['status'] == 400)
    not_found().to_json
  else
  #登録処理
  @results.map do |row| 
    data = [
      {
      zip_code: row ['zip_code'],
      prefecture: row ['prefecture'],
      city: row['city'],
      town_area: row ['town_area']
    }
  ]
  end
    statement = client.prepare('INSERT INTO zip_codes(zip_code, prefecture, city, town_area, created_at, updated_at)
                                VALUES (?, ?, ?, ?, current_time, current_time);')
    query = statement.execute(data["zip_code"], data["prefecture"], data["city"], data["town_area"])
    data.to_json
  end
end

#id指定デリート
delete '/zip_codes/:id' do
statement = client.prepare('DELETE FROM zip_codes WHERE id = ?;' )
result = statement.execute(params['id'])
  not_found().to_json = if result.size.zero?
  else
    data = [
      {
      status: 'deleted',
      status_code: 200
    }
  ]
  end
    data.to_json
  end
end
