RSpec.describe MtgCards::ApiClient do
  let(:cards) do
    [{
      name: 'Moon Dragon',
      set: 'LEA',
      rarity: 'Rare',
      colors: %w[Grey]
    }, {
      name: 'Sky Dragon',
      set: 'KTK',
      rarity: 'Rare',
      colors: %w[Blue]
    }, {
      name: 'Fya',
      set: 'KTK',
      rarity: 'Uncommon',
      colors: %w[Red Blue]
    }, {
      name: 'Reckless rage',
      set: 'RIX',
      rarity: 'Uncommon',
      colors: %w[Red]
    }]
  end

  subject do
    described_class.new({ caller: MtgCards::Card.new })
  end

  before do
    allow_any_instance_of(Net::HTTPResponse).to receive(:to_hash)
      .and_return({ 'link' => ['<https://api.magicthegathering.io/v1/cards?page=1>; rel="last"'] })
    allow_any_instance_of(Net::HTTPResponse).to receive(:body)
      .and_return({ cards: cards }.to_json)
  end

  describe '#fetch_all' do
    it 'fetches all cards' do
      client = described_class.new({ caller: MtgCards::Card.new })
      result = client.fetch_all
      expect(result.length).to be 4
    end
  end

  describe 'logger' do
    it 'prints task progress to the console' do
      client = described_class.new({ caller: MtgCards::Card.new })
      expect { client.fetch_all }
        .to output("Fetched page 1 of 1\n")
        .to_stdout
    end
  end
end
