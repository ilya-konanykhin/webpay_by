# Модель для создания товара для заказа.
# Чтобы создать товар, вам нужно настроить следующие поля:
#   name - Наименование единицы товара.
#   quantity - Количество единиц товара, целое число, обозначающее, количество единиц товара каждого наименования.
#   price - Цена единицы товара, число, определяющее стоимость каждой единицы товара (BYN, USD, EUR, RUB с 2 знаками после запятой или точки).
#
# Пример:
#
# WebpayBy::Item.new price: 100, name: 'Пополнение счёта', quantity: 1
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
