# frozen_string_literal: true
#
# Модель для формирования формы оплаты. Перед созданием, обязательно создайте запрос WebpayBy::Request.
#
# Для оплаты запроса необходимо сформировать форму со специальными полями, и POST-методом перенаправить покупателя
# на страницу оплаты WebPay. Для тестирования необходимо указать адрес https://securesandbox.webpay.by, для совершения
# реальных платежей − https://payment.webpay.by.
#
# Все необходимые поля уже настроены в объекте запроса. Дополнительно можно настроить следующие поля:
#   language_id - идентификатор языка формы оплаты; по-умолчанию russian
#
# Пример:
#
#   request = webpay_client.request(
#     order_id:   'item-1',
#     seed:       Time.now,
#     back_url:   webpay_back_url,
#     notify_url: webpay_notify_url,
#     items:      [{price: 100, name: 'Пополнение счёта', quantity: 1}]
#   )
#
#   @form = request.form language_id: 'english'
#
#   # во вьюхе SLIM
#   = form_tag @form.action_url, method: @form.request_method, enctype: @form.enctype do
#     - @form.fields.each do |key, value|
#       = hidden_field_tag key, value
#     = submit_tag 'Перейти к пополнению'
#
module WebpayBy
  class Form
    SANDBOX_URL     = 'https://securesandbox.webpay.by'
    LIVE_URL        = 'https://payment.webpay.by'
    APP_VERSION     = 2
    LANGUAGE_LIST   = %w( russian english )
    REQUEST_METHOD  = 'post'
    ENCTYPE         = 'application/x-www-form-urlencoded'

    attr_reader :request, :version, :language_id, :request_method, :enctype

    def initialize(request:, language_id: nil)
      @request        = request
      @language_id  ||= LANGUAGE_LIST.first
      @version        = APP_VERSION
      @request_method = REQUEST_METHOD
      @enctype        = ENCTYPE

      raise "Unsupported language, must be one of #{LANGUAGE_LIST.join ', '}" unless LANGUAGE_LIST.include? @language_id
    end

    # Значение поля action формы
    def action_url
      @request.client.debug_mode? ? SANDBOX_URL : LIVE_URL
    end

    # Все hidden-поля формы
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
        wsb_signature:    @request.signature,
        wsb_return_url:   @request.back_url,
        wsb_notify_url:   @request.notify_url
      }

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
