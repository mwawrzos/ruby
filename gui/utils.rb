require 'logger'

class Logger
  def check(asd, &block)
    info('sprawdzam: ' + asd)
  end
end

class RubinowyStan
  def log(akcja)
    # alert funkcja
    @logger.info("#{akcja.event} #{self.class}")
    $log_handler.call @logi.string.strip
    @logi.reopen
  end
  def fail(akcja)
    @logger.error("Nie mozna wykonac akcji #{akcja.event} gdy #{self.class} #{state}")
  end

  def initialize
    @logi = StringIO.new
    @logger = Logger.new @logi
  end
end

class Event
  def initialize(event)
    @event = event
  end
  attr_accessor :event
end