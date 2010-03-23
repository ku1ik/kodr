require "cmd_runner"

module Kodr
  class SparkupAction < Action
    description "Sparkup"
    name "sparkup"
    shortcut "Ctrl+Space"
    
    def call
      line = document.line(cursor.line)
      return if line.blank?
      runner = SparkupRunner.new(line, editor.indentation_width)
      runner.on_success do
        output = runner.readAllStandardOutput.to_s.rstrip
        document.remove_text_range(cursor.line, 0, cursor.line, line.size)
        editor.insert_text(output)
      end
      runner.start
    end
  end

  class SparkupRunner < CmdRunner
    def initialize(input, indentation)
      super("sparkup", "--indent-spaces=#{indentation}")
      @stdin_data = input
    end

    def stdin_data
      @stdin_data
    end
  end
end

