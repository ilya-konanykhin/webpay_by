# frozen_string_literal: true
#
# Модель для подтверждении оплаты системе Webpay.
# Пример:
#
# Создаем объект и передаем ему номер транзакции
# confirmation = webpay_client.confirmation(transaction_id: 'item-1')
#
# Создаем пост запрос к банку
# confirmation_response = confirmation.send
#
# Проверяем ответ от системы на подлинность электронной подписи и подтверждения об оплате
#
require 'digest'
require 'active_support/core_ext/hash'

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
    }

    # Успешной оплате соответствуют следующие значения: Completed, Authorized, Recurrent
    # Ниже храним в константе их типы
    SUCCESSFUL_TYPE_INDEXES = %w( 1 4 10 )

    attr_reader :confirmation, :response, :parsed_response

    def initialize(confirmation:, response:)
      @confirmation     = confirmation
      @response         = response
      @parsed_response  = Hash.from_xml(@response).deep_symbolize_keys rescue {}
    end

    def wsb_api_response
      @parsed_response[:wsb_api_response] || {}
    end

    def response_fields
      wsb_api_response[:fields] || {}
    end

    # Проверка аутентичности XML-документа, пришедшего от банка
    def valid_signature?
      return false unless response_fields.any?

      signature == response_fields[:wsb_signature]
    end

    def signature
      signed_fields = %i( transaction_id batch_timestamp currency_id amount payment_method payment_type order_id rrn )
      signed_attrs  = response_fields.values_at *signed_fields
      signed_attrs  << @confirmation.client.secret_key
      Digest::MD5.hexdigest signed_attrs.join
    end

    def approved?
      payment_type_index = response_fields[:payment_type]
      valid_signature? && payment_type_index.in?(SUCCESSFUL_TYPE_INDEXES)
    end
  end
end
