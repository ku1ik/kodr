require 'plist'
require 'color'

module Kodr
  module Textmate
    class Theme
      attr_accessor :ui, :items, :name
  
      def read(file_name)
        # parse TM theme
        tm_theme = Plist.parse_xml(File.read(file_name).gsub("ustring", "string"))
        self.name = tm_theme["name"]
        settings = tm_theme["settings"]
        # set ui properties
        self.ui = SelectorHash.new(settings.delete_at(0)["settings"])
        bg = Color::RGB.from_html(ui["background"][0..6])
        ui.keys.each do |key|
          if (col = ui[key]).size > 7 # we have color with alpha channel
            alpha = (100 * ((col[-2..-1]).to_i(16) / 255.0)).to_i
            color = Color::RGB.from_html(col[0..-3])
            color = color.mix_with(bg, alpha)
          else
            color = Color::RGB.from_html(col)
          end
          ui[key] = color
        end
        ui["background"] = bg
  
        # set items
        self.items = SelectorHash.new
        settings.each do |rule|
          selectors = rule["scope"]
          style = rule["settings"]
          if font_style = style.delete("fontStyle")
            if font_style.include?("bold")
              style[:bold] = true
            end
            if font_style.include?("italic")
              style[:italic] = true
            end
            if font_style.include?("underline")
              style[:underline] = true
            end
          end
          style = Style.new(style)
          unless selectors.blank? || style.blank?
            selectors.split(",").each do |selector|
              items[selector.strip] = style
            end
          end
        end
  
      end
  
    end
  
    class Style
      attr_accessor :foreground, :background, :bold, :italic, :underline, :strike
      
      def initialize(obj=nil)
        if obj
          case obj
          when String
            initialize_from_hash({ :foreground => obj })
          when Hash
            initialize_from_hash(obj)
          end
        end
      end
      
      def initialize_from_hash(h)
        h.keys.each do |key|
          value = h[key]
          if value.is_a?(String)
            value = Color::RGB.from_html(value[0..6])
          end
          send("#{key}=", value)
        end
      end
      
      def blank?
        foreground.nil? && background.nil?
      end
  
      def to_qt
        # Qt::TextCharFormat.new.tap { |f| f.set_font_weight(75); f.set_foreground(Qt::Brush.new(Qt::Color.new(80, 10, 120))) },
        format = Qt::TextCharFormat.new
        format.set_font_weight(75) if bold
        format.set_foreground(Qt::Brush.new(foreground.to_qt)) if foreground
        format.set_background(Qt::Brush.new(background.to_qt)) if background
        format.set_font_italic(true) if italic
        format.set_font_underline(true) if underline
        format
      end
    end
  
    class SelectorHash < Hash
      def initialize(h={})
        h.keys.each do |key|
          self[key] = h[key]
        end
      end
  
      def [](key, deep=true)
        return nil if key.blank?
        key = key.to_s
        value = super(key)
        if value
          value
        elsif deep
          self[key.split(".")[0..-2].join(".")]
        end
      end
    end
  end
end
