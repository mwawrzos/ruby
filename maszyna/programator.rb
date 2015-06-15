require 'state_machine'

require '../maszyna/utils'
require '../maszyna/programy'

class Filtry
  def zabrudzenie
    rand(100)/100
  end
end

class Programator < RubinowyStan
  state_machine :initial => :wylaczony do
    before_transition :do => :log
    after_failure     :do => :fail
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
    @kontroler_silnika = KontrolerSilnika.new self
    @filtry = Filtry.new
    @wirowanie = Pokretelko.new { rand(800) + 400 }
    @temperatura = Pokretelko.new { rand(60) + 30 }
    @kontroler_temperatury = KontrolerTemperatury.new self

    @watki = []
    super()
  end

  def uruchom
    @panel.program(0).nastepny
  end

  def wlacz_pompe_odsrodkowa
    log Event.new "odpompowuje #{@beben.poziom_wody} litrow wody"
    while @beben.poziom_wody > 0
      @beben.poziom_wody -= 1
      putc '.'
      sleep 0.1
    end
    puts ''
    @beben.poziom_wody = 0
  end

  attr_reader :drzwi
  attr_reader :beben
  attr_reader :dozowniki
  attr_reader :panel
  attr_reader :regulator_wody
  attr_reader :kontroler_silnika
  attr_reader :filtry
  attr_reader :wirowanie
  attr_reader :temperatura
  attr_reader :kontroler_temperatury

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

class Pokretelko < RubinowyStan
  def wartosc
    @wartosc.call
  end

  def initialize
    @wartosc = lambda { yield }
    super()
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

    wylacz
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

class KontrolerSilnika < RubinowyStan
  state_machine :initial => :zatrzymany do
    before_transition :do => :log
    after_failure     :do => :fail

    after_transition any => :kreci, :do => :krecenie_
    after_transition :kreci => any, :do => :nie_krec
    after_transition any => :wiruje, :do => :wirowanie_

    event :krec do
      transition any => :kreci
    end
    event :wiruj do
      transition any => :wiruje
    end
    event :stop do
      transition any => :zatrzymany
    end
  end

  def krecenie_
    @watek = Thread.new {
      start_krecenie
      begin
        czekaj_krecenie
        sleep 3
        w_prawo_krecenie
        sleep 3
        czekaj_krecenie
        sleep 3
        w_lewo_krecenie
        sleep 3
      end until krecenie_zatrzymany?
    }
    @pralka.watki << @watek
  end

  def nie_krec
    @watek.kill
    stop_krecenie
  end

  def wirowanie_
    log(Event.new "wiruje #{@pralka.wirowanie} obr/min")
  end

  state_machine :krecenie, :initial => :zatrzymany, :namespace => 'krecenie' do
    before_transition :do => :log
    after_failure     :do => :fail

    # def log
    #   super.log Event.new krecenie_name
    # end

    event :w_lewo do
      transition :czeka => :kreci_w_lewo
    end
    event :w_prawo do
      transition :czeka => :kreci_w_prawo
    end
    event :czekaj do
      transition [:kreci_w_lewo, :kreci_w_prawo] => :czeka
    end
    event :stop do
      transition any => :zatrzymany
    end
    event :start do
      transition :zatrzymany => :kreci_w_lewo
    end
  end

  def initialize pralka
    super()
    @pralka = pralka
    p @pralka
  end
end
class KontrolerTemperatury < RubinowyStan
  state_machine :initial => :wylaczony do
    before_transition :do => :log
    after_failure     :do => :fail

    event :zalacz do
      transition :wylaczony => :zalaczony
    end
    event :wylacz do
      transition :zalaczony => :wylaczony
    end
  end

  def initialize pralka
    @pralka = pralka
    @temperatura = 20.0
    @temperatura_zadana = @pralka.temperatura.wartosc
    Thread.new {
      loop {
        until @temperatura < 20
          @temperatura -= rand 5
          sleep 0.7
        end
      }
    }.priority = -10

    Thread.new {
      loop {
        # puts zalaczony? , @temperatura , @temperatura_zadana
        if zalaczony?
          log Event.new "grzeje (obecnie #{@temperatura}*C"
          until @temperatura > @temperatura_zadana or wylaczony?
            @temperatura += 10
            putc '+'
            sleep 0.1
          end
          log Event.new 'ugrzane'
        end
        sleep 1
      }
    }

    super()
  end

  attr_writer :temperatura_zadana
end

# konroler = KontrolerSilnika.new pralka

# puts konroler.start_krecenie
# puts konroler.czekaj_krecenie
# puts konroler.krecenie_name
# puts konroler.krecenie_czeka?
# puts konroler.krecenie_zatrzymany?
# p(konroler)


pralka = Programator.new
pralka.panel.pauza.przelacz
pralka.panel.tryb_rubinowy.przelacz
pralka.zalacz
pralka.zalacz
pralka.start

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