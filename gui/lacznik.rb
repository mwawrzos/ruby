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
        @pauseBtn = button("Pauza") {
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
  end

  def initParameters(parameterStack)
    @paramStack = parameterStack

    @paramStack.app do
      border cadetblue, :strokewidth => 2, :curve => 8, :height => 380

      flow :margin_left => 10 do
        inscription strong "Aktualny stan: "
        @aktualny_stan = para strong "czekam..."
      end
      flow :margin_left => 10 do
        inscription "Proszek stan : "
        @proszek = para strong "czekam..."
      end
      flow :margin_left => 10 do
        inscription "Plyn do plukania stan : "
        @plyn = para strong "czekam..."
      end
      flow :margin_left => 10 do
        inscription "Poziom wody : "
        @poziom_wody = para strong "czekam..."
      end
      flow :margin_left => 10 do
        inscription "Waga prania : "
        @waga_prania = para strong "czekam..."
      end
      flow :margin_left => 10 do
        inscription "Temperatura : "
        @aktualna_temp = para strong "czekam..."
      end
      flow :margin_left => 10 do
        inscription "Obroty : "
        @obroty = para strong "czekam..."
      end
      @heaterFlow = flow :margin_left => 10 do
        @heaterPic = image "pics/off-btn.png"
        inscription "Stan : Grzalka"
      end
      @tempOptFlow = flow :margin_left => 10 do
        @tempPic = image "pics/off-btn.png"
        inscription "Stan : Zawory wody"
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

  def changeHeaterState(boolVal)
    if boolVal
      @paramStack.app do
        @heaterPic.remove()
        @heaterFlow.prepend {
          @heaterPic = image "pics/on-btn.png"
        }
      end
    else
      @paramStack.app do
        @heaterPic.remove()
        @heaterFlow.prepend {
          @heaterPic = image "pics/off-btn.png"
        }
      end
    end
  end

  def changeWaterValveState(boolVal)
    if boolVal
      @paramStack.app do
        @tempPic.remove()
        @tempOptFlow.prepend {
          @tempPic = image "pics/on-btn.png"
        }
      end
    else
      @paramStack.app do
        @tempPic.remove()
        @tempOptFlow.prepend {
          @tempPic = image "pics/off-btn.png"
        }
      end
    end
  end

  def changePauseState(state)
    @btnImgFlow.app do
      images = @btnImgFlow.contents
      if (state)
        images[1].replace("pics/pause72-on.png")
      else
        images[1].replace("pics/pause72.png")
      end
    end
  end

  def changeTempLvl(lvl)
    @paramStack.app do
      @aktualna_temp.replace(strong(lvl.to_s << " C"))
    end
  end

  def changeTurnoverLvl(lvl)
    @paramStack.app do
      @obroty.replace(strong(lvl.to_s << " obr/min"))
    end
  end

  def changeWaterLvl(lvl)
    @paramStack.app do
      @poziom_wody.replace(strong(lvl.to_s << " l"))
    end
  end

  def changeDetergentLvl(lvl)
    @paramStack.app do
      @proszek.replace(strong(lvl.to_s << " g"))
    end
  end

  def changeSoftenerLvl(lvl)
    @paramStack.app do
      @plyn.replace(strong(lvl.to_s << " ml"))
    end
  end

  def changeWeightLvl(lvl)
    # @waga_prania = lvl.to_s
    @paramStack.app do
      @waga_prania.replace(strong(lvl.to_s << " kg"))
    end
  end

  def changeWashingState(state)
    @paramStack.app do
      @aktualny_stan.replace(strong(state.to_s))
    end
  end
  def initLogWindow(logStack)
    listOfLists = [@programs, @turnoverlist, @templist, @options]
    @logStack = logStack
    me = self
    @logStack.app do
      flow do
        image "pics/logi.png"
        para "Logi"
      end
      @startBtn.click {
        # jesli potrzeba mozna zmienic na zmienna obiektu - dodac "@"
        @resultList = me.resultList = listOfLists.map { |list|
          l = list.map { |(elemView, elem)|
            if (elemView.checked?)
              elem
            end
          }
          l.compact!
        }
        alert "Temperatura : " << @resultList[2].to_s << " Obroty : " << @resultList[1].to_s << " Type: " << @resultList[0].to_s << "Dodatkowe: " << @resultList[3].to_s
      }

      # niesamowitaFunkcja { funkcja }
      # @logi.append(inscription strong funkcja
      @logi = stack(scroll: true, :height => 190)
    end
  end

  def getTemperature
    return @resultList[2].flatten
  end

  def getTurnover
    return @resultList[1].flatten
  end

  def getProgram
    return @resultList[0].flatten
  end

  def getExtaOptions
    return @resultList[3]
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

  attr_writer :resultList
end

def funkcja
  return "Slowo, Slowo logi tu logi tam!"
end