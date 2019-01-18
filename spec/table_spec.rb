require './main'

RSpec.describe Table do
  let(:table) { Table.new(3,3,[[1,2],[2,0]]) }

  it "#mines_count_around" do
    expect(table.mines_count_around(0,0)).to eq(0)
    expect(table.mines_count_around(1,1)).to eq(2)
    expect(table.mines_count_around(2,2)).to eq(1)
  end

  it '#each_field_around' do
    coordinates = []
    b = proc { |coordinate| coordinates << coordinate }
      table.each_field_around(1,1, &b)
      expect(coordinates).to eq([[0,0],[0,1],[0,2],[1,0],[1,2],[2,0],[2,1],[2,2]])
    coordinates = []
      table.each_field_around(0,0, &b)
    expect(coordinates).to eq([[0,1],[1,0],[1,1]])
    coordinates = []
      table.each_field_around(2,2, &b)
    expect(coordinates).to eq([[1,1],[1,2],[2,1]])
  end

  xit "#create_grid" do
    expect(table.create_grid).to eq([[0,1,1],[1,2,'x'],['x',2,1]])
    expect(Table.new(2,4,[[1,1]]).create_grid).to eq([[1,1,1,0],[1,'x',1,0]])
  end

  it "#inspect" do
    inspected = "\n" +
                "+---+---+---+\n" +
                "|   |   |   |\n" +
                "+---+---+---+\n" +
                "|   |   |   |\n" +
                "+---+---+---+\n" +
                "|   |   |   |\n" +
                "+---+---+---+"
    expect(table.inspect).to eq(inspected)
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
    it 'returns the table.' do
      expect(table.pick(1,1)).to eq table
    end
  end

  describe '#mark' do
    it 'marks the field at x,y.' do
      expect { table.mark(1,2) }.to change(table[1,2], :marked?).to(true)
    end
    it 'returns the table.' do
      expect(table.mark(1,2)).to eq table
    end
  end

  describe '#unmark' do
    it 'unmarks the field at x,y.' do
      table.mark(1,2)
      expect { table.unmark(1,2) }.to change(table[1,2], :untouched?).to(true)
    end
    it 'return the table.' do
      expect(table.unmark(1,2)).to eq table
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

#  describe '#picked_mine' do
#    it 'change all untouched field state to picked.' do
#      all_untouched_field_in_the table
#      table.picked_mine(1,2)
#
#      expect(table.picked_mine(1,2)).to be
#    end
#  end

end
