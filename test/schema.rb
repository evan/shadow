
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

  class Cat < Base; end
  Cat.create(:name => "Blue", :size => 3)
  Cat.create(:name => "Tom", :size => 6)
  
  class Dog < Base; end
  Dog.create(:name => "Rover", :size => 5)
  Dog.create(:name => "Spot", :size => 5)

end
