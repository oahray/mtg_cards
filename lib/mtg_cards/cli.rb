# frozen_string_literal: true

require 'optionparser'

module MtgCards
  class CLI
    def initialize(opts)
      @filter = opts[:filter][0] unless opts[:filter].nil?
    end

    def call
      puts handle_filter.to_s
    rescue Interrupt
      puts "Exiting gracefully... \nBye"
    end

    private

    def handle_filter
      case @filter.to_s.strip.downcase
      when 'set'
        Card.new.by_attribute('set')
      when 'set_and_rarity'
        Card.new.by_nested_attributes(%w[set rarity])
      when 'ktk'
        Card.new.by_set_and_colors('KTK', %w[Blue Red])
      when 'all'
        Card.new.fetch_all
      when ''
        "Welcome to mtg_cards! Please run '$ bin/mtg_cards -h' for a list of avaliable commands"
      else
        "Error: Unknown filter - #{@filter}"
      end
    end
  end
end
