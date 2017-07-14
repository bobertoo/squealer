# Squealer
a csv to postgresql table creation tool
## how to use
navigate to the project directory and then type `ruby bin/run.rb <pathtocsvfile>`.
CSV filename must have `.csv` extension with columns that include `int`, `float4`, `varchar`, `timestamp`(iso8601), and `boolean`.
## example
input:

`ruby bin/run.rb data.csv`

prints:

`CREATE TABLE data (id int, place varchar(5), score float4);`

## run tests
RSpec tests have been included with the project. To test, first run `bundle install` (http://bundler.io/) and then run `rspec`. Test file, `squealer_spec.rb` can be found in the `spec/` directory. Check it out!
