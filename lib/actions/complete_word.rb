class CompleteWordAction < Kodr::Action
  description "Complete word"
  name "complete_word"
  shortcut "Esc"
  
  def run
    puts "completing"
  end
end
