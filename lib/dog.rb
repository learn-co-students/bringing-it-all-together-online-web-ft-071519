require 'pry'

class Dog
  
  
  attr_accessor :name, :breed
  attr_reader :id
  
  def initialize(name: ,breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs(
      id INTEGER PRIMERY KEY,
      name TEXT,
      breed TEXT
      )
    SQL
    
    DB[:conn].execute(sql)
  end
    
    
  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    
    DB[:conn].execute(sql)      
  end
  
  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs(name,breed)
        VALUES (?,?)
      SQL
      
      DB[:conn].execute(sql,self.name,self.breed)   
      
      Dog.new(name: DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][1],breed: DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][2],
      id: DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0])
    end
  end
  
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
        Dog.new(name: DB[:conn].execute(sql, self.name, self.breed, self.id)[0][1],breed: DB[:conn].execute(sql, self.name, self.breed, self.id)[0][2],
      id: DB[:conn].execute(sql, self.name, self.breed, self.id)[0][0])
  end
  
  def self.create(hash)
    dog = Dog.new(name: hash[:name],breed: hash[:breed])
    dog.save
    dog
  end
  
  def self.new_from_db(row)
    dog = Dog.new(name: row[1],breed: row[2], id: row[0])
  end
  
  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    DB[:conn].execute(sql, id)[0]
  end
  
end