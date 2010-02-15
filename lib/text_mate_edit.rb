INC_IND = Regexp.new File.read("reg.txt").gsub("&gt;", ">").gsub("&lt;", "")
DEC_IND = %r(^\s*([}\]]\s*$|(end|rescue|ensure|else|elsif|when)\b))

module Kodr
  class TextMateEdit < Qt::TextEdit
    def initialize
      super
      set_font_family("Envy Code R")
      set_font_point_size(10.0)
      new_palette = palette
      new_palette.set_color(Qt::Palette::ColorRole::Base, Qt::Color.new("2b".to_i(16), "2b".to_i(16), "2b".to_i(16)))
      new_palette.set_color(Qt::Palette::ColorRole::Text, Qt::Color.new(200, 180, 80))
      set_palette(new_palette)
      @highlighter = TextMateHighlighter.new(document)
      self.textChanged { text_changed }
    end

    def keyPressEvent(e)
      if e.key == Qt::Key::Key_Tab.value
        insertPlainText "  "
      elsif e.key == Qt::Key::Key_Return.value
        t = current_line[/^\s*/]
        if current_line =~ INC_IND
          t = "  " + t
        end
        append t
      else
        super
      end
    end

    def current_line
      textCursor.block.text
    end

    def previous_line
      document.findBlockByLineNumber(textCursor.blockNumber).text
    end

    def text_changed
      if current_line =~ DEC_IND && (d = previous_line[/^\s*/].to_s.size - current_line[/^\s*/].to_s.size) != 2
        d = d - 2
        d = 0 if d < 0
        pos = textCursor.position
        textCursor.movePosition(Qt::TextCursor::MoveOperation::StartOfLine)
        #d.times { textCursor.deleteChar }
        #textCursor.setPosition(pos - d)
        puts "unindenting!"
      end
    end
  end
end
