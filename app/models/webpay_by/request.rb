# frozen_string_literal: true
#
# Модель для формирования заказа. Перед созданием заказа обязательно создайте клиента.
# Чтобы создать заказ, вам нужно настроить следующие поля:
#   seed - случайная последовательность символов , участвующих в формировании электронной подписи заказа.
#   order_id - уникальный идентификатор заказа, присваиваемый магазином.
#   back_url - URL адрес на который возвращается покупатель в случае успешной оплаты.
#   notify_url - данный URL вызывается вне зависимости от того, был ли переход по URL в поле wsb_return_url или нет.
#   items - список товаров к оплате.
#   currency_id - идентификатор валюты. Буквенный трехзначный код валюты согласно ISO4271. По умолчанию BYN(белорусский рубль).
#
# Пример:
#
# request = webpay_client.request(
#   order_id:   'item-1',
#   seed:       '12.12.2019',
#   back_url:   product_url,
#   notify_url: payments_epay_url,
#   items:      [{price: 100, name: 'Пополнение счёта', quantity: 1}]
# )
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

    # Электронная подпись формируется для предотвращения изменений в форме платежа и должна присутствовать в каждой форме заказа.
    # Все заказы без электронной подписи не будут рассматриваться системой WebPay
    def signature
      signed_attrs = [@seed, @client.billing_id, @order_id, test_mode, @currency_id, total, @client.secret_key].join

      Digest::SHA1.hexdigest signed_attrs
    end

    def form(options = {})
      WebpayBy::Form.new options.merge request: self
    end
  end
end
