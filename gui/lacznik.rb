require 'programator'
class Lacznik
  # @programator = Programator.new (lambda { |str| niesamowitaFunkcja str })
  @temp = 0
  @turnover = "brak"

  def initButtonFlow(buttonFlow)
    @buttonFlow = buttonFlow
    @buttonFlow.app do
      @flowS = flow do
        @startBtn = button "Start", :width => 100 do
          # alert "Wybrano" << p.to_s
        end
        @pauseBtn = button "Pauza" do
          alert @programator.state
        end
        @stopBtn = button "Stop" do
          @programator.zalacz
          @programator.start
        end
        @offBtn = button "Wylacz" do
          ask_open_file
        end
      end
    end
  end

  def initParameters(parameterStack)
    @paramStack = parameterStack

    @paramStack.app do
      border cadetblue, :strokewidth => 2, :curve => 8, :height => 310

      flow :margin_left => 10 do
        inscription "Poziom wody"
        @poziom_wody = para strong "10l"
      end
      flow :margin_left => 10 do
        inscription "Proszek"
        @proszek = para strong "45g"
      end
      flow :margin_left => 10 do
        inscription "Plyn do plukania"
        @plyn = para strong "20ml"
      end
      flow :margin_left => 10 do
        inscription "Waga prania"
        @waga_prania = para strong "5kg"
      end
    end
  end

  def initLogWindow(logStack)
    listOfLists = [@programs, @turnoverlist, @templist, @options]
    @logStack = logStack
    @logStack.app do
      flow do
        image "pics/logi.png"
        para "Logi"
      end
      @startBtn.click {
        # jesli potrzeba mozna zmienic na zmienna obiektu - dodac "@"
        resultList = listOfLists.map{|list|
          l = list.map{ |(elemView, elem) |
            if(elemView.checked?)
             elem
            end
          }
          l.compact!
        }
        alert "Temperatura : " << resultList[2].to_s << " Obroty : " << resultList[1].to_s << " Type: " << resultList[0].to_s << "Dodatkowe: " << resultList[3].to_s

      }

        # niesamowitaFunkcja { funkcja }
        # @logi.append(inscription strong funkcja
      @logi = stack(scroll: true, :height => 130)
    end
  end

  def setTemp(temp)
    @templist = temp
  end

  def setProgram(programs)
    @programs = programs
  end

  def setTurnOver(turnover)
    @turnoverlist = turnover
  end

  def setExtraOpt(options)
    @options = options
  end

  def niesamowitaFunkcja
    @logStack.app do
      # alert yield
      @logi.append { inscription strong yield }
    end
  end
end

def funkcja
  return "Slowo, Slowo logi tu logi tam!"
end