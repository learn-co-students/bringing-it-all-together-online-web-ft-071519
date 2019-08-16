class Dog
    attr_accessor :name, :breed, :id

    def initialize(attributes)
        attributes.each {|key, value| self.send(("#{key}="), value)}
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE dogs;"
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
            SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(attributes)
        dog = self.new(attributes)
        dog.save
    end

    def self.new_from_db(row)
        attributes = {name: row[1], breed: row[2], id: row[0]}
        self.new(attributes)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL
        row = DB[:conn].execute(sql, id)[0]
        self.new_from_db(row)
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL
        row = DB[:conn].execute(sql, name)[0]
        self.new_from_db(row)
    end

    def self.find_or_create_by(attributes)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        row = DB[:conn].execute(sql, attributes[:name], attributes[:breed])
        if !row.empty?
            # binding.pry
            dog_data = row[0]
            dog = self.new({name: dog_data[1], breed: dog_data[2], id: dog_data[0]})
        else
            dog = self.create(attributes)
        end
        dog
    end

end