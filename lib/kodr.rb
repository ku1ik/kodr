if RUBY_PLATFORM != "java"
  puts "Kodr requires JRuby."
  exit 1
end

LIB_DIR = File.expand_path(File.dirname(__FILE__))

%w(qt ext text_mate_highlighter text_mate_edit app).each do |file|
  require "#{LIB_DIR}/#{file}"
end

# Dir["#{LIB_DIR}/actions/**/*.rb"].each { |file| require file }

app = Qt::Application.new(ARGV.to_java(:string))
win = Kodr::App.new
win.show
Qt::Application.exec
