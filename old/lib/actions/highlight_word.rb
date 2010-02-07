module Kodr
  class HighlightWordAction < Action
    description "Highlight word"
    name "highlight_word"
    shortcut "Alt+Shift+H"

    def call(env)
      doc_range = document.document_range
      smart_i = document.qobject_cast(KTextEditor::SmartInterface)
      h_range = smart_i.new_smart_range(doc_range)
      
      search_i = document.qobject_cast(KTextEditor::SearchInterface)
      result_ranges = search_i.search_text(h_range, "def", 0) #, KTextEditor::Search::WholeWords)
  #     p result_ranges
      
  #     h_range.set_insert_behavior(KTextEditor::SmartRange::DoNotExpand)
  #     attr = Attribute.new
  #     attr.setBackground(Qt::red)
  #     h_range.setAttribute(attr)
    end
  end
end
