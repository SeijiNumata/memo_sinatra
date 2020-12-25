# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'pg'

def db_setup
  @connection = PG.connect(host: 'localhost',
                           user: '',
                           password: '',
                           dbname: 'postgres')
end

# IDを振り分ける（4桁）
def id_countup
  @connection.exec('SELECT * FROM memos ORDER BY id DESC LIMIT 1') do |result|
    @count_id = '0001' # reslutが存在しない場合、最初に登録するデータのid
    result.each do |count|
      count = count['id'].to_i + 1
      count = count.to_s
      @count_id = '0' * (4 - count.length) + count
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

# トップページ
get '/memos' do
  db_setup
  @connection.exec('SELECT * FROM memos ORDER BY id ASC') do |result|
    @result = []
    result.each do |row|
      @result << row
    end
  end
  @connection.finish
  erb :main
end

get '/memos/new' do
  erb :new
end

post '/memos' do # 新規追加
  db_setup
  id_countup
  title = params[:title]
  title = '無題のタイトル' if @title == ''
  content = params[:content]
  write(@count_id, title, content)
  @connection.finish
  redirect '/memos'
end

get '/memos/:id' do # 編集画面
  db_setup
  id = params[:id]
  @connection.exec('SELECT * from memos WHERE id=($1);', [id]) do |result|
    result.each do |row|
      @memo = row
    end
  end
  @connection.finish
  erb :show
end

get '/memos/:id/edit' do
  db_setup
  id = params[:id]
  @connection.exec('SELECT * from memos WHERE id=($1);', [id]) do |result|
    result.each do |row|
      @memo = row
    end
  end
  @connection.finish
  erb :edit
end

enable :method_override

patch '/memos/:id' do
  db_setup
  id = params[:id].to_s
  title = params[:title]
  title = '無題のタイトル' if title == ''
  content = params[:content]
  @connection.exec("UPDATE memos SET title=($1) WHERE id='#{id}';", [title])
  @connection.exec("UPDATE memos SET content=($1) WHERE id='#{id}';", [content])
  @connection.finish
  redirect '/memos'
end

delete '/memos/:id' do # 削除
  db_setup
  delete(params[:id].to_s)
  @connection.finish
  redirect '/memos'
end