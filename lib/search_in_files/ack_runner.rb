#!/usr/bin/env ruby

system File.expand_path(File.dirname(__FILE__) + "/ack-standalone.sh") + " " + ARGV.join(" ") + " <&-"
