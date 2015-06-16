
class UstawieniaGUI
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

  def listExtraOptions
    return [
        "Inteligentne pranie",
        "Pranie szybkie",
        "Plukanie"
    ]
  end
  def timer
    a = 10
    b = 20
    return "#{a}:#{b}"
  end
end