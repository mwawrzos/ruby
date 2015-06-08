Shoes.app(title: "RUBIN", width: 900, height: 700, resizable: false) do
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
        @startBtn = button "Start", :width => 100
        @pauseBtn = button "Pauza"
        @stopBtn  = button "Stop"
        @offBtn   = button "Wylacz"
      end
      flow do
        image "pics/clock72.png"
        para "Czas do konca : "
        para strong "00:49"
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
        radio :washingType
        inscription "Bawelna"

        radio :washingType
        inscription "Sportowe"

        radio :washingType
        inscription "Delikatne"
      end
      para "Temperatura"
      flow :margin => 10 do
        radio :temperature
        inscription "90 C"

        radio :temperature
        inscription "60 C"

        radio :temperature
        inscription "40 C"

        radio :temperature
        inscription "30 C"
      end
      para "Liczba obrotow"
      flow :margin => 10 do
        radio :turnover
        inscription "1200"

        radio :turnover
        inscription "800"

        radio :turnover
        inscription "400"
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

