module WebpayBy
  class Form
    SANDBOX_URL     = 'https://securesandbox.webpay.by'.freeze
    LIVE_URL        = 'https://payment.webpay.by'.freeze
    APP_VERSION     = 2
    LANGUAGE_LIST   = %w( russian english ).freeze
    REQUEST_METHOD  = 'post'.freeze
    ENCTYPE         = 'application/x-www-form-urlencoded'.freeze

    attr_reader :request, :version, :language_id, :request_method, :enctype

    def initialize(request:, language_id: nil)
      @request        = request
      @language_id  ||= LANGUAGE_LIST.first
      @version        = APP_VERSION
      @request_method = REQUEST_METHOD
      @enctype        = ENCTYPE

      raise "Unsupported language, must be one of #{LANGUAGE_LIST.join ', '}" unless LANGUAGE_LIST.include? @language_id
    end

    def action_url
      @request.client.debug_mode ? SANDBOX_URL : LIVE_URL
    end

    def fields
      fields_with_values = {
        '*scart':         '',
        wsb_version:      @version,
        wsb_language_id:  @language_id,
        wsb_storeid:      @request.client.billing_id,
        wsb_order_num:    @request.order_id,
        wsb_test:         @request.test_mode,
        wsb_currency_id:  @request.currency_id,
        wsb_seed:         @request.seed,
        wsb_total:        @request.total,
        wsb_signature:    @request.signature
      }

      unless @request.client.debug_mode
        fields_with_values[:wsb_return_url] = @request.back_url
        fields_with_values[:wsb_notify_url] = @request.notify_url
      end

      @request.items.each_with_index do |item, i|
        fields_with_values.merge!(
          "wsb_invoice_item_name[#{i}]":      item.name,
          "wsb_invoice_item_quantity[#{i}]":  item.quantity,
          "wsb_invoice_item_price[#{i}]":     item.price
        )
      end

      fields_with_values.compact
    end
  end
end
