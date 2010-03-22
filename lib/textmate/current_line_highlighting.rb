module Kodr
  module Textmate
    module CurrentLineHighlighting
      def highlight_current_line
        selection = Qt::TextEdit::ExtraSelection.new
        line_color = theme.ui["lineHighlight"].to_qt
        selection.format.set_background(Qt::Brush.new(line_color))
        selection.format.set_property(Qt::TextFormat::FullWidthSelection, Qt::Variant.new(true))
        c = text_cursor
        c.clear_selection
        selection.cursor = c
        setExtraSelections([selection])
      end
    end
  end
end
