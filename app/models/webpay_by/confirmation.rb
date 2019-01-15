require 'uri'
require 'net/https'
require 'openssl'
require 'builder'

module WebpayBy
  class Confirmation
    SANDBOX_URL = 'https://sandbox.webpay.by'.freeze
    BILLING_URL = 'https://billing.webpay.by'.freeze

    attr_reader :client, :transaction_id

    def initialize(options = {})
      @client         = options[:client]
      @transaction_id = options[:transaction_id]
    end

    def url_string
      @client.debug_mode ? SANDBOX_URL : BILLING_URL
    end

    # ОТВЕТ ЗА ЗАПРОС НА ПОДТВЕРЖДЕНИЕ: Возвращаемый XML выглядит примерно так (без переносов строк):
    # <?xml version="1.0" encoding="UTF-8"?>
    # <wsb_api_response>
    #   <version>1</version>
    #   <command>get_transaction</command>
    #   <status>success</status>
    #   <fields>
    #     <transaction_id>562183392</transaction_id>
    #     <batch_timestamp>1545912281</batch_timestamp>
    #     <currency_id>BYN</currency_id>
    #     <amount>100</amount>
    #     <payment_method>cc</payment_method>
    #     <payment_type>4</payment_type>
    #     <order_id>861857173</order_id>
    #     <order_num>8000104</order_num>
    #     <rrn>420794984839</rrn>
    #     <wsb_signature>d5a09bf7c014a1d3e7629d031fc54d87</wsb_signature>
    #   </fields>
    # </wsb_api_response>
    #
    def send
      xml = api_request_xml.gsub("\n", '').gsub(/\s{2,}/, '').gsub(' <', '<')
      response = Net::HTTP.post_form(URI.parse(url_string), {'*API': '', 'API_XML_REQUEST': xml}).body
      WebpayBy::ConfirmationResponse.new(client: @client, confirmation: self, response: response)
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
    #     <transaction_id>123456789
    #   </transaction_id>
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
