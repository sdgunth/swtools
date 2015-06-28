task default: "start"

desc "Runs Shotgun while watching Sass"
task :start do
  require "sinatra/activerecord/rake"
  require "./swtools" # change this if your app file is something other than "app.rb"
  system "shotgun & sass --watch public/css/sass:public/css"
end