require 'sqlite3'

module Selection
  def find(*ids)
    ids.each do |id|
      unless id.is_a?(Integer) && id > 0
        raise ArgumentError.new("Only positive integers are allowed")
      end
    end
    if ids.length == 1
      find_one(ids.first)
    else
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        WHERE id IN (#{ids.join(",")});
      SQL

      rows_to_array(rows)
    end
  end

  def find_one(id)
    unless id.is_a?(Integer) && id > 0
      raise ArgumentError.new("Only positive integers are allowed")
    end
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE id = #{id};
    SQL

  end

  def find_by(attribute, value)
    unless attribute.is_a?(String)
      raise ArgumentError.new("Only strings are allowed for attribute agruments")
    end
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE #{attribute} = #{BlocRecord::Utility.sql_strings(value)};
    SQL

    rows_to_array(rows)
  end

  def method_missing(m, value)
    full_string = m
    full_string.slice("find_by")
    find_by(full_string, value)
  end


  def find_each(start, batch_size)
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE id >= #{start}
      LIMIT #{batch_size}
    SQL

    all_rows = rows_to_array(rows)
    all_rows.each do |row|
      yield
    end
  end

  def find_in_batches(start, batch_size)
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      WHERE id >= #{start}
      LIMIT #{batch_size}
    SQL
    yield(rows_to_array(rows))

  end

  def take(num=1)
    unless num.is_a?(Integer) && num > 0
      raise ArgumentError.new("Only positive integers are allowed")
    end
    if num > 1
      rows = connection.execute <<-SQL
        SELECT #{columns.join ","} FROM #{table}
        ORDER BY random()
        LIMIT #{num};
      SQL

      rows_to_array(rows)
    else
      take_one
    end
  end

  def take_one
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY random()
      LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def first
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id ASC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def last
    row = connection.get_first_row <<-SQL
      SELECT #{columns.join ","} FROM #{table}
      ORDER BY id DESC LIMIT 1;
    SQL

    init_object_from_row(row)
  end

  def all
    rows = connection.execute <<-SQL
      SELECT #{columns.join ","} FROM #{table};
    SQL

    rows_to_array(rows)
  end


  private

  def init_object_from_row(row)
    if row
      data = Hash[columns.zip(row)]
      new(data)
    end
  end

  def rows_to_array(rows)
    rows.map { |row| new(Hash[columns.zip(row)]) }
  end
end
