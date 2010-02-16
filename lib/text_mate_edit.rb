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
        t = "\n" + current_line[/^\s*/]
        if current_line =~ INC_IND
          t << "  " # + t
        end
        insertPlainText t
      else
        super
      end
    end

    def current_line
      textCursor.block.text
    end

    def previous_line
      document.findBlockByLineNumber(textCursor.blockNumber-1).text
    end

    def text_changed
      prev_indent_size = previous_line[/^\s*/].to_s.size
      curr_indent_size = current_line[/^\s*/].to_s.size

      if current_line =~ DEC_IND && (d = prev_indent_size - curr_indent_size) != 2
        unindent_width = (previous_line =~ INC_IND ? 0 : 2)
        a = d - unindent_width
        cursor = textCursor
        pos = cursor.position
        cursor.movePosition(Qt::TextCursor::MoveOperation::StartOfLine)
        setTextCursor(cursor)
        if a < 0
          t = [-a, curr_indent_size].min
          t.times { cursor.deleteChar }
          a = -t
        else
          a.times { cursor.insertText " " }
        end
        cursor.setPosition(pos + a)
        setTextCursor(cursor)
      end
    end
  end
end
