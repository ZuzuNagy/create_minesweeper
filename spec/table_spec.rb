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

  xit "#inspect" do
    inspected = "\n" +
                "+---+---+---+\n" +
                "| 0 | 1 | 1 |\n" +
                "+---+---+---+\n" +
                "| 1 | 2 | x |\n" +
                "+---+---+---+\n" +
                "| x | 2 | 1 |\n" +
                "+---+---+---+"
    expect(table.inspect).to eq(inspected)
  end
end
