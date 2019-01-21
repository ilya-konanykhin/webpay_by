# frozen_string_literal: true
#
# Модель для формирования запроса. Перед созданием запроса обязательно создайте клиента WebpayBy::Client.
#
# Чтобы создать запрос, нужно настроить следующие поля:
#   seed        - случайная последовательность символов, участвующих в формировании электронной подписи запроса
#   order_id    - уникальный идентификатор заказа, присваиваемый магазином (например, ID модели Order)
#   back_url    - URL, на который возвращается покупатель в случае успешной оплаты
#   notify_url  - URL, по которому сервер WebPay отправит подтверждение платежа
#   items       - список товаров к оплате (можно передать массив хэшей, или сами объекты WebpayBy::Item)
#   currency_id - буквенный трехзначный код валюты ISO4271; по-умолчанию BYN (белорусский рубль)
#
# Пример:
#
#   order = ... # Order.new ...
#
#   request = webpay_client.request(
#     order_id:   order.id,
#     seed:       Time.now,
#     back_url:   webpay_back_url,
#     notify_url: webpay_notify_url,
#     items:      [{price: order.price, name: 'Пополнение счёта', quantity: 1}]
#   )
#
require 'digest'

module WebpayBy
  class Request
    CURRENCIES = %w( BYN USD EUR RUB )

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
      @client.debug_mode? ? 1 : 0
    end

    # Электронная подпись формируется для предотвращения изменений в форме платежа и должна присутствовать в каждой
    # форме запроса. Запросы без электронной подписи не будут рассматриваться системой WebPay.
    def signature
      signed_attrs = [@seed, @client.billing_id, @order_id, test_mode, @currency_id, total, @client.secret_key].join

      Digest::SHA1.hexdigest signed_attrs
    end

    # Вернет форму WebpayBy::Form, из которой во вьюхе можно построить ее HTML-представление
    def form(options = {})
      WebpayBy::Form.new options.merge request: self
    end
  end
end
