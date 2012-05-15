module SequelSimpleCallbacks
  SPECIAL_HOOKS = [
    :before_validation,
    :after_validation
  ].freeze

  ADDITIONAL_HOOKS = [
    :before_validation_on_create,
    :before_validation_on_update,
    :after_validation_on_create,
    :after_validation_on_update
  ].freeze
  
  STANDARD_HOOKS = (Sequel::Model::HOOKS - SPECIAL_HOOKS).freeze
  INSTALLABLE_HOOKS = (Sequel::Model::HOOKS + ADDITIONAL_HOOKS).freeze
  
  def self.apply(model_class)
  end
  
  def self.configure(model_class, *arguments, &block)
    self.define_callback_hooks(model_class)
  end

  def self.define_callback_hooks(model_class)
    STANDARD_HOOKS.each do |hook|
      pre_hook = nil

      if (model_class.instance_methods.include?(hook))
        pre_hook = :"_internal_#{hook}"

        model_class.send(:alias_method, pre_hook, hook)
      end

      model_class.send(:define_method, hook) do
        self.class.run_callbacks(self, hook)

        self.send(pre_hook) if (pre_hook)
      end
    end

    SPECIAL_HOOKS.each do |hook|
      model_class.send(:define_method, hook) do
        self.class.run_callbacks(self, hook)

        if (new?)
          self.class.run_callbacks(self, :"#{hook}_on_create")
        else
          self.class.run_callbacks(self, :"#{hook}_on_update")
        end
      end
    end
  end

  module ClassMethods
    # Add a callback hook to the model with parameters:
    # * :if => One of [ Symbol, Proc ] (optional)
    # * :unless => One of [ Symbol, Proc ] (optional)
    # * :on => One of [ :create, :update ] (optional)
    
    def add_callback(chain, *args, &block)
      @callbacks ||= { }
      callbacks = @callbacks[chain] ||= [ ]

      # Extract the options from the arguments by testing if the last
      # is a Hash, otherwise default to an empty set.
      options = (args[-1].is_a?(Hash)) ? args.pop : { }
      option_on = options[:on]
      option_if = options[:if]
      option_unless = options[:unless]

      callbacks << lambda do |model|
        result = nil
        
        trigger =
          case (option_on)
          when :create
            model.new?
          when :update
            !model.new?
          when nil
            true
          else
            false
          end
        
        if (trigger and !option_if.nil?)
          trigger =
            case (option_if)
            when Symbol, String
              model.send(option_if)
            when Proc
              if (option_if.arity == 0)
                model.instance_eval(option_if)
              else
                option_if.call(model)
              end
            else
              option_if
            end
        end

        if (trigger and !option_unless.nil?)
          trigger =
            case (option_unless)
            when Symbol, String
              !model.send(option_unless)
            when Proc
              if (option_unless.arity == 0)
                !model.instance_eval(option_unless)
              else
                !option_unless.call(model)
              end
            else
              !option_unless
            end
        end
        
        if (trigger)
          args.each do |callback|
            result =
              case (callback)
              when Symbol, String
                model.send(callback)
              else
                if (callback.arity == 0)
                  model.instance_eval(callback)
                else
                  callback.call(model)
                end
              end
            
            break if (false === result)
          end
        end
        
        if (trigger and block)
          if (block.arity == 0)
            model.instance_eval(&block)
          else
            block.call(model)
          end
        end
        
        result
      end
    end

    def run_callbacks(model, hook)
      return unless (@callbacks)
      
      callbacks = @callbacks[hook]
      
      return unless (callbacks)
      
      result = nil
      
      callbacks.each do |callback|
        result = callback.call(model)
        
        break if (result === false)
      end
      
      result
    end

    INSTALLABLE_HOOKS.each do |hook|
      eval %Q[
        def #{hook}(*args, &block)
          add_callback(:#{hook}, *args, &block)
        end
      ]
    end
  end

  module InstanceMethods
    # This method is provided as a simple method to call arbitrary callback
    # chains without having to run through the specific method
    def run_callbacks(hook)
      self.class.run_callbacks(self, hook)
    end
  end
  
  module DatasetMethods
  end
end
