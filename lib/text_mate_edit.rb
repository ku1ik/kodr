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
    end
  end
end
