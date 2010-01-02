module Kodr
  class Ack < Qt::Process
    ACK_PATH = File.expand_path(File.dirname(__FILE__) + "/search_in_files/ack_runner.rb")
    
    def initialize(flags, phrase, dir)
      super(App.instance)
      log "Ack.initialize"
      @cmd = "#{ACK_PATH} #{flags} #{phrase}"
      set_working_directory(dir)
      set_process_channel_mode(Qt::Process::SeparateChannels)
      set_read_channel(Qt::Process::StandardOutput)
      connect(self, SIGNAL("finished(int, QProcess::ExitStatus)")) do |exit_code, exit_status|
        log "Ack#on_success"
        @on_success.call
      end
      connect(self, SIGNAL("error(QProcess::ProcessError)")) do |error|
        log "Ack#on_error: #{error}"
        @on_error.call
      end
      connect(self, SIGNAL("readyReadStandardOutput()")) do
        log "Ack#on_ready_read"
        @on_ready_read.call
      end
    end
    
    def start
      log "Ack#start: #{@cmd}"
      super(@cmd)
      close_write_channel
    end
    
    def on_success(&blk)
      @on_success = blk
    end
    
    def on_error(&blk)
      @on_error = blk
    end
    
    def on_ready_read(&blk)
      @on_ready_read = blk
    end
  end
end
