require './main'

RSpec.describe Game do
  subject { Game.new(3,3,2) }

  describe '#mark' do
    it 'marks the field at x,y of table.' do
      subject.mark(0,0)
      expect(subject.table[0,0]).to be_marked
    end
    it 'returns the game.' do
      expect(subject.mark(0,0)).to eq subject
    end
  end

  describe '#pick' do
    it 'picks the field at x,y of table.' do
      subject.pick(0,1)
      expect(subject.table[0,1]).to be_picked
    end
    it 'calls lose if picked field is mine.' do
      table = Table.new(2,2,[[0,0]])
      subject.instance_variable_set :@table, table
      expect(subject).to receive(:lose)
      subject.pick(0,0)
    end
    it 'calls win if every non-mine field is picked.' do
      table = Table.new(1,2,[[0,0]])
      subject.instance_variable_set :@table, table
      expect(subject).to receive(:win)
      subject.pick(0,1)
    end
    it 'returns the game.' do
      expect(subject.pick(0,1)).to eq subject
    end
  end

  describe '#unmark' do
    it 'unmarks the field at x,y of table.' do
      subject.unmark(0,0)
      expect(subject.table[0,0]).to be_untouched
    end
    it 'returns the game.' do
      expect(subject.unmark(0,1)).to eq subject
    end
  end

  describe '#initialize' do
    xit 'stores new table.' do
      subject.initialize(2,3,4)
      expect(subject.table).to be_an_instance_of(Table)
      expect(subject.table.initialize).to eq "4\n" +
                                          "+---+---+---+\n" +
                                          "|   |   |   |\n" +
                                          "+---+---+---+\n" +
                                          "|   |   |   |\n" +
                                          "+---+---+---+"
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
      expect(subject.inspect).to include drawn_table
    end
    it 'shows the number of unmarked mines.' do
      expect(subject.inspect).to include("2\n")
      subject.mark(1,2)
      expect(subject.inspect).to include("1\n")
      subject.mark(0,0)
      expect(subject.inspect).to include("0\n")
    end
    it 'shows lose.' do
      table = Table.new(1,2,[[0,1]])
      subject.instance_variable_set :@table, table
      subject.pick(0,1)
      expect(subject.inspect).to eq("1\n" +
                                    "+---+---+\n" +
                                    "| 1 | x |\n" +
                                    "+---+---+\n" +
                                    "Loser")
    end
    it 'shows win.' do
      table = Table.new(1,2,[[0,1]])
      subject.instance_variable_set :@table, table
      subject.pick(0,0)
      expect(subject.inspect).to eq("0\n" +
                                    "+---+---+\n" +
                                    "| 1 | M |\n" +
                                    "+---+---+\n" +
                                    "Winner")
    end
  end

  describe '#table' do
    it 'is an attr_reader.' do
      table = Table.new(1,2,[])
      expect { subject.instance_variable_set(:@table, table) }.to change(subject, :table).to table
    end
  end

  describe '#lose' do
    it 'writes lose.' do
      expect(subject.lose).to eq("Loser")
    end
    it 'changes the untouched fields to picked.' do
      untouched_fields = subject.table.each_field.select &:untouched?
      expect { subject.lose }.to change { untouched_fields.all? &:picked? }.to(true)
    end
    it 'shows ! for marked fields that are not mines.' do
      table = Table.new(1,2,[[0,1]])
      subject.instance_variable_set :@table, table
      subject.mark(0,0)
      subject.pick(0,1)
      p subject
      expect(subject.inspect).to eq("0\n" +
                                    "+---+---+\n" +
                                    "| ! | x |\n" +
                                    "+---+---+\n" +
                                    "Loser")
    end
    it 'does not go to win.' do
      should_not receive(:win)
      table = Table.new(1,2,[[0,1]])
      subject.instance_variable_set :@table, table
      subject.mark(0,0)
      subject.pick(0,1)
    end
  end

  describe '#win' do
    it 'writes win.' do
      expect(subject.win).to eq("Winner")
    end
    it 'changes mines field if it is not marked' do
      mines_fields = subject.table.each_field.select &:untouched?
      expect { subject.win }.to change { mines_fields.all? &:marked? }.to(true)
    end
  end

  describe '#pick_around' do
    let(:table) { Table.new(2,2,[[1,1]]) }
    it 'changes x,y field around state, if x,y value eq marked fields around.' do
      subject.instance_variable_set :@table, table
      subject.mark(1,1)
      subject.pick(1,0)
      untouched_fields_around = subject.table.each_coordinate_around(1,0).with_object([]) { |(x,y), fields| fields << table[x,y] if table[x,y].untouched? }
      expect { subject.pick_around(1,0) }.to change { untouched_fields_around.all? &:picked? }.to true
    end
    it 'writes Not enough marked fields.' do
      subject.instance_variable_set :@table, table
      subject.pick(1,0)
      subject.pick_around(1,0)
      expect(subject.inspect).to eq("1\n" +
                                    "+---+---+\n" +
                                    "|   |   |\n" +
                                    "+---+---+\n" +
                                    "| 1 |   |\n" +
                                    "+---+---+\n" +
                                    "Not enough marked fields")
    end
    it 'calls win, if no more untouched non-mine fields.' do
      subject.instance_variable_set :@table, table
      subject.mark(1,1)
      subject.pick(1,0)
      subject.pick_around(1,0)
      expect(subject.inspect).to eq("0\n" +
                                    "+---+---+\n" +
                                    "| 1 | 1 |\n" +
                                    "+---+---+\n" +
                                    "| 1 | M |\n" +
                                    "+---+---+\n" +
                                    "Winner")
    end
    it 'calls lose if x,y around has unmarked mines.' do
      subject.instance_variable_set :@table, table
      subject.mark(1,0)
      subject.pick(0,0)
      subject.pick_around(0,0)
      expect(subject.inspect).to eq("0\n" +
                                    "+---+---+\n" +
                                    "| 1 | 1 |\n" +
                                    "+---+---+\n" +
                                    "| M | x |\n" +
                                    "+---+---+\n" +
                                    "Loser")
    end
    it 'returns the game.' do
      expect(subject.pick_around(0,1)).to eq subject
    end
  end
end
