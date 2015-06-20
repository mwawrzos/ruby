require 'state_machine'

require 'utils'

class Program < RubinowyStan
  state_machine :initial => :oczekiwanie do
    after_transition :do => :log
    after_failure    :do => :fail

    after_transition :oczekiwanie => :odczyty     , :do => :odczytaj
    after_transition :odczyty     => :pranie1     , :do => :pranie1
    after_transition any          => :pranie2     , :do => :pranie2
    after_transition any          => :oczekiwanie , :do => :zakonczenie_

    event :nastepny do
      transition :oczekiwanie => :odczyty , :if => :warunki
      transition :odczyty => :pranie1
      transition :pranie1 => :pranie2     , :if => :tryb_rubinowy?
      transition [:pranie1, :pranie2] => :oczekiwanie
      # transition :zakonczenie => :oczekiwanie
    end
  end

  def initialize(pralka)
    @pralka = pralka
    @cykl   = Cykl.new pralka
    super()
    puts state
  end

  def warunki
    otwarte = @pralka.drzwi.otwarte?
    @logger.check("Drzwi #{otwarte ? 'otwarte' : 'zamkniete'}")
    if otwarte
      return false
    end
    dosc = @pralka.dozowniki.dosc?
    @logger.check("Detergentow jest #{dosc ? 'dosc' : 'za malo'}")
    unless dosc
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
    nastepny
  end
end

class Cykl < RubinowyStan
  state_machine :initial => :oczekiwanie do
    after_transition :do => :log
    after_failure    :do => :fail

    after_transition any => :dozowanie_p   , :do => :proszki
    after_transition any => :dozowanie_w   , :do => :woda
    after_transition any => :pranie        , :do => :pranie_
    after_transition any => :odpompowanie1 , :do => :odpompowanie
    after_transition any => :plukanie      , :do => :plukanie_
    after_transition any => :odwirowanie   , :do => :odwirowanie_
    after_transition any => :oczekiwanie   , :do => :koniec_

    event :nastepny do
      transition :oczekiwanie   => :dozowanie_p
      transition :dozowanie_p   => :dozowanie_w
      transition :dozowanie_w   => :pranie
      transition :pranie        => :odpompowanie1
      transition :odpompowanie1 => :plukanie
      transition :plukanie      => :odwirowanie   , :if => :odwirowanie?
      transition :plukanie      => :oczekiwanie
      transition :odwirowanie   => :oczekiwanie
    end

    event :pauza do
      transition :dozowanie_p => :dppauza  , :dppauza => :dozowanie_p,
                 :dozowanie_w => :dwpauza  , :dwpauza => :dozowanie_w,
                 :pranie => :prpauza       , :prpauza => :pranie,
                 :odpompowanie1 => :opauza , :opauza  => :odpompowanie1,
                 :plukanie => :plpauza     , :plpauza => :plukanie,
                 :odwirowanie => :odpauza  , :odpauza => :odwirowanie
    end
  end

  def proszki
    log Event.new 'dozowanie proszkow'
    @pralka.dozowniki.dozuj(@proszek, self)
  end
  def woda
    log Event.new 'dozowanie wody'
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
    log Event.new 'pranie'
    @pralka.kontroler_temperatury.zalacz
    @pralka.kontroler_silnika.krec
    sleep 10
    @pralka.kontroler_silnika.stop
    @pralka.kontroler_temperatury.wylacz
    nastepny
  end

  def odpompowanie
    log Event.new 'odpompowywanie'
    @pralka.watki << Thread.new {
      @pralka.wlacz_pompe_odsrodkowa
      nastepny
    }
  end

  def plukanie_
    log Event.new 'plukanie'
    @pralka.watki << Thread.new {
      @pralka.regulator_wody.zalacz
      @pralka.kontroler_silnika.krec
      sleep 12.34
      @pralka.kontroler_silnika.stop
      nastepny
    }
  end

  def odwirowanie_
    log Event.new 'wirowanie'
    @pralka.kontroler_silnika.wiruj
    sleep 6.78
    @pralka.kontroler_silnika.stop
    nastepny
  end

  def initialize(pralka)
    @pralka = pralka
    super()
  end

  def koniec_
    @callback.nastepny
  end


  def odwirowanie?
    wirowanie = @pralka.panel.wirowanie.wylaczony?
    @logger.check("Wirowanie #{wirowanie ? 'wlaczone' : 'wylaczane'}")
    wirowanie
  end

  attr_writer :proszek
  attr_writer :woda    # pralka ma 3 czujniki na r�ych wysoko�ciach; tu usatawiamy, kt�ry ma zatrzyma� dozowanie wody

  attr_writer :callback
end

class Bawelna < Program
  def pranie1
    @cykl.proszek = @masa * 15 #gram -> na opakowaniu proszku: 75 gr / 4,5 kg prania
    @cykl.woda    = 2
    @cykl.callback = self
    @cykl.nastepny
   end

  def pranie2
    @cykl.proszek = @masa * 15 * @pralka.filtry.zabrudzenie
    @cykl.nastepny
  end

  def zakonczenie_
    @pralka.drzwi.odblokuj
  end
end

class Sportowe < Program
  def pranie1
    @cykl.proszek = @masa * 1 #gram -> na opakowaniu proszku: 75 gr / 4,5 kg prania
    @cykl.woda    = 3
    @cykl.nastepny
  end

  def pranie2
    @cykl.proszek = @masa * 15 * @pralka.filtry.zabrudzenie
    @cykl.nastepny
  end

  def zakonczenie_
    @pralka.drzwi.odblokuj
  end
end

class Delikatne < Program
  def pranie1
    @cykl.proszek = @masa * 5
    @cykl.woda    = 2
    @cykl.nastepny
  end

  def pranie2
    @cykl.proszek = @masa * 15 * @pralka.filtry.zabrudzenie
    @cykl.nastepny
  end

  def zakonczenie_
    @pralka.drzwi.odblokuj
  end
end