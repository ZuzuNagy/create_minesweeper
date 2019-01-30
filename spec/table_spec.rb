require './main'

RSpec.describe Table do
  let(:table) { Table.new(3,3,[[1,2],[2,0]]) }

  it "#mines_count_around" do
    expect(table.mines_count_around(0,0)).to eq(0)
    expect(table.mines_count_around(1,1)).to eq(2)
    expect(table.mines_count_around(2,2)).to eq(1)
  end

  describe '#each_coordinate_around' do
    context 'with block' do
      let(:coordinates) { [] }
      let(:b) { proc { |coordinate| coordinates << coordinate } }

      it 'calls the block with coordinates around x,y.' do
        table.each_coordinate_around(1,1, &b)
        expect(coordinates).to eq([[0,0],[0,1],[0,2],[1,0],[1,2],[2,0],[2,1],[2,2]])
        coordinates.clear
        table.each_coordinate_around(0,0, &b)
        expect(coordinates).to eq([[0,1],[1,0],[1,1]])
        coordinates.clear
        table.each_coordinate_around(2,2, &b)
        expect(coordinates).to eq([[1,1],[1,2],[2,1]])
      end
      it 'returns an array with coordinates around x,y.' do
        expect(table.each_coordinate_around(0,0, &b)).to be_an_instance_of(Array)
        expect(table.each_coordinate_around(0,0, &b)).to eq([[0,1],[1,0],[1,1]])
      end
    end
    context 'without block' do
      it 'returns an enumerator.' do
        expect(table.each_coordinate_around(1,1)).to be_an_instance_of(Enumerator)
      end
      it 'contains coordinates around x,y.' do
        expect(table.each_coordinate_around(0,0).to_a).to eq([[0,1],[1,0],[1,1]])
      end
    end
  end

  describe "#inspect" do
    it 'draws a table.' do
      drawn_table =
        "+---+---+---+\n" +
        "|   |   |   |\n" +
        "+---+---+---+\n" +
        "|   |   |   |\n" +
        "+---+---+---+\n" +
        "|   |   |   |\n" +
        "+---+---+---+"
      expect(table.inspect).to include drawn_table
    end
    it 'shows the number of unmarked mines.' do
      expect(table.inspect).to include("2\n")
      table.mark(1,2)
      expect(table.inspect).to include("1\n")
      table.mark(0,0)
      expect(table.inspect).to include("0\n")
    end
  end

  describe '#each_field' do
    let(:fields) { [[0,0],[0,1],[0,2],[1,0],[1,1],[1,2],[2,0],[2,1],[2,2]].map { |(x,y)| table[x,y] } }
    context 'block_given' do
      let(:fields_picked) { [] }
      let(:b) { proc { |field| fields_picked << field.picked? } }

      it 'calls the block for each field.' do
        table.each_field(&b)
        expect(fields_picked).to eq([false] * 9)
      end
      it 'returns fields of the table in an array.' do
        expect(table.each_field(&b)).to be_an_instance_of(Array)
        expect(table.each_field(&b)).to eq(fields)
      end
    end
    context 'without block' do
      it 'returns an enumerator.' do
        expect(table.each_field).to be_an_instance_of(Enumerator)
      end
      it 'contains fields.'do
        expect(table.each_field.to_a).to eq(fields)
      end
    end
  end

  describe '#grid' do
    it 'returns the @grid.' do
      expect(table.grid).to eq table.instance_variable_get :@grid
    end
  end

  describe "#[](x, y)" do
    it 'returns the field at x,y.' do
      expect(table[1,1]).to eq table.grid[1][1]
      expect(table[0,2]).to eq table.grid[0][2]
    end
  end

  describe '#pick' do
    it 'picks the field at x,y.' do
      expect { table.pick(1,1) }.to change(table[1,1], :picked?).to(true)
    end
    it 'picks the field at x,y and picks around x,y if x,y value is zero.' do
      fields = [[0,0],[0,1],[1,0],[1,1]].map { |(x,y)| table[x,y] }
      expect { table.pick(0,0) }.to change { fields.all? &:picked? }.to true
    end
    it 'calls pick_around again, if a new picked field is zero.' do
      table = Table.new(3,3, [[2,1]])
      fields = [[0,0],[0,1],[0,2],[1,0],[1,1],[1,2]].map { |(x,y)| table[x,y] }
      expect { table.pick(0,0) }.to change { fields.all? &:picked? }.to true
    end
    it 'does nothing if field at x,y is marked.' do
      table.mark(0,0)
      expect { table.pick(0,0) }.not_to change(table[0,0], :picked?)
    end
    it 'returns the field.' do
      expect(table.pick(1,1)).to eq table[1,1]
    end
  end

  describe '#mark' do
    it 'marks the field at x,y.' do
      expect { table.mark(1,2) }.to change(table[1,2], :marked?).to(true)
    end
    it 'returns the table.' do
      expect(table.mark(1,2)).to eq table[1,2]
    end
  end

  describe '#unmark' do
    it 'unmarks the field at x,y.' do
      table.mark(1,2)
      expect { table.unmark(1,2) }.to change(table[1,2], :untouched?).to(true)
    end
    it 'return the table.' do
      expect(table.unmark(1,2)).to eq table[1,2]
    end
  end

  describe '#marked_count_around' do
    it 'returns number of marked around.' do
      table.pick(0,0)
      table.pick(1,1)
      table.pick(2,2)
      table.mark(1,2)
      table.mark(2,0)
      expect(table.marked_count_around(0,0)).to eq(0)
      expect(table.marked_count_around(1,1)).to eq(2)
      expect(table.marked_count_around(2,2)).to eq(1)
    end
  end

  describe '.create' do
    it 'returns Table instance, calls generate_grid, chose some coordinates.' do
      table = Table.create(4,5,6)
      mine_coordinates = table.instance_variable_get(:@mine_coordinates)
      expect(mine_coordinates.size).to eq(6)
      expect(mine_coordinates).to be_an_instance_of(Array)
      all_inside = mine_coordinates.all? { |coor| coor[0] >= 0 && coor[1] >= 0 && coor[0] < 4 && coor[1] < 5 }
      expect(all_inside).to be true
    end
  end

  describe '.coordinates_for' do
    it 'returns coordinates for grid.' do
      expect(Table.coordinates_for(2,3)).to eq([[0,0],[0,1],[0,2],[1,0],[1,1],[1,2]])
      expect(Table.coordinates_for(3,2)).to eq([[0,0],[0,1],[1,0],[1,1],[2,0],[2,1]])
    end
  end

  describe '#unmarked_mines_count' do
    it 'returns a number of unmarked mines.' do
      expect(table.unmarked_mines_count).to eq(2)
      table.mark(1,2)
      expect(table.unmarked_mines_count).to eq(1)
      table.mark(0,0)
      expect(table.unmarked_mines_count).to eq(0)
    end
  end

  describe '#pick_around' do
    it 'changes x,y field around state, if x,y value eq marked fields around.' do
      table.mark(2,0)
      table.pick(1,0)
      untouched_fields_around = table.each_coordinate_around(1,0).inject([]) { |fields,(x,y)| fields << table[x,y] if table[x,y].untouched?; fields }
      expect { table.pick_around(1,0) }.to change { untouched_fields_around.all? &:picked?  }.to true
    end
  end
end
