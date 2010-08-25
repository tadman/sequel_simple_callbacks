if (DB.table_exists?(:conditionals))
  DB.drop_table(:conditionals)
end

DB.create_table(:conditionals) do
  primary_key :id
  string :name
end  

class ConditionalModel < Sequel::Model(:conditionals)
  include ModelTriggers
  plugin SimpleSequelCallbacks

  before_validation do |model|
    model.trigger(:before_validation_with_model)
  end

  before_validation do
    trigger(:before_validation_without_model)
  end

  after_validation :on => :create do
    trigger(:after_validation_only_on_create)
  end

  before_save :if => nil, :unless => nil do
    trigger(:before_save_with_nil)
  end

  before_save :if => true, :unless => false do
    trigger(:before_save_with_true_false)
  end

  after_update :only => :never do
    trigger(:after_update_never_called)
  end

  after_save :if => false do
    trigger(:after_save_not_called)
  end
  
  def never
    false
  end
end
