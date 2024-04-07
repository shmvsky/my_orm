# frozen_string_literal: true

require_relative '..\..\..\lib\my_orm'

RSpec.describe MyOrm::Associations do
  after do
    MyOrm::Connection.close_db

    Object.send(:remove_const, :Student) if defined?(Student)
    Object.send(:remove_const, :Mark) if defined?(Mark)
    Object.send(:remove_const, :Scholarship) if defined?(Scholarship)
  end

  def query_eq(table, id, pp)
    MyOrm::Connection.execute("SELECT * FROM #{table.table_name} WHERE students_id = #{id} AND students_pp = #{pp}")[0]
  end

  def query(request)
    MyOrm::Connection.execute(request)
  end

  context 'nullify' do
    before do
      MyOrm::Connection.establish_connection ':memory:'
      MyOrm::Record.populate_students

      class Student < MyOrm::Record
        has_many :Mark, dependent: :nullify
        has_many :Scholarship, dependent: :nullify
      end

      class Mark < MyOrm::Record
      end

      class Scholarship < MyOrm::Record
      end
    end

    let(:obj) { Student.new(id: 1, pp: 7, name: 'GEG', surname: 'PIP', yr: 62) }

    it 'nullifies associations', fast: true do
      obj.marks.create(marks_id: 3, students_id: 1, students_pp: 7, mark: 4)
      Mark.create(marks_id: 4, students_id: 1, students_pp: 7, mark: 5)

      obj.scholarships.create(scholar_id: 3, students_id: 1, students_pp: 7, scholarship: 5000)
      Scholarship.create(scholar_id: 4, students_id: 1, students_pp: 7, scholarship: 4000)

      obj.delete

      marks_rows = query('SELECT * FROM marks WHERE marks_id = 3 or marks_id = 4')
      scholarships_rows = query('SELECT * FROM scholarships WHERE scholar_id = 3 or scholar_id = 4')

      expected_mark_rows = [[3, nil, nil, 4], [4, nil, nil, 5]]
      expected_scholarship_rows = [[3, nil, nil, 5000], [4, nil, nil, 4000]]

      marks_rows.zip(expected_mark_rows).each do |mr, emr|
        expect(mr).to match_array emr
      end

      scholarships_rows.zip(expected_scholarship_rows).each do |sr, esr|
        expect(sr).to match_array esr
      end
    end
  end

  context 'destoy' do
    before do
      MyOrm::Connection.establish_connection ':memory:'
      MyOrm::Record.populate_students

      class Student < MyOrm::Record
        has_many :Mark, dependent: :destroy
        has_many :Scholarship, dependent: :destroy
      end

      class Mark < MyOrm::Record
      end

      class Scholarship < MyOrm::Record
      end
    end

    let(:obj) { Student.new(id: 1, pp: 7, name: 'GEG', surname: 'PIP', yr: 62) }

    it 'destroys associations' do
      obj.marks.create(marks_id: 3, students_id: 1, students_pp: 7, mark: 4)
      Mark.create(marks_id: 4, students_id: 1, students_pp: 7, mark: 5)

      obj.scholarships.create(scholar_id: 3, students_id: 1, students_pp: 7, scholarship: 5000)
      Scholarship.create(scholar_id: 4, students_id: 1, students_pp: 7, scholarship: 4000)

      obj.delete

      marks_rows = query('SELECT * FROM marks WHERE marks_id = 3 or marks_id = 4')
      scholarships_rows = query('SELECT * FROM scholarships WHERE scholar_id = 3 or scholar_id = 4')

      puts marks_rows

      expect(marks_rows).to be_empty
      expect(scholarships_rows).to be_empty
    end
  end

  context 'restrict_with_exception' do
    before do
      MyOrm::Connection.establish_connection ':memory:'
      MyOrm::Record.populate_students

      class Student < MyOrm::Record
        has_many :Mark, dependent: :restrict_with_exception
      end

      class Mark < MyOrm::Record
      end
    end

    let(:obj) { Student.new(id: 1, pp: 7, name: 'GEG', surname: 'PIP', yr: 62) }

    it 'calls restrict_exception' do
      mark = obj.marks.create(marks_id: 3, students_id: 1, students_pp: 7, mark: 4)

      expect { obj.delete }.to raise_error MyOrm::RestrictException

      mark.delete

      expect { obj.delete }.not_to raise_error
    end
  end
end