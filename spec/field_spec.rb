require './main'

RSpec.describe Field do
  let(:game) { Game.new(1,1,0) }
  # let(:table) { game.table }
  let(:field) { Field.new(0, game) }

  describe "#state" do
    it 'is :untouched when initialized.' do
      expect(field.state).to eq(:untouched)
    end

    it 'is :marked after #mark is called' do
      field.mark
      expect(field.state).to eq(:marked)
    end

    it 'is :picked after #pick is called.' do
      field.pick
      expect(field.state).to eq(:picked)
    end

    it 'is :untouched after #unmark is called.' do
      field.unmark
      expect(field.state).to eq(:untouched)
    end
  end

  describe '#value' do
    it 'returns @value if state is picked.' do
      field.pick
      expect(field.value).to eq(0)
    end

    it 'returns nil if state is not picked.' do
      expect(field.value).to be_nil
      field.mark
      expect(field.value).to be_nil
    end
  end

  describe "#mark" do
    it 'changes state to :marked.' do
      expect { field.mark }.to change(field, :state).to(:marked)
    end

    it 'does nothing if state is :picked.' do
      field.pick
      expect { field.mark }.not_to change(field, :state)
    end
  end

  describe "#pick" do
    it 'changes state to :picked.' do
      expect { field.pick }.to change(field, :state).to(:picked)
    end

    it 'does nothing if state is :marked.' do
      field.mark
      expect { field.pick }.not_to change(field, :state)
    end
  end

  describe "#unmark" do
    it 'changes state to :untouched.' do
      field.mark
      expect { field.unmark }.to change(field, :state).to(:untouched)
    end

    it 'does nothing if state :untouched.' do
      expect { field.unmark }.not_to change(field, :state)
    end

    it 'does nothing if state :picked.' do
      field.pick
      expect { field.unmark }.not_to change(field, :state)
    end
  end

  describe "#inspect" do
    context '.game==running' do
      it 'returns " " if state is :untouched.' do
        expect(field.inspect).to eq(" ")
      end

      it 'returns "M" if state is :marked.' do
        field.mark
        expect(field.inspect).to eq("M")
      end
      # TODO ilyen nincs
      it 'returns the value if state is :picked.' do
        field.pick
        expect(field.inspect).to eq("0")
        field = Field.new('x', game)
        field.pick
        expect(field.inspect).to eq("X")
      end
    end
    context '.game==ended' do
      before :each do
        game.instance_variable_set :@state, :ended
      end

      it 'retuns the value, if state is :untouched.' do
        expect(field.inspect).to eq("0")
        field = Field.new('x', game)
        expect(field.inspect).to eq("x")
      end
      it 'returns "M" or "!" if the state is :marked.' do
        field = Field.new('x', game)
        field.mark
        expect(field.inspect).to eq("M")

        field = Field.new(2, game)
        field.mark
        expect(field.inspect).to eq("!")
      end
      it 'returns the value or X if state is :picked.' do
        field = Field.new(1, game)
        field.pick
        expect(field.inspect).to eq("1")

        field = Field.new('x', game)
        field.pick
        expect(field.inspect).to eq("X")
      end
    end
  end

  describe "#untouched?" do
    it 'return true if state is :untouched.' do
      expect(field).to be_untouched
    end
    it 'return false if state is :picked.' do
      field.pick
      expect(field).not_to be_untouched
    end
    it 'return false if state is :marked.' do
      field.mark
      expect(field).not_to be_untouched
    end
  end

  describe "#picked?" do
    it 'return true if state is :picked.' do
      field.pick
      expect(field).to be_picked
    end
    it 'return false if state is :marked.' do
      field.mark
      expect(field).not_to be_picked
    end
    it 'return false is state is :untouched.' do
      expect(field).not_to be_picked
    end
  end

  describe "#marked?" do
    it 'return true if state is :marked.' do
      field.mark
      expect(field).to be_marked
    end
    it 'return false if state is :picked.' do
      field.pick
      expect(field).not_to be_marked
    end
    it 'return false if state is :untouched.' do
      expect(field).not_to be_marked
    end
  end

  describe '#state' do
    it 'returns the symbol value of the state.' do
      expect { field.mark }.to change(field, :state).to :marked
      expect { field.unmark }.to change(field, :state).to :untouched
      expect { field.pick }.to change(field, :state).to :picked
    end
  end

  describe '(private) #state=' do
    it 'changes the state to the given value.' do
      expect { field.send(:state=, :picked) }.to change(field, :state).to :picked
      expect { field.send(:state=, :marked) }.to change(field, :state).to :marked
    end
  end
end
