def log(text)
  puts "~ " + Time.now.strftime("%H:%M:%S") + " " + text
end

def deprec
  log "!!! Deprecated #{self.class}##{caller.first[/in `(.+)'$/, 1]}"
end
