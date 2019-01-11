class Field

  attr_reader :state

  def initialize value, table
    @state = :untouched
    @value = value
    @table = table
  end

  def mark
    @state = :marked unless @state == :picked
    @table
  end

  def pick
    @state = :picked unless @state == :marked
    @table
  end

  def unmark
    @state = :untouched if @state == :marked
    @table
  end

#  def untouched?
#    @state == :untouched
#  end
#
#  def picked?
#    @state == :picked
#  end
#
#  def marked?
#    @state == :marked
#  end

  [:untouched, :marked, :picked].each do |method|
    define_method(method.to_s + "?") do
      @state == method
    end
  end


  def inspect
    case @state
    when :untouched then " "
    when :marked then "M"
    when :picked then @value.to_s
    end
  end
end
