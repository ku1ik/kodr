class KTextEditor::Cursor
  def ==(other)
    other.is_a?(KTextEditor::Cursor) && self.line == other.line && self.column == other.column
  end
end
