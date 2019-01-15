require 'digest'

module WebpayBy
  class Client
    attr_reader :billing_id, :secret_key, :debug_mode, :login, :password

    def initialize(billing_id:, secret_key:, debug_mode:, login:, password:)
      @billing_id = billing_id
      @secret_key = secret_key
      @debug_mode = debug_mode
      @login      = login
      @password   = Digest::MD5.hexdigest password
    end

    def request(options = {})
      WebpayBy::Request.new options.merge(client: self)
    end

    def response(options = {})
      WebpayBy::Response.new options.merge(client: self)
    end

    def confirmation(options)
      WebpayBy::Confirmation.new options.merge(client: self)
    end
  end
end
