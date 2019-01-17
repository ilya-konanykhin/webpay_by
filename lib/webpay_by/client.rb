# Клиент для взаимодействия с Webpay. Он предоставляет доступ ко всем возможностям системы онлайн-оплаты.
# Чтобы создать клиент, вам нужно настроить следующие поля:
#   billing_id - уникальный идентификатор магазина.
#   secret_key - секретный ключ, необходим для формирования электронной  подписи каждого Вашего платежа.
#   debug_mode - поле, указывающее на проведение тестовой оплаты. Для работы с тестовой средой укажите true.
#   login - имя пользователя.
#   password - пароль.
#
# Пример:
#
# webpay_client = WebpayBy::Client.new(
# secret_key: 'your_secret_key',
#     billing_id: '000000001',
#     debug_mode: ENV.development?,
#     login:      'your_login',
#     password:   'your_password'
# )
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

    def request(options = {})
      WebpayBy::Request.new options.merge client: self
    end

    def response(options = {})
      WebpayBy::Response.new options.merge client: self
    end

    def confirmation(options)
      WebpayBy::Confirmation.new options.merge client: self
    end
  end
end
