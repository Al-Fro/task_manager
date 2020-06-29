require 'test_helper'

class Api::V1::TasksControllerTest < ActionController::TestCase
  test 'should get show' do
    author = create(:user)
    task = create(:task, author: author)
    get :show, params: { id: task.id, format: :json }
    assert_response :success
  end

  test 'should get index' do
    get :index, params: { format: :json }
    assert_response :success
  end

  test 'should post create' do
    author = create(:user)
    sign_in(author)
    assignee = create(:user)
    task_attributes = attributes_for(:task).
      merge({ assignee_id: assignee.id })
    post :create, params: { task: task_attributes, format: :json }
    assert_response :created

    data = JSON.parse(response.body)
    created_task = Task.find(data['task']['id'])

    assert_equal task_attributes.stringify_keys, created_task.slice(*task_attributes.keys)
  end

  test 'should put update' do
    author = create(:user)
    assignee = create(:user)
    task = create(:task, author: author)
    task_attributes = attributes_for(:task).
      merge({ author_id: author.id, assignee_id: assignee.id }).
      stringify_keys

    patch :update, params: { id: task.id, format: :json, task: task_attributes }
    assert_response :success

    task.reload
    assert_equal task.slice(*task_attributes.keys), task_attributes
  end

  test 'should delete destroy' do
    author = create(:user)
    task = create(:task, author: author)
    delete :destroy, params: { id: task.id, format: :json }
    assert_response :success

    assert !Task.where(id: task.id).exists?
  end

  test 'should put attach_image' do
    author = create :user
    task = create :task, author: author
  
    image = file_fixture('image.jpeg')
    attachment_params = {
      image: fixture_file_upload(image, 'image/jpeg'),
      crop_x: 190,
      crop_y: 100,
      crop_width: 300,
      crop_height: 300,
    }
  
    put :attach_image, params: { id: task.id, attachment: attachment_params, format: :json }
    assert_response :success
  
    task.reload
    assert { task.image.attached? }
  end
  
  test 'should put remove_image' do
    author = create :user
    task = create :task, author: author
  
    image = file_fixture('image.jpeg')
    attachable_image = fixture_file_upload(image)
  
    task.image.attach(attachable_image)
  
    put :remove_image, params: { id: task.id, format: :json }
    assert_response :success
  
    task.reload
    refute { task.image.attached? }
  end

  def after_teardown
    super
  
    remove_uploaded_files
  end
  
  def remove_uploaded_files
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
end
