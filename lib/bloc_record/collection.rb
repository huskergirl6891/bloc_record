module BlocRecord
  class Collection < Array
    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def take(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.take : false
    end

    def where(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.where(updates)
    end

    def not(args)
      # store value from argument hash into temp variable (array)
      temp_value = args.values
      # get value of first item (string) in array
      new_value = temp_value[0]
      # add to string so SQL query inverts the where search
      final_value = "!=" + new_value
      self.any? ? self.first.class.where(final_value)
    end
  end
end
