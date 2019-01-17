require './main'

RSpec.describe Table do
  let(:table) { Table.new(3,3,[[1,2],[2,0]]) }

  it "#mines_count_around" do
    expect(table.mines_count_around(0,0)).to eq(0)
    expect(table.mines_count_around(1,1)).to eq(2)
    expect(table.mines_count_around(2,2)).to eq(1)
  end

  xit '#each_field_around' do
    expect(table.each_field_around(1,1).size).to eq(8)
    expect(table.each_field_around(1,1)).to eq([[0,0],[0,1],[0,2],[1,0],[1,2],[2,0],[2,1],[2,2]])
    expect(table.each_field_around(0,0)).to eq([[0,1],[1,0],[1,1]])
    expect(table.each_field_around(2,2)).to eq([[1,1],[1,2],[2,1]])
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

  describe '#pick_around' do
    before :each do
      table.pick(0,0)
      table.pick(1,1)
      table.pick(2,2)
      table.mark(1,2)
    end

    it 'changes the x,y field around state to :picked if enough is marked.' do
      untouched_fields_around = []
      table.each_field_around(0,0) { |x,y| untouched_fields_around << table[x,y] if table[x,y].untouched? }
      table.pick_around(0,0)
      expect(untouched_fields_around).to all be_picked

      untouched_fields_around = []
      table.each_field_around(2,2) { |x,y| untouched_fields_around << table[x,y] if table[x,y].untouched? }
      table.pick_around(2,2)
      expect(untouched_fields_around).to all be_picked
    end

    it 'does nothing if not enough field is marked around x, y.' do
      untouched_fields_around = []
      table.each_field_around(1,1) { |x,y| untouched_fields_around << table[x,y] if table[x,y].untouched? }
      table.pick_around(1,1)
      expect(untouched_fields_around).to all be_untouched
    end

    it 'does nothing if field at x, y is not picked.' do
      untouched_fields_around = []
      table.each_field_around(0,2) { |x,y| untouched_fields_around << table[x,y] if table[x,y].untouched? }
      table.pick_around(0,2)
      expect(untouched_fields_around).to all be_untouched
    end
  end

end
