require 'singleton'

class Game
#  include Singleton

#  class NoTableError < StandardError; end

#  class << self
#
#    private :new
#
#    def instance
#      @instance ||= new
#    end

#  end

  attr_reader :table

  def initialize rows, cols, mines_count
    @table = Table.create(rows, cols, mines_count, self)
    @state = :running
  end

  def inspect
    table.inspect +
    "\n#{@message}"
  end



  [:mark, :unmark].each do |method|
    define_method(method) do |x,y|
#     raise NoTableError if @table.nil?
      table.send(method, x, y) if running?
      self
    end
  end

  def pick x,y
    if running?
      table.pick(x,y)
      if table[x,y].value == "x"
        lose
      elsif table.each_field.count(&:untouched?) == table.unmarked_mines_count
        win
      end
    end
    self
  end

  def pick_around x,y
    if table[x,y].value&. <= table.marked_count_around(x,y)
      table.each_coordinate_around(x,y) { |coordinate| pick(*coordinate) }
    else
      @message = "Not enough marked fields"
    end
    self
  end

  def win
    @state = :ended
    table.each_field &:mark
    @message = "Winner"
  end

  def lose
    @state = :ended
    table.each_field &:pick
    @message = "Loser"
  end

  [:running, :ended].each do |method|
     define_method "#{method}?" do
       @state == method
     end
   end

end
