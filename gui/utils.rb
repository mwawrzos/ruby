require 'logger'

class Logger
  def check(asd, &block)
    info('sprawdzam: ' + asd)
  end
end

class RubinowyStan
  def log(akcja)
    @logger.info("#{akcja.event} #{self.class}")
  end
  def fail(akcja)
    @logger.error("Nie mozna wykonac akcji #{akcja.event} gdy #{self.class} #{state}")
  end

  def initialize
    @logger = Logger.new(STDOUT)
  end
end

class Event
  def initialize(event)
    @event = event
  end
  attr_accessor :event
end