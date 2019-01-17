require 'webpay_by/version'

module WebpayBy
  autoload :Client,               'webpay_by/client'
  autoload :Confirmation,         'webpay_by/confirmation'
  autoload :ConfirmationResponse, 'webpay_by/confirmation_response'
  autoload :Form,                 'webpay_by/form'
  autoload :Item,                 'webpay_by/item'
  autoload :Request,              'webpay_by/request'
  autoload :Response,             'webpay_by/response'
end
