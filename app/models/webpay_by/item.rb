module WebpayBy
  class Item
    attr_reader :name, :quantity, :price, :total

    def initialize(name:, quantity:, price:)
      @price     = price
      @quantity  = quantity
      @name      = name
      @total     = @quantity * @price
    end
  end
end
