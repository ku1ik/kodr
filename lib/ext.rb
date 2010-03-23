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
  def try(*args)
    send(*args) if respond_to?(args.first)
  end
  
  def blank?
    false
  end
  
  def deep_clone(cloned={})
    clone
  end
end

class Hash
  def try_dup
    self
  end

  def deep_clone(cloned={})
    return cloned[self] if cloned.key?(self)
    copy = self.clone
    cloned[self] = copy
    copy.each do |k, v|
      next if v.nil? || v.is_a?(Fixnum)
      elem = v.deep_clone(cloned)
      copy[k] = elem
    end
    copy
  end
end

class Array
  def deep_clone(cloned={})
    return cloned[self] if cloned.key?(self)
    copy = self.clone
    cloned[self] = copy
    copy.each_with_index do |e, i|
      next if e.nil? || e.is_a?(Fixnum)
      elem = e.deep_clone(cloned)
      copy[i] = elem
    end
    copy
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
  
  def move_to_start_of_line
    move_position(Qt::TextCursor::StartOfLine)
  end
  
  def move_right(n, mode=Qt::TextCursor::MoveAnchor)
    move_position(Qt::TextCursor::NextCharacter, mode, n)
  end
end

class Word < String
  attr_accessor :position
end

class Pathname
  def /(other)
    self.+(other)
  end
end

