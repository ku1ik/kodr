require 'korundum4'

class QMateEdit < Qt::Widget
  def initialize
    super
  end
  
  def paintEvent(e)
    painter = Qt::Painter.new(self)
    painter.fillRect(e.rect, Qt::lightGray)
    painter.drawText(0, 10, 100, 15, Qt::AlignLeft, "Fuuuuuuuuuuu")
  end
end

class MainWindow < Qt::MainWindow
  def initialize
    super
    self.window_title = 'QMateEdit test'
    resize(500, 300)
    self.central_widget = QMateEdit.new
  end
  
end

if $0 == __FILE__
  a = Qt::Application.new(ARGV)
  w = MainWindow.new
  w.show
  a.exec
end
