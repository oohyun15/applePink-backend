class CustomFormatter < Logger::Formatter
  def call(severity, time, progname, msg)                                       
    "| #{severity.ljust(5)} | [#{time}] #{msg}\n"
  end                                                                           
end
