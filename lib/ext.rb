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
