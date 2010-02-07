
module Kodr
  class App < KParts::MainWindow
    slots :new_document, :open_document, :close_document, :quit, :edit_keys

    def initialize
      super
      show
    end
  end
end

