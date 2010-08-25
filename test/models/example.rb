if (DB.table_exists?(:examples))
  DB.drop_table(:examples)
end

DB.create_table(:examples) do
  primary_key :id
  string :name
end  

class ExampleModel < Sequel::Model(:examples)
  include ModelTriggers
  
  plugin SequelSimpleCallbacks

  SequelSimpleCallbacks::INSTALLABLE_HOOKS.each do |hook|
    send(hook, :"do_#{hook}", :if => :triggers_active?)
    
    define_method(:"do_#{hook}") do
      trigger(hook)
    end
  end
  
  def triggers_active?
    !name or name != 'off'
  end
end
