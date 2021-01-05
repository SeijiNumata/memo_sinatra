# memo_sinatra
WebアプリからのDB利用
# 実行前にローカル環境でmemoテーブルを作っていただく必要があります。
host: 'localhost', user: '', password: '', dbname: 'postgres'で動きます。
```
% psql postgres
# create database memos;
# create table memos(id integer not null,title text not null,content text, primary key(id));
CREATE TABLE
```
