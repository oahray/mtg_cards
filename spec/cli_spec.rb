RSpec.describe MtgCards::CLI do
  describe '#call' do
    context 'when no option is passed' do
      it 'Prints a welcome message' do
        expect { described_class.new({}).call }
          .to output("Welcome to mtg_cards! Please run '$ bin/mtg_cards -h' for a list of avaliable commands\n")
          .to_stdout
      end
    end

    context 'when an unknown filter is passed' do
      it 'Prints an error message to the conmmand line' do
        expect { described_class.new({ filter: ['ray'] }).call }
          .to output("Error: Unknown filter - ray\n")
          .to_stdout
      end
    end

    context 'when an interrupt exception (ctrl + c) is raised' do
      before do
        allow_any_instance_of(described_class)
          .to receive(:handle_filter).and_raise(Interrupt)
      end

      it 'It exits gracefully' do
        expect { described_class.new({ filter: 'set' }).call }
          .to output("Exiting gracefully... \nBye\n")
          .to_stdout
      end
    end
  end
end
