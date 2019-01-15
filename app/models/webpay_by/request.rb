require 'digest'

module WebpayBy
  class Request
    CURRENCIES = %w( BYN USD EUR RUB ).freeze

    attr_reader :client, :seed, :order_id, :currency_id, :back_url, :notify_url, :items

    def initialize(client:, seed:, order_id:, back_url:, notify_url:, items:, currency_id: nil)
      @client         = client
      @order_id       = order_id
      @seed           = seed
      @currency_id  ||= CURRENCIES.first
      @back_url       = back_url
      @notify_url     = notify_url
      @items          = items.map { |item| item.is_a?(WebpayBy::Item) ? item : WebpayBy::Item.new(item) }

      raise "Unsupported currency, must be one of #{CURRENCIES.join ', '}" unless CURRENCIES.include? @currency_id
    end

    def total
      @items.map(&:total).sum
    end

    def test_mode
      @client.debug_mode ? 1 : 0
    end

    def signature
      signed_attrs = [@seed, @client.billing_id, @order_id, test_mode, @currency_id, total, @client.secret_key].join

      Digest::SHA1.hexdigest(signed_attrs)
    end

    def form(options = {})
      WebpayBy::Form.new options.merge(request: self)
    end
  end
end
