module Kodr
  class WrapWithTag < DocumentAction
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
        opening_tag + env[:selected_text].to_s + "</" + opening_tag[/<(\w+)/, 1] + ">"
      end
    end
  end
end
