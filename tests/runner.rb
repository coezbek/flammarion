require 'optparse'
require 'fileutils'
require_relative "../lib/flammarion.rb"

$options = {}

def options; $options; end

OptionParser.new do |o|
  {
    '-l' => :list,
    # '-p' => :parallel,
    '-r' => :reload,
    '-s' => :snapshot
  }.each do |k,v|
    o.on(k) {|p| options[v] = p}
  end
  o.parse!
end

case
when options[:list]
  $r = Flammarion::Engraving.new(exit_on_disconnect: true)
  def sample(name, &block)
    $r.button(name.to_s.split("_").collect{|w| w[0] = w[0].upcase; w}.join(" ")) do
      # Launch a new process so that it will automatically reload any needed
      # changes.
      system("ruby #{__FILE__} #{options[:reload] ? "-r" : ""} #{name}")
    end
  end
when options[:snapshot]
  FileUtils.mkdir_p 'snapshots'
  def sample(name)
    return if ARGV[0] and name.to_s != ARGV[0]
    puts "Showing: #{name}"
    f = Flammarion::Engraving.new(title:name.to_s.split("_").collect{|w| w[0] = w[0].upcase; w}.join(" "))
    yield(f)
    sleep(1)
    File.write("snapshots/#{name}.png", f.snapshot)
    f.close
  end
else
  def sample(name)
    return if ARGV[0] and name.to_s != ARGV[0]
    puts "Showing: #{name}"
    f = Flammarion::Engraving.new(title:name.to_s.split("_").collect{|w| w[0] = w[0].upcase; w}.join(" "))
    yield(f)
    if options[:reload] then
      f.on_connect = Proc.new {yield(f)}
      sleep 1000 while true
    else
      f.wait_until_closed
    end
  end
end

require_relative "samples.rb"

$r.wait_until_closed if options[:list]
