module Coloration

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
  
end

