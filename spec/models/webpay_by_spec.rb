require 'spec_helper'

Dir['./app/models/webpay_by/*.rb'].each { |f| require f }

describe WebpayBy::Client do
  let(:webpay_client) do
    WebpayBy::Client.new(
        secret_key: 'your_secret_key',
        billing_id: '000000001',
        debug_mode: true,
        login:      'your_login',
        password:   'your_password'
    )
  end

  describe 'Формирования заказа' do
    it 'сгенерирует правильную электронную подпись' do
      request = webpay_client.request(
          order_id:   'item-1',
          seed:       '12.12.2019',
          back_url:   'test.com',
          notify_url: 'test.com/notify',
          items:      [{price: 100, name: 'Пополнение счёта', quantity: 1}]
      )

      # seed='12.12.2019' billing_id='000000001' order_id='item-1' test_mode=1 currency_id'BYN'
      # amount=100 secret_key='your_secret_key'
      valid_signature = '42fc5bd5f26360789488073d2d8e535f9e16e2f9'

      expect(request.signature).to eq valid_signature
    end
  end

  describe 'Ответ банка' do
    it 'возвращает валидную электронную подпись' do
      answer_params = {
        batch_timestamp:  '10.10.2019',
        currency_id:      'BYN',
        amount:           '100',
        payment_method:   'cc',
        order_id:         '1111',
        site_order_id:    'item-1',
        transaction_id:   '1',
        payment_type:     '4',
        rrn:              '01',
        wsb_signature:    '62a2ab40e7ae1630883e1f8e2f284f8a'
      }

      response = webpay_client.response answer_params

      expect(response.signature).to eq answer_params[:wsb_signature]
    end
  end

  describe 'Подтверждения об оплате банку' do
    it 'ответ возвращает валидную электронную подпись' do
      xml_response = <<-XML.gsub("\n", '').gsub(/\s{2,}/, '').gsub(' <', '<')
        <?xml version="1.0" encoding="UTF-8"?>
        <wsb_api_response>
          <version>1</version>
          <command>get_transaction</command>
          <status>success</status>
          <fields>
            <transaction_id>1</transaction_id>
            <batch_timestamp>31231231</batch_timestamp>
            <currency_id>BYN</currency_id>
            <amount>100</amount>
            <payment_method>cc</payment_method>
            <payment_type>4</payment_type>
            <order_id>item-1</order_id>
            <order_num>1111</order_num>
            <rrn>1</rrn>
            <wsb_signature>7f0276873ce8e701c6fe36912fe5fb33</wsb_signature>
          </fields>
        </wsb_api_response>
      XML

      confirmation          = webpay_client.confirmation(transaction_id: '1')
      confirmation_response = WebpayBy::ConfirmationResponse.new(confirmation: confirmation, response: xml_response)

      expect(confirmation_response.signature).to eq confirmation_response.response_fields[:wsb_signature]
    end
  end
end
