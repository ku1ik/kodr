class CompleteWordAction < Kodr::Command
  description "Complete word"
  name "complete_word"
  shortcut "Esc"
  
  def call(env)
    puts "completing"
  end
end
