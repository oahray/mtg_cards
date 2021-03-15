# frozen_string_literal: true

module MtgCards
  class Card
    def initialize(opts = {})
      @groups = {}
      @group_by = opts[:group_by] || 'set'
      @client = opts[:client] || ApiClient.new(
        {
          caller: self,
          group_by: @group_by
        }
      )
      all
    end

    def by_attribute(_attribute)
      @groups
    end

    def by_nested_attributes(attributes)
      grouped_cards = {}
      parent = attributes[0]
      child = attributes[1]
      by_attribute(parent).each do |parent_group, items|
        grouped_cards[parent_group] = items
                                      .group_by { |card| card[child] }
      end

      grouped_cards
    end

    def by_set_and_colors(set_name, colors)
      groups = by_attribute('set')
      groups[set_name]
        .select { |card| colors.sort.eql? card['colors']&.sort }
    end

    def all
      @all ||= @client.fetch_all
    end

    def add_to_group(name, data)
      @groups[name] ||= []
      @groups[name].push data
    end

    def category
      'cards'
    end
  end
end
