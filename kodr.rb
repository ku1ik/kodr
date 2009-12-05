#!/usr/bin/env ruby

require 'korundum4'
require 'ktexteditor'

require 'lib/view'
require 'lib/app'

app = Qt::Application.new ARGV
Kodr::App.new
app.exec
