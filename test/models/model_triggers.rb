module ModelTriggers
  def clear_triggered!
    @triggered = [ ]
  end
  
  def trigger(type)
    @triggered ||= [ ]
    @triggered << type
  end
  
  def triggered
    @triggered ||= [ ]
  end
  
  def triggered?(type)
    @triggered and @triggered.include?(type)
  end
end
