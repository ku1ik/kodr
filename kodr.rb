#!/usr/bin/env ruby

require 'korundum4'
require 'ktexteditor'

require 'lib/extensions'
require 'lib/logger'
require 'lib/view'
require 'lib/view_space'
require 'lib/command'
require 'lib/app'

Dir['lib/commands/**/*.rb'].each { |c| require c }

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
Kodr::App.new

args.count.times do |n|
  Kodr::App.instance.open_document(args.url(n))
end

app.exec
