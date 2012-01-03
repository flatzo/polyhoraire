require 'poly/auth'
require 'test/unit'

class TestAuth < Test::Unit::TestCase
  def test_connect
    assert_nothing_raised do
      auth = Poly::Auth.new
      
      user      = $config['credentials']['user']
      password  = $config['credentials']['password']
      bday      = $config['credentials']['bday']
      
      auth.connect(user,password,bday)
    end
  end
end
