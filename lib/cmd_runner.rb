module Kodr
  class CmdRunner < Qt::Process
    VENDOR_PATH = Pathname(__FILE__).dirname / ".." / "vendor"
    
    def initialize(cmd, args=nil, dir=nil)
      super(App.instance)
      log "CmdRunner#initialize"
      @cmd = "#{VENDOR_PATH / cmd}"
      if args
        @cmd << " " + args
      end
      if dir
        set_working_directory(dir)
      end
      set_process_channel_mode(Qt::Process::SeparateChannels)
      set_read_channel(Qt::Process::StandardOutput)
      connect(self, SIGNAL("finished(int, QProcess::ExitStatus)")) do |exit_code, exit_status|
        log "CmdRunner#on_success"
        @on_success.call if @on_success
      end
      connect(self, SIGNAL("error(QProcess::ProcessError)")) do |error|
        log "CmdRunner#on_error: #{error}"
        @on_error.call if @on_error
      end
      connect(self, SIGNAL("readyReadStandardOutput()")) do
        log "CmdRunner#on_ready_read"
        @on_ready_read.call if @on_ready_read
      end
    end
    
    def start
      log "CmdRunner#start: #{@cmd}"
      super(@cmd)
      if data = stdin_data
        write(data)
      end
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

    def stdin_data
      nil
    end
  end
end
