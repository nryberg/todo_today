class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy, :complete, :uncomplete]

  def index
    @tasks = sorted_tasks
  end

  def show
  end

  def new
    @task = Task.new
  end

  def create
    @task = current_user.tasks.build(task_params)

    if @task.save
      redirect_to tasks_path, notice: "Task was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to tasks_path, notice: "Task was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: "Task was successfully deleted."
  end

  def complete
    completion = @task.task_completions.create!(completed_at: Time.current)
    logger.info "Created TaskCompletion #{completion.id} for Task #{@task.id} at #{completion.completed_at}"

    respond_to do |format|
      format.html { redirect_to tasks_path, notice: "Task completed! (#{completion.completed_at.strftime('%I:%M %p')})" }
      format.turbo_stream do
        @tasks = sorted_tasks
      end
    end
  end

  def uncomplete
    @task.task_completions.today.destroy_all

    respond_to do |format|
      format.html { redirect_to tasks_path, notice: "Task marked as incomplete." }
      format.turbo_stream do
        @tasks = sorted_tasks
      end
    end
  end

  def reset_all
    # Get all tasks that are completed today for current user
    completed_tasks = current_user.tasks.joins(:task_completions)
                                       .where(task_completions: {
                                         completed_at: Date.current.beginning_of_day..Date.current.end_of_day
                                       })
                                       .distinct

    # Delete all today's completions for current user's tasks
    TaskCompletion.joins(:task)
                  .where(tasks: { user_id: current_user.id })
                  .where(completed_at: Date.current.beginning_of_day..Date.current.end_of_day)
                  .destroy_all

    count = completed_tasks.count
    message = if count == 0
                "No completed tasks to reset."
              elsif count == 1
                "Reset 1 task to undone."
              else
                "Reset #{count} tasks to undone."
              end

    respond_to do |format|
      format.html { redirect_to tasks_path, notice: message }
      format.turbo_stream do
        @tasks = sorted_tasks
        flash.now[:notice] = message
      end
    end
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:name)
  end

  def sorted_tasks
    current_user.sorted_tasks
  end
end
