RSpec.describe MtgCards::Card do
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
    }]
  end

  subject { described_class.new({ group_by: 'set' }) }

  before do
    allow_any_instance_of(Net::HTTPResponse).to receive(:to_hash)
      .and_return({ 'link' => ['<https://api.magicthegathering.io/v1/cards?page=1>; rel="last"'] })
    allow_any_instance_of(Net::HTTPResponse).to receive(:body)
      .and_return({ cards: cards }.to_json)
  end

  describe '#all' do
    it 'returns all cards' do
      expect(subject.all.length).to be(3)
    end
  end

  describe '#by_attribute' do
    it 'returns cards grouped by specified attribute' do
      result = subject.by_attribute('set')
      expect(result.keys.length).to be(2)
      expect(result['KTK'].length).to be(2)
      expect(result['LEA'].length).to be(1)
    end
  end

  describe '#by_nested_attributes' do
    it 'returns cards grouped by nested attributed' do
      result = subject.by_nested_attributes(%w[set rarity])
      expect(result.keys.length).to be(2)
      expect(result['KTK'].key?('Rare')).to be true
      expect(result['KTK'].key?('Uncommon')).to be true
    end
  end

  describe '#by_set_and_colors' do
    it 'returns cards by a specified set and color ' do
      blue_ktk = subject.by_set_and_colors('KTK', %w[Blue])
      blue_and_red_ktk = subject.by_set_and_colors('KTK', %w[Blue Red])
      red_lea = subject.by_set_and_colors('LEA', %w[Red])

      expect(blue_ktk.length).to be 1
      expect(blue_and_red_ktk.length).to be 1
      expect(red_lea.length).to be 0
    end
  end
end
