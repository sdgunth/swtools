require "sinatra/activerecord/rake"
require "./swtools"

task default: "start"

desc "Runs Shotgun while watching Sass"
task :start do
  system "shotgun & sass --watch public/css/sass:public/css"
end