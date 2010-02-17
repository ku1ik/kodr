module Kodr
  class TMTheme
    attr_accessor :ui, :items, :name
    include Coloration::Readers::TextMateThemeReader
  end
end

