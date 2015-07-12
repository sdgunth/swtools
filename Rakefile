require "sinatra/activerecord/rake"
require "./swtools"

task default: "start"

desc "Runs Sinatra while watching Sass"
task :start do
  system "sass --watch public/css/sass:public/css"
end