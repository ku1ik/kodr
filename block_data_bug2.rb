require "korundum4"

module Kodr
  class App < KParts::MainWindow
    def initialize(doc=nil)
      super(nil, 0)
      set_central_widget(MyEdit.new)
      show
    end
  end
end

class MyHighlighter < Qt::SyntaxHighlighter
  def highlightBlock(line)
    puts "highli"
    setCurrentBlockUserData(Qt::TextBlockUserData.new)
  end
end

class MyEdit < Qt::TextEdit
  def initialize
    super
    @highlighter = MyHighlighter.new(document)
  end

end

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

$app.exec

