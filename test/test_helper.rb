#Spork.prefork do 
  ENV["RAILS_ENV"] = "test"
  require File.expand_path('../../config/environment', __FILE__)
  require 'rails/test_help'
  require 'webmock/test_unit'
  require 'pp'
#end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
 # fixtures :all
 include ActionDispatch::TestProcess

  # Add more helper methods to be used by all tests here...
  def process_array(builder, arry)
  arry.each do |value|
    if value.is_a?(Hash)
        process_hash(builder, value)
    elsif value.is_a?(Array)

        process_array(builder, value)
    else
      builder.__send__(value)
    end
  end
end

def process_hash(builder, hsh)
  hsh.each do |key, value|
    if value.is_a?(Hash)
      builder.__send__(key) do
        process_hash(builder, value)    
      end
    elsif value.is_a?(Array)
      builder.__send__(key) do
        process_array(builder, value)
      end
    else
      builder.__send__(key, value)
    end  
      
  end

end

def build_xml_from_hash(hash)
  builder = Builder::XmlMarkup.new
  process_hash(builder, hash)
  builder.target!
end
end
#require 'mocha'
