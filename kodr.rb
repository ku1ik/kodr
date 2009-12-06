#!/usr/bin/env ruby

require 'korundum4'
require 'ktexteditor'

require 'lib/view'
require 'lib/app'

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

app = KDE::Application.new
Kodr::App.new

app.exec
