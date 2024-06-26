# frozen_string_literal: true

module MyOrm
  class Exception < ::StandardError
    # A convenience for accessing the error code for this exception.
    attr_reader :code
  end

  class PopulateException < Exception; end

  class ConnectionException < Exception; end

  class DependentException < Exception; end

  class RestrictException < Exception; end

  class TableNameException < Exception; end
end
