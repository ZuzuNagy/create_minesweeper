class Field

  def initialize value, table
    @state = 0
    @value = value
    @table = table
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
    case @state
    when 0 then " "
    when 1 then "M"
    when 2 then @value.to_s
    end
  end

  private

  def state= state
    @state = STATES.index(state)
  end

end
