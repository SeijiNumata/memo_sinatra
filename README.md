# memo_sinatra
WebアプリからのDB利用
# 実行前にローカル環境でmemosのデータベースを作ってください。
host: 'localhost', user: '', password: '', dbname: 'postgres'で動きます。
```
% psql postgres
# create database memos;
# create table memos(id char(4) not null,title text not null,content text, primary key(id));
CREATE TABLE
```