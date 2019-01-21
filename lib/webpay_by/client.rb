# Клиент для взаимодействия с WebPay. Он предоставляет доступ ко всем возможностям системы онлайн-оплаты.
#
# Чтобы создать клиент, вам нужно настроить следующие поля:
#   billing_id - уникальный идентификатор магазина
#   secret_key - секретный ключ, необходим для формирования электронной  подписи каждого Вашего платежа
#   debug_mode - поле, указывающее на проведение тестовой оплаты. Для работы с тестовой средой укажите true
#   login      - имя пользователя (для подтверждения платежа)
#   password   - пароль (для подтверждения платежа)
#
# Пример:
#
#   webpay_client = WebpayBy::Client.new(
#   secret_key: 'your_secret_key',
#     billing_id: '000000001',
#     debug_mode: ENV.development?,
#     login:      'your_login',
#     password:   'your_password'
#   )
#
require 'digest'

module WebpayBy
  class Client
    attr_reader :billing_id, :secret_key, :debug_mode, :login, :password

    alias debug_mode? debug_mode

    def initialize(billing_id:, secret_key:, debug_mode:, login:, password:)
      @billing_id = billing_id
      @secret_key = secret_key
      @debug_mode = debug_mode
      @login      = login
      @password   = Digest::MD5.hexdigest password
    end

    # Вернет объект "запроса на оплату" WebpayBy::Request, из которого можно получить WebpayBy::Form для создания формы
    def request(options = {})
      WebpayBy::Request.new options.merge client: self
    end

    # Вернет объект "ответа от сервера" WebpayBy::Response для валиадции ответа WebPay
    def response(options = {})
      WebpayBy::Response.new options.merge client: self
    end

    # Вернет объект "подтверждения платежа" WebpayBy::Confirmation для списания заблокированных средств
    def confirmation(options = {})
      WebpayBy::Confirmation.new options.merge client: self
    end
  end
end
