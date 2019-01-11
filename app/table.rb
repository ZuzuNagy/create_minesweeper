require 'terminal-table'
class Table

  def initialize rows, cols, mine_coordinates
    @rows = rows
    @cols = cols
    @mine_coordinates = mine_coordinates
    @grid = create_grid
  end

#  private

  def create_grid
    grid = Array.new(@rows) { Array.new(@cols) }
    @mine_coordinates.each do |(x,y)|
      grid[x][y] = 'x'
    end
    @rows.times do |x|
      @cols.times do |y|
        if grid[x][y].nil?
          grid[x][y] = mines_count_arround(x,y)
        end
      end
    end
    grid
  end

  def inspect
    #total = ""
    #between = "+-" * @cols + "+"
    #total += between
    #@grid.each do |row|
    #  pipe = "\n    " + "|"
    #  row.each do |field|
    #    pipe += field.to_s + "|"
    #  end
    #  total += (pipe += "\n    " + between)
    #end
    #total

    table = Terminal::Table.new do |t|
      @grid.each do |row|
        t << row
      end
      t.style = {:all_separators => true}
    end
    "\n#{table}"
  end

  def fields_arround x,y
    [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]].inject([]) do |select, (x_dir,y_dir)|
      x1 = x + x_dir
      y1 = y + y_dir
      select << [x1, y1] if x1 >= 0 && y1 >= 0 && x1 < @rows && y1 < @cols
      select
    end
  end

  def mines_count_arround x,y
    fields_arround(x,y).count do |coor|
      @mine_coordinates.include?(coor)
    end
  end

end
