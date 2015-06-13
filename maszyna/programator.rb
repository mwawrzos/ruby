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
    @panel = PanelSterowania.new(self)
    @drzwi = Drzwi.new
    @beben = Beben.new
    @dozowniki = Dozowniki.new
    super()
  end

  def uruchom
    @panel.program(0).fire_state_event(:nastepny)
  end

  attr_reader :drzwi
  attr_reader :beben
  attr_reader :dozowniki
  attr_reader :panel
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
end

class Dozowniki
  def dosc?
    rand = rand 10
    rand > 2
  end
end

pralka = Programator.new
pralka.panel.pauza.fire_state_event :przelacz
pralka.fire_state_event :zalacz
pralka.fire_state_event :zalacz
pralka.fire_state_event :start


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