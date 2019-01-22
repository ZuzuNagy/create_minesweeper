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

  def each_coordinate_around x, y
    directions = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
    coordinates_if_in_table = proc do |x,y,x_dir,y_dir, &block|
      x1 = x + x_dir
      y1 = y + y_dir
      block.([x1,y1]) if x1 >= 0 && y1 >= 0 && x1 < @rows && y1 < @cols
    end

    if block_given?
      directions.inject([]) do |coordinates, (x_dir, y_dir)|
        coordinates_if_in_table.call(x,y,x_dir,y_dir) do |coordinate|
          coordinates << coordinate
          yield(coordinate)
        end
        coordinates
      end
      #  directions.inject([]) do |coordinates, (x_dir,y_dir)|
      #    coordinate, in_table = coordinates_and_is_in_table(x,y,x_dir,y_dir)
      #    if in_table
      #      coordinates << coordinate
      #      yield(coordinate)
      #    end
      #    coordinates
      #  end
    else
      Enumerator.new do |yielder|
        directions.each do |(x_dir, y_dir)|
          coordinates_if_in_table.call(x,y,x_dir,y_dir) { |coordinate| yielder << coordinate }
        end
      end
      #    directions.each do |(x_dir,y_dir)|
      #      coordinate, in_table = coordinates_and_is_in_table(x,y,x_dir,y_dir)
      #      yielder << coordinate if in_table
      #    end
      #  end
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
    each_coordinate_around(x,y) do |coordinate|
      count += 1 if @mine_coordinates.include?(coordinate)
    end
    count
  end

  def marked_count_around x,y
    marked_count = 0
    each_coordinate_around(x,y) do |coordinate|
      marked_count += 1 if self[*coordinate].marked?
    end
    marked_count
  end

  def pick_around x,y
    if self[x,y].value&.<= marked_count_around(x,y)
      each_coordinate_around(x,y) { |coordinate| pick(*coordinate) }
    end
    self
  end

  def coordinates_and_is_in_table x, y, x_dir, y_dir
    x1 = x+x_dir
    y1 = y+y_dir
    [[x1,y1], x1 >= 0 && y1 >= 0 && x1 < @rows && y1 < @cols]
  end

  def self.create rows, cols, mines_count
    mine_coordinates = generate_grid(rows, cols).sample(mines_count)
      new(rows, cols, mine_coordinates)
  end

  def self.generate_grid rows, cols
    (0...rows).inject([]) do |coor, x|
      (0...cols).each do |y|
        coor << [x,y]
      end
      coor
    end
  end

end
