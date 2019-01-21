# frozen_string_literal: true
#
# После совершения удачного платежа, система WebPay отсылает специально сформированный POST-запрос по адресу,
# указанному в поле wsb_notify_url (Webpay::Request#notify_url). В этом запросе содержится информация по платежу.
#
# Полученную информацию Интернет-ресурс должен проверить в соответствии с требованиями выполнения заказа
# и ответить на запрос кодом: "HTTP/1.0 200 OK".
#
# Эта модель служит для работы с полученным от сервера WebPay запросом. Перед созданием объекта обязательно создайте
# клиента.
#
# Поля, содержащиеся в запросе:
#   batch_timestamp - время совершения транзакции
#   currency_id     - валюта транзакции
#   amount          - сумма транзакции
#   payment_method  - метод совершения транзакции
#   order_id        - номер заказа в системе WebPay
#   site_order_id   - номер (имя) заказа, присвоенное магазином (Webpay::Request#order_id)
#   transaction_id  - номер транзакции
#   payment_type    - тип транзакции
#   rrn             - номер транзакции в системе Visa/MasterCard
#   wsb_signature   - электронная подпись сервера
#
# Пример:
#
#   response = webpay_client.response request.params
#   raise '...' unless response.valid_signature?
#   logger.log "успешная оплата заказа #{response.site_order_id} на сумму #{response.amount} #{response.currency_id}"
#   do_money_stuff response.site_order_id
#
require 'digest'

module WebpayBy
  class Response
    SUCCESSFUL_TYPE_INDEXES = %w( 1 4 )

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

    # Верен ли ответ от сервера?
    def approved?
      valid_signature? && @payment_type.in?(SUCCESSFUL_TYPE_INDEXES)
    end

    # wsb_signature представляет собой hex-последовательность и является результатом выполнения функции MD5.
    # В качестве аргумента функции MD5 служит текстовая последовательность, полученная путем простой конкатенации.
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
