require 'programator'
require 'ustawieniaGUI'
require 'lacznik'

Shoes.app(title: "RUBIN", width: 900, height: 720, resizable: false) do
  @obj = UstawieniaGUI.new
  @lacznik = Lacznik.new
  @programator = Programator.new (lambda { |str| @lacznik.niesamowitaFunkcja { str } })

  background gainsboro

  @titleStack = flow :margin => 20 do
    image "pics/rubin.png"
    image "pics/logo2.png"
  end
  @panelStack = flow :margin => 20 do
    stack :width => 320 do
      flow do
        # border teal, :strokewidth => 2
        image "pics/play96.png"
        image "pics/pause72.png"
        image "pics/stop72.png"
        image "pics/power72.png"
      end
      @stackButton = stack
      @lacznik.initButtonFlow(@stackButton)
      flow do
        image "pics/clock72.png"
        para "Czas do konca : "
        para strong @obj.timer
      end
      @stateStack = stack do
        flow do
          image "pics/speed72.png"
          para "State machine"
        end
        @parametersWindow = stack
        @lacznik.initParameters @parametersWindow

      end
    end
    stack :width => -320, :margin => 10 do
      flow do
        stack :width => 260 do
          border tomato, :strokewidth => 2, :curve => 8
          image "pics/preferences72.png"
          para "Ustawienia"
          para "Tryb pracy"
          flow :margin_left => 10  do
            @obj.listOfPrograms.map! do |program|
              @p = radio :washingType
              inscription program
            end
          end
          para "Temperatura"
          flow :margin_left => 10  do
            @obj.listOfTemperature.map! do |temperature|
              @t = radio :temperature
              inscription temperature
            end
          end
          para "Liczba obrotow"
          flow :margin_left => 10 do
            @obj.listTurnOver.map! do |turnover|
              @o = radio :turnover
              inscription turnover
            end
          end

        end
        stack :width => -280 do
          border tomato, :strokewidth => 2, :curve => 8
          image "pics/preferences.png"
          para "Dodatkowe ustawienia"

          @obj.listExtraOptions.map! do |option|
            @op = flow {
              check; inscription option
            }
          end
        end
      end
      stack :height => 210, :width => 510, :margin => 10, :margin_left => 0 do
        border steelblue, :strokewidth => 2, :curve => 8
        # para "Logi"
        @logWindow = stack
        @lacznik.initLogWindow @logWindow
        # height: "fixed", scroll: true do
        # end
        # @lacznik.initLogWindow @logWindow
      end
    end
  end
end