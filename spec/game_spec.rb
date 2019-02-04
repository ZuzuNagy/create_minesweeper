require './main'

RSpec.describe Game do
  subject { Game.new(3,3,2) }

  describe '#mark' do
    it 'marks the field at x,y of table.' do
      subject.mark(0,0)
      expect(subject.table[0,0]).to be_marked
    end
    it 'empties message.' do
      subject.pick_around(0,0)
      expect(subject.inspect).to include "Not enough marked fields"
      subject.mark(0,1)
      expect(subject.inspect).not_to include "Not enough marked fields"
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
      table = Table.new(2,2,[[0,0]],subject)
      subject.instance_variable_set :@table, table
      expect(subject).to receive(:lose)
      subject.pick(0,0)
    end
    it 'calls win if every non-mine field is picked.' do
      table = Table.new(1,2,[[0,0]], subject)
      subject.instance_variable_set :@table, table
      expect(subject).to receive(:win)
      subject.pick(0,1)
    end
    it 'empties message.' do
      table = Table.new(3,3, [[1,1]], subject)
      subject.instance_variable_set :@table, table
      subject.pick_around(0,0)
      expect(subject.inspect).to include "Not enough marked fields"
      subject.pick(0,1)
      expect(subject.inspect).not_to include "Not enough marked fields"
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
    it 'empties message.' do
      subject.pick_around(0,0)
      expect(subject.inspect).to include "Not enough marked fields"
      subject.unmark(0,1)
      expect(subject.inspect).not_to include "Not enough marked fields"
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
      table = Table.new(1,2,[[0,1]], subject)
      subject.instance_variable_set :@table, table
      subject.pick(0,1)
      expect(subject.inspect).to eq("1\n" +
                                    "+---+---+\n" +
                                    "| 1 | X |\n" +
                                    "+---+---+\n" +
                                    "Loser")
    end
    it 'shows win.' do
      table = Table.new(1,2,[[0,1]],subject)
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
      table = Table.new(1,2,[],subject)
      expect { subject.instance_variable_set(:@table, table) }.to change(subject, :table).to table
    end
  end

  describe '#lose (private)' do
    it 'writes lose.' do
      expect(subject.send(:lose)).to eq("Loser")
    end
    it 'changes the untouched fields to picked.' do
      untouched_fields = subject.table.each_field.select &:untouched?
      expect { subject.send(:lose) }.to change { untouched_fields.all? &:picked? }.to(true)
    end
    it 'shows ! for marked fields that are not mines.' do
      table = Table.new(1,2,[[0,1]], subject)
      subject.instance_variable_set :@table, table
      subject.mark(0,0)
      subject.pick(0,1)
      expect(subject.inspect).to eq("0\n" +
                                    "+---+---+\n" +
                                    "| ! | X |\n" +
                                    "+---+---+\n" +
                                    "Loser")
    end
    it 'does not go to win.' do
      should_not receive(:win)
      table = Table.new(1,2,[[0,1]], subject)
      subject.instance_variable_set :@table, table
      subject.mark(0,0)
      subject.pick(0,1)
    end
  end

  describe '#win (private)' do
    it 'writes win.' do
      expect(subject.send(:win)).to eq("Winner")
    end
    it 'changes mines field if it is not marked' do
      mines_fields = subject.table.each_field.select &:untouched?
      expect { subject.send(:win) }.to change { mines_fields.all? &:marked? }.to(true)
    end
  end

  describe '#pick_around' do
    let(:table) { Table.new(2,2,[[1,1]],subject) }
    it 'changes x,y field around state, if x,y value eq marked fields around.' do
      subject.instance_variable_set :@table, table
      subject.mark(1,1)
      subject.pick(1,0)
      untouched_fields_around = subject.table.each_coordinate_around(1,0).with_object([]) { |(x,y), fields| fields << table[x,y] if table[x,y].untouched? }
      expect { subject.pick_around(1,0) }.to change { untouched_fields_around.all? &:picked? }.to true
    end
    it 'empties message.' do
      table = Table.new(3,3, [[1,0],[2,2]], subject)
      subject.instance_variable_set :@table, table
      subject.pick(0,0)
      subject.pick(1,1)
      subject.mark(1,0)
      subject.pick_around(1,1)
      expect(subject.inspect).to include "Not enough marked fields"
      subject.pick_around(0,0)
      expect(subject.inspect).not_to include "Not enough marked fields"
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
                                    "| ! | X |\n" +
                                    "+---+---+\n" +
                                    "Loser")
    end

    it 'returns the game.' do
      expect(subject.pick_around(0,1)).to eq subject
    end
  end

  describe "#running?" do
    it 'returns true if sate is running.' do
      expect(subject).to be_running
    end
    it 'returns false if the player win the game.' do
      subject.send(:win)
      expect(subject.running?).to be false
    end
    it 'reutrns false if the player lose the game.' do
      subject.send(:lose)
      expect(subject.running?).to be false
    end
  end

  describe '#ended?' do
    it 'returns true if the player win the game.' do
      subject.send(:win)
      expect(subject.ended?).to be true
    end
    it 'reutrns true if the player lose the game.' do
      subject.send(:lose)
      expect(subject.ended?).to be true
    end
    it 'returns false if state is not ended.' do
      expect(subject).not_to be_ended
    end
  end
end
