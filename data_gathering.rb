#!/usr/bin/env ruby

require 'octokit'
require 'ruby-progressbar'

require "sqlite3"
require 'json'
require 'parallel'

Octokit.configure do |c|
  c.access_token = 'b88a350a62dc76da2628e7d1867514a15520f53c'
end

# stats for user
def user_stats(username)
  # sum their repo forks, stars, and watches
  forks = 0
  stars = 0
  watches = 0

  # auto pagination
  Octokit.auto_paginate = true

  repo_count = 0
  repos = Octokit.repos(username, per_page: 100).to_a.map(&:to_h)
  repo_count += repos.count

  repos.each do |repo|
    forks += repo[:forks]
    stars += repo[:stargazers_count]
    watches += repo[:watchers_count]
  end

  return {username: username, forks: forks, stars: stars, watches: watches, repos: repos.count}
end

DB = SQLite3::Database.new("./gh_users.db")

remaining = DB.execute('SELECT COUNT(*) FROM users WHERE stars IS NULL')[0][0]

puts "#{remaining} records to process"

PROG_FMT = "%t: |%B| (%c/%C %E)   "
progress = ProgressBar.create(
  :title => "Querying users",
  :total => remaining,
  format: PROG_FMT)

users = DB.execute('SELECT * FROM users WHERE stars IS NULL ORDER BY RANDOM()')

users.each_slice(20) do |user_slice|
  results = Parallel.map(user_slice, in_threads: 20) do |u|
    username = u[0]

    begin
      next user_stats(username)
    rescue Octokit::NotFound
      next nil
    end
  end

  results.each do |stats|
    next if stats.nil?
    DB.execute("UPDATE users SET 
    forks = #{stats[:forks]}, 
    stars = #{stats[:stars]}, 
    watches = #{stats[:watches]},
    repos = #{stats[:repos]}
    WHERE username = (?)", stats[:username])
    progress.increment
  end
end