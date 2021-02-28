class ActionDispatch::DebugExceptions
  alias_method :old_log_error, :log_error
  def log_error(env, wrapper)
    if Rails.env.production? && wrapper.exception.is_a? ActionController::RoutingError
      return
    else
      old_log_error env, wrapper
    end
  end
end