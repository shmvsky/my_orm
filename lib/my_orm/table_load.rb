# frozen_string_literal: true

require_relative 'connection'
require_relative 'record'
require_relative 'errors'

module MyOrm
  # Configuration - модуль, инициализирующий класс-таблицу
  module TableLoad
    def inherited(descendant)
      raise ConnectionException, 'do connect!!!!' unless Connection.connected?

      descendant.load_fields
    end

    def load_fields
      # В КЛАССЕ БУДЕТ ХРАНИТЬСЯ НАЗВАНИЕ ТАБЛИЦЫ, К КОТОРОЙ ОН ОТНОСИТСЯ
      class_variable_set(:@@table_name, "#{to_s.underscore}s")

      define_singleton_method :table_name do
        class_variable_get(:@@table_name)
      end


      class_eval do
        attr_accessor :is_saved
        attr_reader :current_primary_keys

        def initialize(**args)
          # СОЗДАНИЕ ПОЛЯ, ДЛЯ ХРАНЕНИЯ ТЕКУЩИХ ЗНАЧЕНИЙ PRIMARY КЛЮЧЕЙ (ИСПОЛЬЗУЕТСЯ ПРИ ИЗМЕНЕНИИ PRIMARY КЛЮЧЕЙ)
          @current_primary_keys = {}
          # СЛУЖЕБНОЕ ПОЛЕ С ИНФОРМАЦИЕЙ, БЫЛ ЛИ НА ЭКЗЕМПЛЯРЕ ВЫЗВАН МЕТОД SAVE
          @is_saved = false

          return unless args.size.positive?

          args.each do |col, val|
            col_name = :"@#{col}"
            instance_variable_set(col_name, val)
          end
        end
      end

      # ПОЛУЧАЕМ ИНФУ О ТАБЛИЦЕ
      table_info = Connection.execute("PRAGMA table_info(#{table_name})")

      # СОЗДАЕМ СЛУЖЕБНОЕ ПОЛЕ С ИНФОРМАЦИЕЙ О СТОЛБЦАХ {NAME:[INFO1,INFO2..],...}
      class_variable_set(:@@column_info, {})

      define_singleton_method :column_info do
        class_variable_get(:@@column_info)
      end

      class_variable_set(:@@associated_tables, {})

      define_singleton_method :associated_tables do
        class_variable_get(:@@associated_tables)
      end

      table_info.each do |col_info|
        col_name = "@#{col_info[1]}"
        column_info.merge!({ col_name.to_sym => col_info })

        # ПЕРЕБИРАЕМ ИНФУ О КОЛОНКАХ ТАБЛИЦЫ
        col_name = col_info[1]

        # ХУЯРИМ ПЕРЕМЕННЫЕ ОБЪЕКТА
        instance_variable_set("@#{col_name}", nil)

        # ХУЯРИМ ГЕТТЕРЫ
        define_method :"#{col_name}" do
          instance_variable_get("@#{col_name}")
        end

        # ХУЯРИМ СЕТТЕРЫ
        define_method :"#{col_name}=" do |value|
          instance_variable_set("@#{col_name}", value)
        end
      end
    end
  end
end
