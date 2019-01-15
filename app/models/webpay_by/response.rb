require 'digest'

module WebpayBy
  class Response
    attr_reader :client, :batch_timestamp, :currency_id, :amount, :payment_method, :order_id, :site_order_id,
                :transaction_id, :payment_type, :rrn

    def initialize(options = {})
      @client           = options[:client]
      @batch_timestamp  = options[:batch_timestamp]
      @currency_id      = options[:currency_id]
      @amount           = options[:amount]
      @payment_method   = options[:payment_method]
      @order_id         = options[:order_id]
      @site_order_id    = options[:site_order_id]
      @transaction_id   = options[:transaction_id]
      @payment_type     = options[:payment_type]
      @rrn              = options[:rrn]
      @wsb_signature    = options[:wsb_signature]
    end

    def valid_signature?
      @wsb_signature.to_s == signature
    end

    def signature
      signed_attrs = [@batch_timestamp, @currency_id, @amount, @payment_method, @order_id, @site_order_id,
                      @transaction_id, @payment_type, @rrn, @client.secret_key].join

      Digest::MD5.hexdigest signed_attrs
    end
  end
end
