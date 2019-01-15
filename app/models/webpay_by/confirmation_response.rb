require 'digest'

module WebpayBy
  class ConfirmationResponse
    PAYMENT_TYPES = {
      'Completed':      'Завершенная',
      'Declined':       'Отклоненная',
      'Pending':        'Вобработке',
      'Authorized':     'Авторизованная',
      'Refunded':       'Возвращенная',
      'System':         'Системная',
      'Voided':         'Сброшенная после авторизации',
      'Failed':         'Ошибка в проведении операции',
      'Partial Voided': 'Частичный сброс',
      'Recurrent':      'Рекуррентный платеж'
    }.freeze

    # Успешной оплате соответствуют следующие значени/: Completed, Authorized, Recurrent
    # Ниже храним в константе их типы
    SUCCESSFUL_TYPE_INDEXES = %w( 1 4 10 ).freeze

    attr_reader :client, :confirmation, :response, :parsed_response

    def initialize(options = {})
      @client           = options[:client]
      @confirmation     = options[:confirmation]
      @response         = options[:response]
      @parsed_response  = Hash.from_xml(@response) rescue {}
    end

    def wsb_api_response
      @parsed_response['wsb_api_response'] || {}
    end

    def response_fields
      wsb_api_response['fields'] || {}
    end

    def valid_signature?
      return false unless response_fields.any?

      signature == response_fields['wsb_signature']
    end

    def signature
      signed_attrs = [
        response_fields['transaction_id'],
        response_fields['batch_timestamp'],
        response_fields['currency_id'],
        response_fields['amount'],
        response_fields['payment_method'],
        response_fields['payment_type'],
        response_fields['order_id'],
        response_fields['rrn'],
        @client.secret_key,
      ].join

      Digest::MD5.hexdigest(signed_attrs)
    end

    def approved?
      payment_type_index = response_fields['payment_type']
      valid_signature? && payment_type_index.in?(SUCCESSFUL_TYPE_INDEXES)
    end
  end
end
