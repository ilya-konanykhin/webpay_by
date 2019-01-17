# frozen_string_literal: true
#
# Модель для создания запроса об подтверждении оплаты системе Webpay. Перед созданием заказа обязательно создайте клиента.
# Прежде чем доставить товар (оказать услугу), Интернет-ресурс обязан проверить совершенный покупателем платеж.
# Необходимо учитывать, что запрос к тестовой среде необходимо отсылать на адрес https://sandbox.webpay.by, а к реальной среде https://billing.webpay.by
#
# Пример:
#
# Создаем объект и передаем ему номер транзакции
# confirmation = webpay_client.confirmation(transaction_id: 'item-1')
#
# Создаем пост запрос к банку
# confirmation.send
# метод send возвращает объект WebpayBy::ConfirmationResponse, который содержить методы для проверки электронной подписи
# и подтверждения об оплате
#
require 'uri'
require 'net/https'
require 'openssl'

module WebpayBy
  class Confirmation
    SANDBOX_URL = 'https://sandbox.webpay.by'
    BILLING_URL = 'https://billing.webpay.by'

    attr_reader :client, :transaction_id

    def initialize(client:, transaction_id:)
      @client         = client
      @transaction_id = transaction_id
    end

    def url_string
      @client.debug_mode? ? SANDBOX_URL : BILLING_URL
    end

    # ОТВЕТ ЗА ЗАПРОС НА ПОДТВЕРЖДЕНИЕ: Возвращаемый XML выглядит примерно так (без переносов строк):
    # <?xml version="1.0" encoding="UTF-8"?>
    # <wsb_api_response>
    #   <version>1</version>
    #   <command>get_transaction</command>
    #   <status>success</status>
    #   <fields>
    #     <transaction_id>123456789</transaction_id>
    #     <batch_timestamp>31231231</batch_timestamp>
    #     <currency_id>BYN</currency_id>
    #     <amount>100</amount>
    #     <payment_method>cc</payment_method>
    #     <payment_type>4</payment_type>
    #     <order_id>584236984</order_id>
    #     <order_num>5874129</order_num>
    #     <rrn>154789648154</rrn>
    #     <wsb_signature>3021e68df9a7200135725c6331369a22</wsb_signature>
    #   </fields>
    # </wsb_api_response>
    def send
      xml = clear_xml_string api_request_xml
      response = Net::HTTP.post_form(URI.parse(url_string), {'*API': '', 'API_XML_REQUEST': xml}).body
      WebpayBy::ConfirmationResponse.new confirmation: self, response: response
    end

    def clear_xml_string(xml_str)
      xml_str.gsub("\n", '').gsub(/\s{2,}/, '').gsub(' <', '<')
    end

    private

    # Для проверки платежа при возврате на страницу Интернет-ресурса, указанному в поле wsb_return_url, необходимо выполнить
    # API команду биллинга «get_transaction»
    # Сгенерированный XML выглядит примерно так:
    # <?xml version="1.0" encoding="ISO-8859-1"?>
    # <wsb_api_request>
    #   <command>get_transaction</command>
    #   <authorization>
    #     <username>your_username</username>
    #     <password>your_md5_password</password>
    #   </authorization>
    #   <fields>
    #     <transaction_id>123456789</transaction_id>
    #   </fields>
    # </wsb_api_request>
    def api_request_xml
      xml = Builder::XmlMarkup.new indent: 2
      xml.instruct! :xml, encoding: 'ISO-8859-1'
      xml.wsb_api_request do |req|
        req.command 'get_transaction'

        req.authorization do |auth|
          auth.username @client.login
          auth.password @client.password
        end

        req.fields do |merch|
          merch.transaction_id @transaction_id
        end
      end
    end
  end
end
