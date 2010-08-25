require 'helper'

DB_DIRECTORY = File.expand_path(File.join(*%w[ .. tmp ]), File.dirname(__FILE__))

unless (File.exist?(DB_DIRECTORY))
  Dir.mkdir(DB_DIRECTORY)
end

DB = Sequel.sqlite(File.expand_path('test.sqlite3', DB_DIRECTORY))

require 'models/model_triggers'
require 'models/example'
require 'models/conditional'

class TestSequelSimpleCallbacks < Test::Unit::TestCase
  def test_model_can_be_created
    model = ExampleModel.new
    
    assert model.triggers_active?
    
    assert_equal [ :after_initialize ], model.triggered

    model.save
    
    assert_equal [ :after_initialize, :before_validation, :before_validation_on_create, :after_validation, :after_validation_on_create, :before_save, :before_create, :after_create, :after_save ], model.triggered
    
    model.clear_triggered!
    
    assert_equal [ ], model.triggered
    
    assert model.id
    
    model.name = 'Test'
    
    model.save

    assert_equal [ :before_validation, :before_validation_on_update, :after_validation, :after_validation_on_update, :before_save, :before_update, :after_update, :after_save ], model.triggered
  end

  def test_model_triggers_can_be_turned_off
    model = ExampleModel.new(:name => 'off')
    
    assert !model.triggers_active?
    
    assert_equal [ ], model.triggered

    model.save
    
    assert_equal [ ], model.triggered
    
    model.clear_triggered!
    
    assert_equal [ ], model.triggered
    
    assert model.id
    
    model.name = 'Test'
    
    model.save

    assert_equal [ :before_validation, :before_validation_on_update, :after_validation, :after_validation_on_update, :before_save, :before_update, :after_update, :after_save ], model.triggered
    
    model = ExampleModel.find(:id => model.id)
  end
  
  def test_model_conditional_triggers
    model = ConditionalModel.new
    
    assert_equal [ ], model.triggered
    
    model.save
    
    assert !model.new?
    
    assert_equal [ :before_validation_with_model, :before_validation_without_model, :after_validation_only_on_create, :before_save_with_nil, :before_save_with_true_false ], model.triggered
  end
end
