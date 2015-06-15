Shoes.setup do
  gem 'state_machine'
end

require 'programator'
require 'ekstra'

# tutaj stworzona klasa, ale mozna ja importowac z innego pliku czyli np. te nasze
class NowaKlasa
  def listOfPrograms
    return ['Bawelna', 'Sport', 'Delikatne']
  end

  def listOfTemperature
    return ['90', '60', '40', '30']
  end

  def listTurnOver
    return ['1200', '800', '400']
  end

  def funkcjaStart
    return "To jest wnetrze klasy Nowa Klasa"
  end

  def funkcjaStop
    return "Funkcja Stop klasy Nowa Klasa"
  end

  def funkcjaPause
    return "Funkcja Pause klasy Nowa Klasa"
  end

  def timer
    a = 10
    b = 20
    return "#{a}:#{b}"
  end
end

Shoes.app(title: "RUBIN", width: 900, height: 700, resizable: false) do

  #
  # !!!
  # tutaj tworze obiekt nowej klasy (ew. tej zaimportowanej z innego pliku) i pozniej wywoluje jej metody
  @obj = NowaKlasa.new
  @ekstra_klasa = Ekstra.new
  @pralka = Programator.new

  background gainsboro

  @titleStack = flow :margin => 20 do
      image "pics/rubin.png"
      image "pics/logo2.png"
  end
  @panelStack = flow :margin => 20 do
    stack :width => 320 do
      flow do
        # background lightgrey..lightskyblue
        # border teal, :strokewidth => 2
        image "pics/play96.png"
        image "pics/pause72.png"
        image "pics/stop72.png"
        image "pics/power72.png"
      end
      flow do
        @startBtn = button "Start", :width => 100 do
          alert @obj.funkcjaStart
          alert @ekstra_klasa.okon
        end
        @pauseBtn = button "Pauza" do
          # alert @obj.funkcjaPause
          alert @pralka.state
        end
        @stopBtn  = button "Stop" do
          alert @obj.funkcjaStop
        end
        @offBtn   = button "Wylacz"
      end
      flow do
        image "pics/clock72.png"
        para "Czas do konca : "
        para strong @obj.timer
      end
      @stateStack = stack do
        flow do
          # background lightgrey..lightskyblue
          image "pics/speed72.png"
          para "State machine"
        end
        # border blue, :strokewidth => 2

      end
    end
    stack :width => -600 do
      border tomato, :strokewidth => 2
      image "pics/preferences72.png"
      para "Ustawienia"
      para "Tryb pracy"
      flow :margin => 10 do
        @obj.listOfPrograms.map! do |program|
          @p = radio :washingType
          inscription program
        end
        # radio :washingType
        # inscription "Bawelna"
        #
        # radio :washingType
        # inscription "Sportowe"
        #
        # radio :washingType
        # inscription "Delikatne"
      end
      para "Temperatura"
      flow :margin => 10 do
        @obj.listOfTemperature.map! do |temperature|
          @t = radio :temperature
          inscription temperature
        end

        # radio :temperature
        # inscription "90 C"
        #
        # radio :temperature
        # inscription "60 C"
        #
        # radio :temperature
        # inscription "40 C"
        #
        # radio :temperature
        # inscription "30 C"
      end
      para "Liczba obrotow"
      flow :margin => 10 do
       @obj.listTurnOver.map! do |turnover|
         @o = radio :turnover
         inscription turnover
       end
        # radio :turnover
        # inscription "1200"
        #
        # radio :turnover
        # inscription "800"
        #
        # radio :turnover
        # inscription "400"
      end

    end
    stack :width => -620 do
      border tomato, :strokewidth => 2
      image "pics/preferences.png"
      para "Dodatkowe ustawienia"

      flow {check; inscription "Inteligentne pranie (Sprawdzenie wskaznika brudu)"}
      flow {check; inscription "Pranie szybkie"}
      flow {check; inscription "Plukanie"}

    end
  end
end

