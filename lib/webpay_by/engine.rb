module WebpayBy
  class Engine < ::Rails::Engine
    config.webpay_by = ActiveSupport::OrderedOptions.new

    isolate_namespace WebpayBy
  end
end
