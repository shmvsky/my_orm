# frozen_string_literal: true

require_relative '..\..\..\lib\my_orm'


RSpec.describe MyOrm::Record do
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

  def query(id, pp)
    MyOrm::Connection.execute("SELECT * FROM #{Student.table_name} WHERE id = #{id} AND pp = #{pp}")[0]
  end

  context '#save' do
    example 'as a create' do
      args = { id: 52, pp: 12, name: 'ABOBA', surname: 'ABOB', yr: 52 }

      obj = Student.new(**args)
      obj.save

      new_row_of_the_table = query(52, 12)

      expect(args.length).to eq(new_row_of_the_table.length)
      expect(args.values).to match_array new_row_of_the_table
    end

    example 'set an existing primary key' do
      args = { id: 1, pp: 5, name: 'ABOBA', surname: 'ABOB', yr: 52 }

      obj = Student.new(**args)

      expect { obj.save }.to raise_error(SQLite3::ConstraintException)
    end

    example 'as an update' do
      args = { id: 11, pp: 55, name: 'ABOBA', surname: 'ABOB', yr: 52 }

      obj = Student.new(**args)

      obj.save

      new_args = { id: 52, pp: 52, name: 'SNUS', surname: 'HOLA', yr: 53 }

      obj.id = new_args[:id]
      obj.pp = new_args[:pp]
      obj.name = new_args[:name]
      obj.surname = new_args[:surname]
      obj.yr = new_args[:yr]

      obj.save

      updated_row = query(52, 52)
      old_row = query(11, 55)

      expect(old_row).to be_nil
      expect(new_args.values).to match_array updated_row
    end
  end

  context '#update' do
    let(:obj) { Student.create(id: 52, pp: 25, name: 'ABOB', surname: 'BOB', yr: 19) }

    example 'update some args' do
      args = { id: 777, pp: 888, name: 'KEK', surname: 'LOL', yr: 12 }

      obj.update(**args)

      updated_row = query(777, 888)
      old_row = query(52, 25)

      expect(old_row).to be_nil
      expect(args.values).to match_array updated_row
    end

    example 'set an existing primary key' do
      # these primary_keys already exist
      args = { id: 1, pp: 5 }

      expect { obj.update(**args) }.to raise_error SQLite3::ConstraintException
    end
  end

  context '.create' do
    it 'creates a row' do
      args = { id: 52, pp: 25, name: 'ABOB', surname: 'BOB', yr: 19 }
      Student.create(**args)

      new_row = query(52, 25)

      expect(args.length).to eq(new_row.length)
      expect(args.values).to match_array(new_row)
    end

    example 'set an existing primary key' do
      args = { id: 1, pp: 5, name: 'ABOB', surname: 'BOB', yr: 19 }

      expect { Student.create(**args) }.to raise_error SQLite3::ConstraintException
    end
  end

  context '.where' do
    before do
      Student.create(id: 52, pp: 1, name: 'test1', surname: 'test1', yr: 2)
      Student.create(id: 53, pp: 553, name: 'test2', surname: 'test2', yr: 3)
    end

    it 'gets some rows' do
      rows = Student.where('id >    ?   AND pp   >   ?', 1, 2)

      args1 = { :@id => 2, :@pp => 5, :@name => 'Илья', :@surname => 'Вязников', :@yr => 3 }
      args2 = { :@id => 53, :@pp => 553, :@name => 'test2', :@surname => 'test2', :@yr => 3 }

      expect(rows.length).to eq 2

      args1.each do |key, val|
        instance_args = rows[0].instance_variable_get(key)
        expect(instance_args).to eq val
      end

      args2.each do |key, val|
        instance_args = rows[1].instance_variable_get(key)
        expect(instance_args).to eq val
      end


      rows = Student.where('id >    ?   AND pp   >   ?', 1512, 2)

      expect(rows).to be_empty
    end

    example 'without arguments' do
      table_from_where = Student.where

      args = %i[@id @pp @name @surname @yr]

      table = MyOrm::Connection.execute("SELECT * FROM #{Student.table_name}")

      table.zip(table_from_where).each do |r1, r2|
        args.each_with_index do |col, i|
          expect(r1[i]).to eq r2.instance_variable_get(col)
        end
      end
    end

    example 'wrong conditions' do
      expect { Student.where('fsa > ?', 5) }.to raise_error SQLite3::SQLException
      expect { Student.where('id >     ', 2) }.to raise_error SQLite3::SQLException
      expect { Student.where('id > ? fsa', 2) }.to raise_error SQLite3::SQLException

      rows = Student.where('id > ?', 52, 3)

      args = { :@id => 53, :@pp => 553, :@name => 'test2', :@surname => 'test2', :@yr => 3 }
      args.each do |key, val|
        col = rows[0].instance_variable_get(key)
        expect(col).to eq val
      end
    end
  end

  context '.#delete' do
    before do
      Student.create(id: 52, pp: 1, name: 'test1', surname: 'test1', yr: 2)
      Student.create(id: 53, pp: 553, name: 'test2', surname: 'test2', yr: 3)
    end

    example '.delete' do
      res = query(1, 5)

      expect(res).not_to be_nil

      Student.delete(id: 1, pp: 5)

      res = query(1, 5)

      expect(res).to be_nil
    end

    example '#delete' do
      Student.where('id = ? AND pp = ? ', 2, 5).each(&:delete)

      deleted_row = query(2, 5)

      expect(deleted_row).to be_nil

      Student.where.each(&:delete)

      table = MyOrm::Connection.execute("SELECT * FROM #{Student.table_name}")

      expect(table).to be_empty
    end
  end
end
