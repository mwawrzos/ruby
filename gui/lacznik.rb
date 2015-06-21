require 'programator'
class Lacznik
  # @programator = Programator.new (lambda { |str| niesamowitaFunkcja str })
  @pauseState = false

  def initialize(programator)
    @programator = programator
  end

  def initButtonFlow(buttonFlow)
    @buttonFlow = buttonFlow
    @buttonFlow.app do
      @flowS = flow do
        @startBtn = button "Start", :width => 100
        @pauseBtn = button("Pauza"){
          @programator.panel.pauza.przelacz
        }

        @stopBtn = button "Stop" do
          @programator.zalacz
          @programator.start
        end
        @offBtn = button "Wylacz"
      end
    end
  end
  def initBtnImgFlow(flow)
    @btnImgFlow = flow
  end
  def initLockerFlow(lockerFlow, locker)
    @lockerFlow = lockerFlow
    @locker = locker
    # lockerFlow.app do
    #   button "klik" do
    #     @locker.remove()
    #     lockerFlow.append {
    #       @locker = image "pics/lockerLocked.png"
    #     }
    #   end
    #   button "unlock" do
    #     @locker.remove()
    #     lockerFlow.append {
    #       @locker = image "pics/lockerUnlocked.png"
    #     }
    #   end
    # end
  end

  def initParameters(parameterStack)
    @paramStack = parameterStack

    @paramStack.app do
      border cadetblue, :strokewidth => 2, :curve => 8, :height => 310

      flow :margin_left => 10 do
        inscription "Poziom wody"
        @poziom_wody = para strong "czekam..."
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
      flow :margin_left => 10 do
        @heaterPic = image "pics/off-btn.png"
        inscription "Stan : Grzalka"
      end
    end
  end

  def changeLockerState(boolVal)
    if boolVal
      @lockerFlow.app do
        @locker.remove()
        @lockerFlow.append {
          @locker = image "pics/lockerLocked.png"
        }
      end
    else
      @lockerFlow.app do
        @locker.remove()
        @lockerFlow.append {
          @locker = image "pics/lockerUnlocked.png"
        }

      end
    end
  end

  def changeState(boolVal, element)
    if boolVal
      @paramStack.app do
        element.remove
        @paramStack.append{
          element = image "pics/on-btn.png"
        }
      end
    else
      @paramStack.app do
        element.remove
        @paramStack.append{
          element = image "pics/off-btn.png"
        }
      end
    end
  end

  def changeHeaterState(boolVal)
    changeState(boolVal, @heaterPic)
  end
  def changePauseState(state)
    @btnImgFlow.app do
      images = @btnImgFlow.contents
      if(state)
        images[1].replace("pics/pause72-on.png")
      else
        images[1].replace("pics/pause72.png")
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
    @paramStack.app do
      @plyn.replace(strong(lvl.to_s))
    end
  end

  def changeWeightLvl(lvl)
    # @waga_prania = lvl.to_s
    @paramStack.app do
      @waga_prania.replace(strong(lvl.to_s))
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
        resultList = listOfLists.map { |list|
          l = list.map { |(elemView, elem)|
            if (elemView.checked?)
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
      @logi.append { inscription strong yield }
    end
  end

end

def funkcja
  return "Slowo, Slowo logi tu logi tam!"
end