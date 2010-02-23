class Class
  def cattr_accessor(*syms)
    syms.each do |ivar|
      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def self.#{ivar}(obj=:_undefined)
          if obj == :_undefined
            return @#{ivar} if defined?(@#{ivar})
            return nil if self.object_id == #{self.object_id}
            ivar = superclass.#{ivar}
            return nil if ivar.nil?
            @#{ivar} = ivar.try_dup
          else
            @#{ivar} = obj
          end
        end
        
        def self.#{ivar}=(obj)
          @#{ivar} = obj
        end
        
        def #{ivar}
          self.class.#{ivar}
        end
      RUBY
    end
  end
end

class Object
  def try(method)
    send method if respond_to?(method)
  end
  
  def blank?
    false
  end
end

class Hash
  def try_dup
    self
  end
end

class NilClass
  def blank?
    true
  end
end

class String
  def blank?
    self.strip == ''
  end
  
  def indentation
    self[/^\s*/].to_s.size
  end
  
  def increases_indentation?(mode)
    self =~ INC_IND
  end
  
  def decreases_indentation?(mode)
    self =~ DEC_IND
  end
end

require "color"
class Color::RGB
  def to_qt
    Qt::Color.new(r*255, g*255, b*255)
  end
end

class Qt::TextCursor
  def line
    block_number
  end
  
  def column
    column_number
  end
end

class Word < String
  attr_accessor :position
end
