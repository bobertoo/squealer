#!/usr/bin/env ruby
require_relative "../lib/squealer"

if !ARGV[0]
  puts "Error: needs a csv file as argument"
elsif !/.+\.csv$/.match(ARGV[0])
  puts "Error: argument must be a .csv file"
else
  squeal = Squealer.new
  squeal.csv = File.open(ARGV[0])
  squeal.table_name = /\/?(\w+)\./.match(ARGV[0])[1]
  puts(squeal.print_postgres_query)
end
