module Kodr
  module Textmate
    module LineNumbering
      
      class LineNumberArea < Qt::Widget
        def initialize(editor)
          super
          @editor = editor
        end
        
        def sizeHint
          Qt::Size.new(@editor.line_number_areaWidth, 0)
        end
        
        def paintEvent(event)
          @editor.line_number_area_paint_event(event)
        end
      end
      
      def line_number_area_paint_event(event)
        painter = Qt::Painter.new(@line_number_area)
        painter.fillRect(event.rect, Qt::lightGray)
        block = firstVisibleBlock
        blockNumber = block.blockNumber
        top = blockBoundingGeometry(block).translated(contentOffset).top
        bottom = top + blockBoundingRect(block).height
        while block.isValid && top <= event.rect.bottom
          if block.isVisible && bottom >= event.rect.top
            number = (blockNumber + 1).to_s
            painter.setPen(Qt::black)
            painter.drawText(0, top, @line_number_area.width - 3, fontMetrics.height, Qt::AlignRight, number)
          end
          
          block = block.next
          top = bottom
          bottom = top + blockBoundingRect(block).height
          blockNumber += 1
        end
      end

      def resizeEvent(e)
        super(e)
        cr = contentsRect
        @line_number_area.set_geometry(Qt::Rect.new(cr.left, cr.top, line_number_area_width, cr.height))
      end
      
      def line_number_area_width
        digits = 1
        max = [1, blockCount].max
        while max >= 10
          max /= 10
          digits += 1
        end
        space = 3 + fontMetrics.width("9") * digits + 3
      end
      
      def update_line_number_area_width
        setViewportMargins(line_number_area_width, 0, 0, 0)
      end

      def update_line_number_area(rect, dy)
        if dy != 0
          @line_number_area.scroll(0, dy)
        else
          @line_number_area.update(0, rect.y, @line_number_area.width, rect.height)
        end
        
        if rect.contains(viewport.rect)
          update_line_number_area_width
        end
      end
      
    end
  end
end
