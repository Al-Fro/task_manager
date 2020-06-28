require 'test_helper'

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  test 'should get new' do
    get new_password_reset_path
    assert_response :success
  end

  test 'should get create' do
    user = create(:user)
    attrs = {
      email: user.email,
    }
    
    assert_emails 1 do
      post password_resets_path, params: { password_reset_form: attrs }
    end

    assert_response :redirect
  end  

  test 'should get edit' do
    user = create(:user)
    user.generate_password_token!

    get edit_password_reset_path(user.password_reset_token)
    assert_response :success
  end

  test 'should get update' do
    user = create(:manager)
    user.generate_password_token!
    attrs = {
      password: '123456',
      password_confirmation: '123456',
    }

    patch password_reset_path(user.password_reset_token), params: { manager: attrs }
    assert_response :redirect
  end
end
