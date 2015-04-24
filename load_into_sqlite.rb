#!/usr/bin/env ruby

require 'octokit'
require 'ruby-progressbar'

require "sqlite3"
require 'json'
require 'CSV'

PROG_FMT = "%t: |%B| (%c/%C %E)   "
progress = ProgressBar.create(
  :title => "Creating initial database",
  :total => 218369,
  format: PROG_FMT)

# Open a database
DB = SQLite3::Database.new("./gh_users.db")

# Create a table if there isn't one
rows = DB.execute <<-SQL
  create table if not exists users (
    username varchar(255),
    prs_closed int,
    prs_merged int,
    pr_ratio float,
    stars int,
    watches int,
    forks int,
    repos int
  );
SQL

Octokit.configure do |c|
  c.access_token = 'b88a350a62dc76da2628e7d1867514a15520f53c'
end

# Read in the users
# 218369 users in file
users = CSV.open('bigdata', 'r')
users.first #advance the pointer one time

users.each do |user|
  username = user[0]
  next if username.nil?
  username = username.strip.tr('"', '')
  prs_closed = user[1]
  prs_merged = user[3]
  DB.execute("insert into users (username, prs_closed, prs_merged, pr_ratio) values ( ?, ?, ?, ?)", 
    username,
    prs_closed,
    prs_merged,
    prs_merged.to_f / prs_closed.to_f
    )
  progress.increment
end