require 'programator'
class Lacznik
  @programator = Programator.new

  def initButtonFlow(buttonFlow)
    @buttonFlow = buttonFlow

    @buttonFlow.app do
      @flowS = flow do
        @startBtn = button "Start", :width => 100
        @pauseBtn = button "Pauza" do
          alert @programator.state
        end
        @stopBtn = button "Stop" do
          alert @obj.funkcjaStop
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
      flow :margin_left =>10 do
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
    @logStack = logStack
    @logStack.app do
      flow do
        image "pics/logi.png"
        para "Logi"
      end

      @logi = stack
      @logi.style(background: black, stroke: white, scroll: true, :height => "fix")
      @startBtn.click {
        @logi.append(inscription strong funkcja)
      }
    end
  end

end

def funkcja
  return "Slowo, Slowo logi tu logi tam!"
end