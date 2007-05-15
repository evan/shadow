
module ActiveRecord

  Schema.define(:version => 0) do
    create_table :cats, :force => true do |t|
      t.column :name, :string
      t.column :size, :integer
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end
  
    create_table :dogs, :force => true do |t|
      t.column :name, :string
      t.column :size, :integer
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end
  end

  class Dog < Base; end
  class Cat < Base; end
  
  Dog.create(:name => "Rover", :size => 5)
  Cat.create(:name => "Blue", :size => 3)

end
