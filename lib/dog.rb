require 'pry'
class Dog

attr_accessor :id, :name, :breed

def initialize(id: nil, name:, breed:)
  @name = name
  @breed = breed
  @id = id
end 

def self.create_table
  DB[:conn].execute("CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);")
end 

def self.drop_table
  DB[:conn].execute("DROP table dogs;")
end

def self.new_from_db(array)
  new_dog = Dog.new(id: array[0], name: array[1], breed: array[2])
end

def self.find_by_name(name)
 DB[:conn].execute('SELECT * FROM dogs WHERE name = ?;', name).map do |row|
   self.new_from_db(row)
 end.first
end 

def update
  DB[:conn].execute('UPDATE dogs SET name =? WHERE id =?;', name, id)
end 

def save
  DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?);", self.name, self.breed)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  return self
end 

def self.create(hash) #{:name=>"Ralph", :breed=>"lab"}
  new_dog = Dog.new(hash)
  new_dog.save
  new_dog
end 

def self.find_by_id(id)
  DB[:conn].execute('SELECT * FROM dogs WHERE id = ?;', id).map do |row|
    self.new_from_db(row)
  end.first
end

def self.find_or_create_by(name:, breed:)
  dog = DB[:conn].execute('SELECT * FROM dogs WHERE name=? AND breed=?;',name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0],name: dog_data[1],breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
end 

end 