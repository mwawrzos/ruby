require 'state_machine'

require '../maszyna/utils'
require '../maszyna/programy'

class Programator < RubinowyStan
  state_machine :initial => :wylaczony do
    before_transition :do => :log
    after_failure :do => :fail
    before_transition :zalaczony => :uruchomiony, :do => :uruchom

    event :zalacz do
      transition :wylaczony => :zalaczony
    end

    event :wylacz do
      transition all - [:wylaczony] => :wylaczony
    end

    event :start do
      transition :zalaczony => :uruchomiony
    end
  end

  def initialize
    @panel = PanelSterowania.new self
    @drzwi = Drzwi.new
    @beben = Beben.new
    @dozowniki = Dozowniki.new self
    @regulator_wody = RegulatorWody.new self

    @watki = []
    super()
  end

  def uruchom
    @panel.program(0).fire_state_event(:nastepny)
  end

  attr_reader :drzwi
  attr_reader :beben
  attr_reader :dozowniki
  attr_reader :panel
  attr_reader :regulator_wody

  attr_accessor :watki
end

class PanelSterowania

  def initialize(pralka)
    @programy = [Bawelna, Sportowe, Delikatne].map { |c| c.new(pralka)}
    @tryb_rubinowy   = Guzik.new
    @czy_napewno_nie = Guzik.new
    @pauza           = Guzik.new
    @wirowanie       = Guzik.new
    @ekstra_plukanie = Guzik.new
  end

  def program(ktory)
    @programy[ktory]
  end

  attr_reader :tryb_rubinowy
  attr_reader :czy_napewno_nie
  attr_reader :pauza
  attr_reader :wirowanie
  attr_reader :ekstra_plukanie
end

class Guzik < RubinowyStan
  state_machine :initial => :wylaczony do
    before_transition :do => :log
    after_failure :do => :fail
    event :przelacz do
      transition :wylaczony => :zalaczony, :zalaczony => :wylaczony
    end
  end
end

class Drzwi < RubinowyStan
  state_machine :initial => :zamkniete do
    before_transition :do => :log
    after_failure :do => :fail

    event :zamknij do
      transition :otwarte => :zamkniete
    end
    event :otworz do
      transition :zamkniete => :otwarte
    end
    event :zablokuj do
      transition :zamkniete => :zablokowane
    end
    event :odblokuj do
      transition :zablokowane => :zamkniete
    end
  end
end

class Beben
  def masa
    rand(6)
  end

  def initialize
    @poziom_wody = 0
  end

  attr_accessor :poziom_wody
end

class Dozowniki < RubinowyStan
  def initialize(pralka)
    @pralka = pralka
    super()
  end

  def dosc?
    rand = rand 10
    rand > 0
  end

  def dozuj(gram, callback)
    # @event = "dozuje #{gram} gram proszku"
    # ja = self
    @pralka.watki << Thread.new {
      log Event.new "dozuje #{gram} gram proszku <"
      sleep(3)
      log Event.new 'nasypane <'
      callback.fire_state_event(:nastepny)
    }
  end

  attr_reader :event
end

class RegulatorWody < RubinowyStan
  state_machine :initial => :wylaczony do
    before_transition :do => :log
    after_failure :do => :fail

    after_transition any => :zalaczony, :do => :otworz_zawor

    event :zalacz do
      transition :wylaczony => :zalaczony
    end
    event :wylacz do
      transition :zalaczony => :wylaczony
    end
  end

  def otworz_zawor

    log Event.new "obenie w pralce: #{@pralka.beben.poziom_wody} litrow wody <"
    until dosc?
      @pralka.beben.poziom_wody += 1
      sleep(0.1)
      putc '.'
    end
    puts ''
    log Event.new "obenie w pralce: #{@pralka.beben.poziom_wody} litrow wody <"

    fire_state_event :wylacz
  end

  def dosc?
    method(@czujki[@poziom_wody]).call
  end

  def czujka1
    @pralka.beben.poziom_wody > 35;
  end

  def czujka2
    @pralka.beben.poziom_wody > 65;
  end

  def czujka3
    @pralka.beben.poziom_wody > 95;
  end

  def initialize(pralka)
    super()
    @pralka = pralka
    @czujki = [:czujka1, :czujka2, :czujka3]
  end

  attr_writer :poziom_wody
end

pralka = Programator.new

pralka.panel.pauza.fire_state_event :przelacz
pralka.fire_state_event :zalacz
pralka.fire_state_event :zalacz
pralka.fire_state_event :start

pralka.watki.each { |w| w.join }

# p(/abc/ =~ "xabc")
#
# [[1,2,3],[4],[5,6]].each {
#   |c,d| puts("#{c}#{d}")
# }
#
# def oko
#   puts(1)
#   yield
#   puts(2)
#   yield
# end
#
#
#
# method(:oko).call{puts('kul!')}
#
# oko{puts('oko')}
#