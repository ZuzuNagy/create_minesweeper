require './main'

RSpec.describe Table do
  let(:table) { Table.new(3,3,[[1,2],[2,0]]) }

  it "#mines_count_arround" do
    expect(table.mines_count_arround(0,0)).to eq(0)
    expect(table.mines_count_arround(1,1)).to eq(2)
    expect(table.mines_count_arround(2,2)).to eq(1)
  end

  it '#fields_arround' do
    expect(table.fields_arround(1,1).size).to eq(8)
    expect(table.fields_arround(1,1)).to eq([[0,0],[0,1],[0,2],[1,0],[1,2],[2,0],[2,1],[2,2]])
    expect(table.fields_arround(0,0)).to eq([[0,1],[1,0],[1,1]])
    expect(table.fields_arround(2,2)).to eq([[1,1],[1,2],[2,1]])
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

#  describe 'each_field_arround' do
#    it 'returns an array with fields arround.' do
#      expect(table[1,1]).to eq table.each_field_arround do |(x,y)|
#        [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
#      end
#    end
#  end

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
end
