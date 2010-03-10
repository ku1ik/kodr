require "korundum4"

app = Qt::Application.new(ARGV)

class MyHighlighter < Qt::SyntaxHighlighter
  def highlightBlock(line)
    puts "highli"
    setCurrentBlockUserData(Qt::TextBlockUserData.new)
  end
end

class MyEdit < Qt::TextEdit
  def initialize
    super
    @highlighter = MyHighlighter.new(self)
  end
end

w = MyEdit.new
w.show

app.exec