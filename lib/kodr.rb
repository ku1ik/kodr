if RUBY_PLATFORM != "java"
  puts "Kodr requires JRuby."
  exit 1
end

require "rubygems"
require "extlib"
require "qtjruby-core"
require "color"

LIB_DIR = File.expand_path(File.dirname(__FILE__))

%w(ext style textmate_theme_reader tm_theme text_mate_highlighter text_mate_edit app).each do |file|
  require "#{LIB_DIR}/#{file}"
end

# Dir["#{LIB_DIR}/actions/**/*.rb"].each { |file| require file }

app = Qt::Application.new(ARGV.to_java(:string))
win = Kodr::App.new
win.show
Qt::Application.exec
