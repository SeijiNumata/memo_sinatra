# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

before do
  db_setup
end

after do
  @connection.finish
end

def db_setup
  @connection = PG.connect(host: ENV['DB_HOST'],
                           user: ENV['DB_USER'],
                           password: ENV['DB_PASSWORD'],
                           dbname: 'postgres')
end

# IDを振り分ける（4桁）
def id_countup
  @connection.exec('SELECT * FROM memos ORDER BY id DESC LIMIT 1') do |result|
    @count_id = 1 # reslutが存在しない場合、最初に登録するデータのid
    result.each do |count|
      count = count['id'].to_i + 1
      @count_id = count.to_s
    end
  end
end

# 書き込み
def write(id, title, content)
  @connection.exec('INSERT INTO memos VALUES ($1, $2, $3);', [id, title, content])
end

# 削除
def delete(id)
  @connection.exec('DELETE FROM memos WHERE id=($1);', [id])
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @connection.exec('SELECT * FROM memos ORDER BY id ASC') do |result|
    @result = []
    result.each do |row|
      @result << row
    end
  end
  erb :main
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  id_countup
  title = params[:title]
  title = '無題のタイトル' if @title == ''
  content = params[:content]
  write(@count_id, title, content)
  redirect '/memos'
end

get '/memos/:id' do
  id = params[:id]
  search_memo = @connection.exec('SELECT * from memos WHERE id=($1);', [id])
  @memo = search_memo[0]
  erb :show
end

get '/memos/:id/edit' do
  id = params[:id]
  search_memo = @connection.exec('SELECT * from memos WHERE id=($1);', [id])
  @memo = search_memo[0]
  erb :edit
end

enable :method_override

patch '/memos/:id' do
  id = params[:id].to_s
  title = params[:title]
  title = '無題のタイトル' if title == ''
  content = params[:content]
  @connection.exec("UPDATE memos SET title=($1) WHERE id='#{id}';", [title])
  @connection.exec("UPDATE memos SET content=($1) WHERE id='#{id}';", [content])
  redirect '/memos'
end

delete '/memos/:id' do 
  delete(params[:id].to_s)
  redirect '/memos'
end
