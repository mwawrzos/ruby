require 'programator'
require 'ustawieniaGUI'
require 'lacznik'

Shoes.app(title: "RUBIN", width: 900, height: 720, resizable: false) do
  @obj = UstawieniaGUI.new
  @lacznik = Lacznik.new(@programator)
  @programator = Programator.new @lacznik
  $log_handler = lambda { |str| @lacznik.niesamowitaFunkcja { str } }

  background gainsboro

  @titleStack = flow :margin => 20 do
    image "pics/rubin.png"
    image "pics/logo2.png"
  end
  @panelStack = flow :margin => 20 do
    stack :width => 320 do
      @btnImgFlow = flow do
        # border teal, :strokewidth => 2
        image "pics/play96.png"
        image "pics/pause72.png"
        image "pics/stop72.png"
        image "pics/power72.png"
      end
      @stackButton = stack
      @lacznik.initButtonFlow(@stackButton)
      @lockerFlow = flow do
        image "pics/clock72.png"
        para "Czas do konca : "
        para strong @obj.timer
        @locker = image "pics/lockerUnlocked.png"
      end
      @lacznik.initLockerFlow(@lockerFlow, @locker)

      @stateStack = stack do
        flow do
          image "pics/speed72.png"
          para "Maszyna stanowa"
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
          @programFlow = flow :margin_left => 10  do
            @listOfPrograms = @obj.listOfPrograms.map! do |program|
              p = radio :washingType
              inscription program
              [p, program]
            end
            @lacznik.setProgram(@listOfPrograms)
          end
          para "Temperatura"
          flow :margin_left => 10  do
            @listOfTemperature = @obj.listOfTemperature.map! do |temperature|
              t = radio :temperature
              inscription temperature
              [t, temperature]
            end
            @lacznik.setTemp(@listOfTemperature)
          end
          para "Liczba obrotow"
          flow :margin_left => 10 do
           @listOfTurnover = @obj.listTurnOver.map! do |turnover|
              o = radio :turnover
              inscription turnover
              [o, turnover]
            end
            @lacznik.setTurnOver(@listOfTurnover)
          end
        end
        stack :width => -280 do
          border tomato, :strokewidth => 2, :curve => 8
          image "pics/preferences.png"
          para "Dodatkowe ustawienia"

          @listExtraOpt = @obj.listExtraOptions.map do |option|
            op = flow {
              @c = check; inscription option
            }
            [@c, option]
          end
          @lacznik.setExtraOpt(@listExtraOpt)
        end
      end
      stack :height => 210, :width => 510, :margin => 10, :margin_left => 0 do
        border steelblue, :strokewidth => 2, :curve => 8
        @logWindow = stack
        @lacznik.initLogWindow @logWindow
      end
    end
  end
end
