# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'

get '/memos' do
  @memo_files = Dir.glob('models/*').sort { |a, b| File.stat(a).birthtime <=> File.stat(b).birthtime }
  @memos = []
  @id = []
  @memo_files.each do |memo_file|
    File.open(memo_file.to_s, 'r') do |j|
      hash = JSON.parse(j.read)
      hash['title'] = '無題のタイトル' if hash['title'] == ''
      @title_id = []
      @title_id << hash['title']
      @title_id << hash['id']
      @memos << @title_id
    end
  end
  erb :main
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  @title = params[:title]
  @content = params[:content]
  memo = { "id": SecureRandom.uuid, "title": @title, "content": @content }
  File.open("models/#{memo[:id]}.json", 'w') do |io|
    io.puts(JSON.pretty_generate(memo))
  end
  redirect '/memos'
end

get '/memos/:id' do
  open("models/#{params[:id]}.json") do |io|
    @memo = JSON.parse(io.read)
  end
  erb :show
end

get '/memos/:id/edit' do
  open("models/#{params[:id]}.json") do |io|
    @memo = JSON.parse(io.read)
  end
  erb :edit
end

enable :method_override

patch '/memos/:id' do
  @title = params[:title]
  @content = params[:content]
  id = params['id']
  memo = { "id": id, "title": @title, "content": @content }
  File.open("models/#{id}.json", 'w') do |io|
    io.puts(JSON.pretty_generate(memo))
  end

  redirect '/memos'
end

delete '/memos/:id' do
  File.delete("models/#{params[:id]}.json")
  redirect '/memos'
end
