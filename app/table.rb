require 'terminal-table'
require './main'

class Table

  attr_reader :grid

  def initialize rows, cols, mine_coordinates
    @rows = rows
    @cols = cols
    @mine_coordinates = mine_coordinates
    @grid = create_grid
  end

  def create_grid
    grid = Array.new(@rows) { Array.new(@cols) }
    @mine_coordinates.each do |(x,y)|
      grid[x][y] = Field.new('x', self)
    end
    @rows.times do |x|
      @cols.times do |y|
        if grid[x][y].nil?
          grid[x][y] = Field.new(mines_count_around(x,y), self)
        end
      end
    end
    grid
  end

  def [] x, y
    grid[x][y]
  end

  def inspect
    table = Terminal::Table.new do |t|
      @grid.each do |row|
        t << row.map(&:inspect)
      end
      t.style = {:all_separators => true}
    end
    "\n#{table}"
  end

  def each_field_around x, y, &block
    [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]].each do |(x_dir,y_dir)|
      x1 = x + x_dir
      y1 = y + y_dir
      block.call([x1, y1]) if x1 >= 0 && y1 >= 0 && x1 < @rows && y1 < @cols
    end
  end

  [:mark, :unmark].each do |method|
    define_method(method) do |x,y|
      send(:[], x , y).send(method)
      self
    end
  end

  def pick x,y
    if self[x,y].untouched?
      self[x,y].pick
      pick_around(x,y) if self[x,y].value == 0
      self
    end
  end

  def mines_count_around x,y
    count = 0
    each_field_around(x,y) do |coordinate|
      count += 1 if @mine_coordinates.include?(coordinate)
    end
    count
  end

  def marked_count_around x,y
    marked_count = 0
    each_field_around(x,y) do |coordinate|
      marked_count += 1 if self[*coordinate].marked?
    end
    marked_count
  end

  def pick_around x,y
    if self[x,y].value&.<= marked_count_around(x,y)
      each_field_around(x,y) { |coordinate| pick(*coordinate) }
    end
    self
  end

#  def all_untouched_field_in_the_table x,y
#
#  end
#
#  def picked_mine x,y
#    if self[x,y].picked? && self[x,y].value == 'x'
#
#    end
#  end
end
