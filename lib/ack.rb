module Kodr
  class Ack < CmdRunner
    def initialize(flags, phrase, dir)
      log "Ack.initialize"
      super("ack_runner.sh", "#{flags} #{phrase}", dir)
    end
end
