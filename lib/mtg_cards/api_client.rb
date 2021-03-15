# frozen_string_literal: true

require 'net/http'
require 'json'

module MtgCards
  class ApiClient
    def initialize(params = {})
      @caller = params[:caller]
      @category = @caller.category
      @base_url = "https://api.magicthegathering.io/v1/#{@category}".freeze
      @first_page_number = params[:start_page] || 1
      @group_by = params[:group_by]
    end

    def fetch_all
      all
    end

    private

    def response_by_page(page = @first_page_number)
      uri = URI(@base_url)
      params = { page: page }
      uri.query = URI.encode_www_form(params)
      Net::HTTP.get_response(uri)
    end

    def first_page_response
      @first_page_response ||= response_by_page(@first_page_number)
    end

    def last_page_number
      @last_page_number ||= first_page_response
                            .to_hash['link']
                            .first
                            .split(',')
                            .find { |l| l[/\=\"last\"$/] }[/page\=\K\d+/]
                            .to_i
    end

    def all
      list = []
      first_page_body = parse_response(first_page_response)
      print_progress(@first_page_number)
      list.append(*first_page_body[@category])
      update_groups(first_page_body[@category]) if group_data?

      return list if last_page_number.to_i < 2

      (@first_page_number + 1..last_page_number).each_slice(20) do |subset|
        Fiber.new do
          subset.each do |page|
            response = response_by_page(page)
            data = JSON.parse(response.body)[@category]

            break if data.empty?

            print_progress(page)
            list.append(*data)
            update_groups(data) if group_data?
          end
        end.resume
      end

      list
    end

    def parse_response(response)
      JSON.parse(response.body)
    end

    def print_progress(page)
      puts "Fetched page #{page} of #{last_page_number}"
    end

    def group_data?
      !(@group_by.nil? || @group_by.empty?)
    end

    def update_groups(items)
      items.each do |item|
        @caller.add_to_group(item[@group_by], item)
      end
    end
  end
end
