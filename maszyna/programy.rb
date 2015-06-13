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
    after_failure :do => :fail
    event :nastepny do
      transition :oczekiwanie => :dozowanie
      transition :dozowanie   => :pranie
      transition :pranie      => :plukanie
      transition :plukanie    => :odwirowanie , :if => :odwirowanie?
      transition :plukanie    => :koniec
      transition :odwirowanie => :koniec
    end
  end

  def initialize(pralka)
    @pralka = pralka
    super()
  end

  def odwirowanie
    @pralka.panel.wirowanie?
  end
end

class Bawelna < Program
  def pranie1
    @cykl.fire_state_event :nastepny
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