# OS helpers.
module OS
  module_function

  # Returns false if the current OS is not Mac OS X.
  def mac?
    RUBY_PLATFORM.downcase.include? 'darwin'
  end
end
