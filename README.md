# Гем для работы с webpay.by

Гем для работы с платежной системой WebPay для использования в проектах, использующих Ruby (Ruby On Rails, Sinatra и др.).

WebPay («Вебпей») – белорусская система электронных платежей компании ООО «ВЭБ ПЭЙ», 
который позволяет осуществлять безопасные платежи при помощи банковских карт VISA и MasterCard 
в режиме реального времени в любой валюте (BYN, USD, RUB, EUR и т.д.).

WebPay™ Sandbox — это самостоятельное Web-приложение, являющееся прототипом реальной системы и предназначенное для  
тестирования и ознакомления с возможностями реальной системы WebPay™.

Официальный сайт: https://webpay.by

Документация: https://webpay.by/wp-content/uploads/2016/08/WebPay-Developer-Guide-2.1.2_RU.pdf

## Установка

Добавьте эту строку в ваш Gemfile:

    gem 'webpay_by'

Затем установите gem, используя bundler:

    $ bundle

Или выполните команду:

    $ gem install webpay_by

## Использование (примеры с использованием Ruby On Rails)

### Настройка

Создаем клиент для работы с Webpay

```ruby
require 'webpay_by/client'

webpay_client = WebpayBy::Client.new(
  secret_key: 'your_secret_key',
  billing_id: '000000001',
  debug_mode: !Rails.env.production?,
  login:      'your_login',
  password:   'your_password'
)

Rails.application.config.webpay_by = webpay_client
```

Формируем заказ и создаем форму

```ruby
request = Rails.application.config.webpay_by.request(
  order_id:   'item-1',
  seed:       '12.12.2019',
  back_url:   product_url,
  notify_url: payments_epay_url,
  items:      [{price: 100, name: 'Пополнение счёта', quantity: 1}]
)

@form = request.form

```
```slim
= form_tag @form.action_url, method: @form.request_method, id: 'epay-form', enctype: @form.enctype do
  - @form.fields.each do |key, value|
    = hidden_field_tag key, value
  = submit_tag 'Перейти к пополнению'
```
Важно: 
- В режиме разработки, после подтверждения формы оплаты, система может не принять запрос, ссылаясь на неправильный формат wsb_notify_url или wsb_return_url. 
Это связано с тем, что система валидирует эти поля на реальные домены. 
Локальный сервер localhost:3000 или адреса с доменными зонами .dev, .localhost и т.д работат не будут.
Поэтому перед созданием формы передайте в заказ параметры notify_url и back_url c валидными адресами.
- Если у вас в биллинг-аккаунте подключена возможность приема оплаты и через систему ЕРИП,
то при тестировании платежей  максимальная длина имени счета (wsb_order_num) равна 10 символам.
В реальной среде размер этого поля может измениться в зависимости от ограничений, которые будут установлены системой ЕРИП.

После совершения удачного платежа, система WebPay отсылает специально сформированный POST-запрос по адресу,
указанному в поле wsb_notify_url Интернет-ресурса. В этом запросе содержится информация по платежу.
Полученную информацию Интернет-ресурс должен проверить в соответствии с требованиями выполнения заказа
и ответить на запрос кодом: "HTTP/1.0 200 OK".

       
```ruby
answer_hash             = params.except(:controller, :action).to_unsafe_h.symbolize_keys
response                = webpay_client.response answer_hash

if response.approved?
  user.add_balance response.amount
end

render nothing: true, status: 200
``` 

Прежде чем доставить товар (оказать услугу), Интернет-ресурс обязан проверить совершенный покупателем платеж.
Что такое "подтверждение": когда человек ввел данные карты, нужная сумма только блокируется на ней. Чтобы она
реально списалась, мы должны сообщить системе Webpay, что услуга оказана и сумму можно списать. Это и есть подтверждение.
Его нужно делать автоматически, поэтому через cron или аналог надо запускать робота, который будет выбирать
оплаченные заявки и их подтверджать. 

```ruby
webpay_client         = Rails.application.config.webpay_by
confirmation          = webpay_client.confirmation(transaction_id: transaction_id)
confirmation_response = confirmation.send

# Проверяем ответ от системы на подлинность электронной подписи и подтверждения об оплате
if confirmation_response.approved?
 order.update(confirmed: true)
end
``` 