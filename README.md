# Гем для работы с webpay.by

Гем для работы с платежной системой WebPay для использования в проектах, использующих Ruby (Ruby On Rails, Sinatra и др.).

WebPay («Вебпей») – белорусская система электронных платежей компании ООО «ВЭБ ПЭЙ», 
который позволяет осуществлять безопасные платежи при помощи банковских карт VISA и MasterCard 
в режиме реального времени в любой валюте (BYN, USD, RUB, EUR и т.д.).

WebPay™ Sandbox — это самостоятельное Web-приложение, являющееся прототипом реальной системы и предназначенное для  
тестирования и ознакомления с возможностями реальной системы WebPay™.

Оф. сайт: https://webpay.by

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

```ruby
require 'webpay_by/client'

webpay_client = WebpayBy::Client.new(
  secret_key: 'my_secret_key',
  billing_id: '000000001',
  debug_mode: !Rails.env.production?,
  login:      'foobar',
  password:   "foobar"
)

Rails.application.config.webpay_by.client = webpay_client
```