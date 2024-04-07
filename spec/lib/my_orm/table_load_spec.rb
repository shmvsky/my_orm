# frozen_string_literal: true

require_relative '..\..\..\lib\my_orm'

RSpec.describe MyOrm::TableLoad do
  context 'Error connection' do
    example 'connection is failed' do
      expect { Class.new(MyOrm::Record) }.to raise_error(MyOrm::ConnectionException)
    end
  end


  context 'No error connection' do
    before do
      MyOrm::Connection.establish_connection ':memory:'
      MyOrm::Record.populate_students
      class Student < MyOrm::Record
      end
    end

    after do
      MyOrm::Connection.close_db
      Object.send(:remove_const, :Student)
    end



    it 'calls inherited and looks at the methods' do
      expected_static_methods = %i[table_name column_info associated_tables]
      expected_instance_methods = %i[is_saved is_saved= current_primary_keys id id= pp pp= name
                                     name= surname surname= yr yr=]

      set_of_expected_static_methods = Set.new(expected_static_methods)
      set_of_expected_instance_methods = Set.new(expected_instance_methods)

      obj = Student.new

      set_of_static_methods = Set.new(Student.methods(false))
      set_of_instance_methods = Set.new(obj.methods)

      expect(set_of_expected_static_methods).to eq set_of_static_methods
      expect(set_of_expected_instance_methods.subset?(set_of_instance_methods)).to eq true
    end
  end
end
