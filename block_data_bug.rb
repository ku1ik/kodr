require "korundum4"

class MyHighlighter < Qt::SyntaxHighlighter
  @@data = []

  def highlightBlock(line)
    old_data = currentBlockUserData
    new_data = Qt::TextBlockUserData.new
    @@data << new_data
    setCurrentBlockUserData(new_data)
    @@data.delete(old_data) if @@data.include?(old_data)
  end
end

class MyEdit < Qt::TextEdit
  def initialize
    super
    @highlighter = MyHighlighter.new(document)
  end
end

app = Qt::Application.new(ARGV)

w = MyEdit.new
w.show

app.exec

