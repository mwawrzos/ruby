require 'state_machine'

require '../maszyna/utils'

class Program < RubinowyStan
  state_machine :initial => :oczekiwanie do
    after_transition :do => :log
    after_failure    :do => :fail

    after_transition :oczekiwanie => :odczyty     , :do => :odczytaj
    after_transition :odczyty     => :pranie1     , :do => :pranie1
    after_transition any          => :pranie2     , :do => :pranie2
    after_transition any          => :zakonczenie , :do => :zakonczenie

    event :nastepny do
      transition :oczekiwanie => :odczyty , :if => :warunki
      transition :odczyty => :pranie1
      transition :pranie1 => :pranie2     , :if => :tryb_rubinowy?
      transition :pranie1 => :zakonczenie
      transition :pranie2 => :zakonczenie
    end
  end

  def initialize(pralka)
    @pralka = pralka
    @cykl   = Cykl.new pralka
    super()
  end

  def warunki
    otwarte = @pralka.drzwi.otwarte?
    @logger.check("Drzwi #{otwarte ? 'otwarte' : 'zamkniete'}")
    if otwarte
      return false
    end
    dosc = @pralka.dozowniki.dosc?
    @logger.check("Detergentow jest #{dosc ? 'dosc' : 'za malo'}")
    if !dosc
      return false
    end

    @pralka.drzwi.zablokuj
    true
  end

  def tryb_rubinowy?
    @pralka.panel.tryb_rubinowy.zalaczony?
  end

  def odczytaj
    @masa = @pralka.beben.masa
    fire_state_event(:nastepny)
  end
end

class Cykl < RubinowyStan
  state_machine :initial => :oczekiwanie do
    after_transition :do => :log
    after_failure    :do => :fail

    after_transition any => :dozowanie_p , :do => :proszki
    after_transition any => :dozowanie_w , :do => :woda
    after_transition any => :pranie      , :do => :pranie_
    after_transition any => :plukanie    , :do => :plukanie_
    after_transition any => :odwirowanie , :do => :odwirowanie_
    after_transition any => :koniec      , :do => :koniec_

    event :nastepny do
      transition :oczekiwanie => :dozowanie_p
      transition :dozowanie_p => :dozowanie_w
      transition :dozowanie_w => :pranie
      transition :pranie      => :plukanie
      transition :plukanie    => :odwirowanie , :if => :odwirowanie?
      transition :plukanie    => :koniec
      transition :odwirowanie => :koniec
    end
  end

  def proszki
    @pralka.dozowniki.dozuj(@proszek, self)
  end
  def woda
    regulator_wody = @pralka.regulator_wody
    regulator_wody.poziom_wody = 1

    @pralka.watki << Thread.new {
      wilgoc = 1
      until regulator_wody.dosc?
        regulator_wody.zalacz
        @pralka.kontroler_silnika.krec
        sleep 5.5
        @pralka.kontroler_silnika.stop
        if rand(10) > wilgoc
          wessane = (1 - wilgoc) * rand(@proszek / 5)
          log Event.new "pranie wsyslo #{wessane} litrow wody"
          @pralka.beben.poziom_wody -= wessane
          ++wilgoc
        end
      end
      nastepny
    }
  end

  def pranie_
    @pralka.kontroler_silnika.krec
    sleep 10
    @pralka.kontroler_silnika.stop
    nastepny
  end

  def plukanie_
    @pralka.beben.poziom_wody = 0
    @pralka.regulator_wody.zalacz
  end

  def initialize(pralka)
    @pralka = pralka
    super()
  end

  def odwirowanie?
    wirowanie = @pralka.panel.wirowanie?
    @logger.check("Wirowanie #{wirowanie ? 'wlaczone' : 'wylaczane'}")
    wirowanie
  end

  attr_writer :proszek
  attr_writer :woda    # pralka ma 3 czujniki na ró¿ych wysokoœciach; tu usatawiamy, który ma zatrzymaæ dozowanie wody
end

class Bawelna < Program
  def pranie1
    @cykl.proszek = @masa * 15 #gram -> na opakowaniu proszku: 75 gr / 4,5 kg prania
    @cykl.woda    = 2
    @cykl.nastepny
  end
end

class Sportowe < Program
  def warunki
  end
end

class Delikatne < Program
  def warunki

  end
end