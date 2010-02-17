class Object
  def tap
    yield(self)
    self
  end

  def try(method)
    send method if respond_to?(method)
  end
  
  def blank?
    false
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
end

class Color::RGB
  def to_qt
    Qt::Color.new(r*255, g*255, b*255)
  end
end

