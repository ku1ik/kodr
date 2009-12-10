class WrapWithTag < Kodr::DocumentCommand
  description "Wrap selection with tag"
  name "wrap_with_tag"
  shortcut "Alt+Shift+W"
  
  def call(env)
    opening_tag = KDE::InputDialog.get_text("Wrap selection with tag", "Enter tag to wrap selection with:", "")
    if opening_tag
      opening_tag.strip!
      unless opening_tag.start_with?("<")
        opening_tag = "<#{opening_tag}"
      end
      unless opening_tag.end_with?(">")
        opening_tag << ">"
      end
      closing_tag = "</" + opening_tag[/<(\w+)/, 1] + ">"
      if text = env[:selected_text]
        opening_tag + text + closing_tag
      else
        opening_tag + closing_tag
      end
    end
  end
end
