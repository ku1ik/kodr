#!/usr/bin/env ruby

if RUBY_VERSION < "1.9.1"
  puts "Kodr requires Ruby version 1.9.1 or higher."
  exit 1
end

begin
  require 'korundum4'
rescue LoadError
  puts "Kodr requires Ruby KDE bindings (look for package like \"kdebindings-ruby\", \"kdebindings-kde4\" or similar)"
  exit 1
end

require "pathname"

LIB_DIR = Pathname(__FILE__).dirname
$:.unshift(LIB_DIR.to_s)

require "ext"

$:.unshift((LIB_DIR / "textpow" / "lib").to_s)

require "textpow/lib/textpow"
require "logger"
require "app"

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

$app = KDE::Application.new
w = Kodr::App.new
# w.show

args.count.times do |n|
  Kodr::App.instance.open_document(args.url(n))
end

$app.exec
