class TasksManagerFree

  def initialize(app)
    @app = app
  end

  def perform(context)
    tasks = @app.tasks.not_done_by_username(context[:current_username])
    tasks=tasks.where('tasks.input_task_id > ?', context[:from_task]) unless (context[:from_task].blank?)
    task=tasks.order('tasks.input_task_id asc').first
    return nil if (task.nil?)
    task
  end

end