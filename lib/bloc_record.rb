module BlocRecord
  def self.connect_to(filename, variable)
    # handle extra variable
    @database_filename = filename
    @db_type = variable
  end

  def self.database_filename
    @database_filename
  end
end
