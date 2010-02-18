#!/usr/bin/env ruby

if RUBY_VERSION < "1.9.1"
  puts "Kodr requires Ruby version 1.9.1 or higher."
  exit 1
end

begin
  require 'korundum4'
  require 'ktexteditor'
rescue LoadError
  puts "Kodr requires Ruby KDE bindings (look for package like \"kdebindings-ruby\", \"kdebindings-kde4\" or similar)"
  exit 1
end

LIB_DIR = File.expand_path(File.dirname(__FILE__))

#%w(extensions logger editor editor_set action dir_model project_viewer ack search_in_files/search_in_directory_dialog
#  search_in_files/search_in_project_dialog app).each do |file|
#  require "#{LIB_DIR}/#{file}"
#end

require "color"

%w(ext style textmate_theme_reader tm_theme text_mate_highlighter text_mate_edit app).each do |file|
  require "#{LIB_DIR}/#{file}"
end

#Dir["#{LIB_DIR}/actions/**/*.rb"].each { |file| require file }

aboutData = KDE::AboutData.new("kodr",
                               "",
                               KDE::ki18n("Kodr"),
                               "0.1",
                               KDE::ki18n("Kodr - Programmer's Editor"),
                               KDE::AboutData::License_LGPL_V2,
                               KDE::ki18n("(c) 2009 Marcin Kulik"),
                               KDE::LocalizedString.new,
                               "http://www.kodr.org",
                               "marcin.kulik@gmail.com")
aboutData.addAuthor(KDE::ki18n("Marcin Kulik"), KDE::ki18n("Author"), "marcin.kulik@gmail.com", "http://sickill.net")
aboutData.setProgramIconName("kodr")
KDE::CmdLineArgs::init(ARGV, aboutData)

options = KDE::CmdLineOptions.new
options.add("+[file]", KDE::ki18n("File to open"))
KDE::CmdLineArgs::addCmdLineOptions(options)
args = KDE::CmdLineArgs::parsedArgs

app = KDE::Application.new
w = Kodr::App.new
w.show
app.exec

# Dir["#{LIB_DIR}/actions/**/*.rb"].each { |file| require file }

#app = Qt::Application.new(ARGV.to_java(:string))
#win = Kodr::App.new
#win.show
#Qt::Application.exec
