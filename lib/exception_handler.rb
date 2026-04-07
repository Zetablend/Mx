module ExceptionHandler
  class InvalidToken < StandardError; end
  class ExpiredToken < StandardError; end
end
