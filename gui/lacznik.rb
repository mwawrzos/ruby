require 'programator'
class Lacznik
  # @programator = Programator.new (lambda { |str| niesamowitaFunkcja str })


  def initialize(programator)
    @programator = programator
  end
  def initButtonFlow(buttonFlow)
    @buttonFlow = buttonFlow
    @buttonFlow.app do
      @flowS = flow do
        @startBtn = button "Start", :width => 100 do
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
        @poziom_wody = para strong"czekam..."
      end
      flow :margin_left => 10 do
        inscription "Proszek"
        @proszek = para strong "czekam..."
      end
      flow :margin_left => 10 do
        inscription "Plyn do plukania"
        @plyn = para strong "czekam..."
      end
      flow :margin_left => 10 do
        inscription "Waga prania"
        @waga_prania = para strong "czekam..."
      end
    end
  end

  def changeWaterLvl(lvl)
    @paramStack.app do
      # @poziom_wody.text = lvl.to_s
      @poziom_wody.replace(strong(lvl.to_s))
    end
  end

  def changeDetergentLvl(lvl)
    @paramStack.app do
      # @proszek = lvl.to_s
      @proszek.replace(strong(lvl.to_s))
    end
  end

  def changeSoftenerLvl(lvl)
    # @plyn = lvl.to_s
    @plyn.replace(strong(lvl.to_s))
  end

  def changeWeightLvl(lvl)
    # @waga_prania = lvl.to_s
    @waga.replace(strong(lvl.to_s))
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