class Api::V1::TasksController < Api::V1::ApplicationController
  def show
    task = Task.find(params[:id])

    respond_with(task, serializer: TaskSerializer)
  end

  def index
    tasks = Task.order(updated_at: :desc).ransack(ransack_params).
      result.
      page(page).
      per(per_page)

    respond_with(tasks, each_serializer: TaskSerializer, root: 'items', meta: build_meta(tasks))
  end

  def create
    task = current_user.my_tasks.new(task_params)

    if task.save
      UserMailer.with({ user: current_user, task: task }).task_created.deliver_later
    end

    respond_with(task, serializer: TaskSerializer, location: nil)
  end

  def update
    task = Task.find(params[:id])

    if task.update(task_params)
      user = User.find(task.assignee_id)
      UserMailer.with({ user: user, task: task }).task_updated.deliver_later
    end

    respond_with(task, serializer: TaskSerializer)
  end

  def destroy
    task = Task.find(params[:id])

    if task.destroy
      user = User.find(task.assignee_id)
      UserMailer.with({ user: user, task: task }).task_destroyed.deliver_later
    end

    respond_with(task)
  end

  private

  def task_params
    params.require(:task).permit(:name, :description, :assignee_id, :state_event)
  end
end
