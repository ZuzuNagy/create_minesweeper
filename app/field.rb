class Field
  include TextColor

  def initialize value, game
    send(:state=, :untouched)
    @value = value
    @game = game
  end

  def value
    @value if picked?
  end

  def mark
    send(:state=, :marked) unless picked?
  end

  def pick
    send(:state=, :picked) unless marked?
  end

  def unmark
    send(:state=, :untouched) if marked?
  end

  STATES = [:untouched, :marked, :picked]

  STATES.each_with_index do |method, index|
    define_method "#{method}?" do
      @state == index
    end
  end

  def state
    STATES[@state]
  end

  def inspect
    if @game.running?
      case @state
      when 0 then " "
      when 1 then color "M"
      when 2 then color @value.to_s.upcase
      end
    else
      case @state
      when 0 then color @value.to_s
      when 1 then color @value == 'x' ? "M" : "!"
      when 2 then color @value.to_s.upcase
      end
    end
  end

  private

  def state= state
    @state = STATES.index(state)
  end

end
