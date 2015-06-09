require 'state_machine'

class Rubin
  state_machine :initial => :wylaczona do
    event :zalacz do
      transition :wylaczona => :zalaczona
    end

    event :wylacz do
      transition :zalaczona => :wylaczona
    end
  end
end

pralka = Rubin.new
puts(pralka.state)
pralka.fire_state_event(:zalacz)
puts(pralka.state)