require 'sqlite3'

module Connection
  def connection
    if @db_type == :sqlite3
      @connection ||= SQLite3::Database.new(BlocRecord.database_filename)
    else
      @connection ||= PG::Connection.new(BlocRecord.database_filename)
    end
  end
end
