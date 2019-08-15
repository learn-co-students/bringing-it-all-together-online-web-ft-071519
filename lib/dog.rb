require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end
  
  def self.create_table
    sql = <<-SQL
          CREATE TABLE IF NOT EXISTS dogs(
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT)
          SQL
    DB[:conn].execute(sql)
  end
  
  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end
  
  def save
    sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
          SQL
          
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    self
  end
  
  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
  end
  
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    self.new(id: id, name: name, breed: breed)
  end
  
  def self.find_by_id(id)
    #use sql to find if id exists in database
    #if it does, grab this row as a var and pass it into self.new_from_db(row)
    sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE id = ?
          SQL
    row = DB[:conn].execute(sql, id)[0]
    self.new_from_db(row)
  end
  
  
  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    
    if dog.empty?
      new_dog = self.create(name: name, breed: breed)
      new_dog
    else
      new_dog = self.new(id: dog[0][0], name: dog[0][1], breed: dog[0][2])
      new_dog
    end
  end
  
  
  def self.find_by_name(name)
    sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?
          SQL
          
    info = DB[:conn].execute(sql, name)[0]
    self.new_from_db(info)
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
  
  
end
