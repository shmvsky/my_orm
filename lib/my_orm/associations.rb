# frozen_string_literal: true
require_relative 'errors'

module MyOrm
  # Модуль, содержаний методы, поддерживающие ассоциации у таблиц
  module Associations
    # table_name - camelCase notation
    def has_many(table_name, **dependent)
      raise DependentException, 'The size of the dependent is incorrect' if dependent.length > 1

      snake_case_table_name = (table_name.to_s.underscore + 's').to_sym

      define_method snake_case_table_name do
        raise TableNameException, 'Undefined table name' unless Object.const_defined?(table_name)

        Object.const_get(table_name)
      end
      
      raise DependentException, 'Undefined dependent' unless %i[destroy nullify restrict_with_exception].include?(dependent.values[0])

      associated_tables[table_name] = dependent.values[0]
    end

    def associated_delete(table_name, dependent, args)
      case dependent
      when :nullify
        nullify_rows(table_name, args)
      when :destroy
        destroy_rows(table_name, args)
      when :restrict_with_exception
        check_restrict(table_name, args)
      end
    end

    def check_restrict(table_name, args)
      rows, = rows_pipeline(table_name, args)

      raise RestrictException, "Associated objects exist into #{table_name}" unless rows.empty?
    end

    def destroy_rows(table_name, args)
      rows, = rows_pipeline(table_name, args)

      rows.each(&:delete)
    end

    def nullify_rows(table_name, args)
      rows, parsed_args = rows_pipeline(table_name, args)

      parsed_args_nil = parsed_args.transform_values { nil }

      rows.each { |col| col.update(**parsed_args_nil) }
    end

    def rows_pipeline(table_name, args)
      parsed_args = parse_args(**args)

      condition = condition_maker(**parsed_args)

      table = Object.const_get(table_name)

      rows = table.where(condition, *parsed_args.values)

      [rows, parsed_args]
    end

    def condition_maker(**args)
      condition = args.inject('') do |cond, hash|
        cond + "#{hash[0]} = ? AND "
      end
      condition[0...-5]
    end

    def parse_args(**args)
      parsed = {}
      args.each do |key, value|
        new_key = "#{table_name}_#{key}".to_sym
        parsed[new_key] = value
      end
      parsed
    end
  end
end