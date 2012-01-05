require 'poly/auth'
require 'test/unit'
require 'yaml'

class TestAuth < Test::Unit::TestCase
  def setup
    @config = YAML.load_file("conf/test_poly.yaml")
  end
  
  def test_connect
    assert_nothing_raised do
      auth = Poly::Auth.new
      
      user      = @config['credentials']['user']
      password  = @config['credentials']['password']
      bday      = @config['credentials']['bday']
      
      auth.connect(user,password,bday)
    end
  end
end
