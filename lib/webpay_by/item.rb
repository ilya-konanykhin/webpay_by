# Модель для создания товара для запроса.
#
# Чтобы создать товар, нужно настроить следующие поля:
#   name      - наименование единицы товара
#   quantity  - количество единиц товара, целое число
#   price     - число, определяющее стоимость каждой единицы товара (BYN, USD, EUR, RUB с 2 знаками после запятой)
#
# Пример:
#
#   WebpayBy::Item.new price: 100, name: 'Пополнение счёта', quantity: 1
#
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
