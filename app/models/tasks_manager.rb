class TasksManager

  def initialize(app)
    @app = app
  end

  def perform(context)
    tasks = @app.tasks.available.not_done_by_username(context[:current_username])

    # if random order
    if (context[:random])
      tasks = tasks.where('tasks.input_task_id!=?', context[:from_task]) unless (context[:from_task].blank?)
      task = tasks.order('random() ').first
    else
      tasks = tasks.where('tasks.input_task_id > ?', context[:from_task]) unless (context[:from_task].blank?)
      task = tasks.order('tasks.input_task_id asc').first
    end
    return nil if (task.nil?)
    task
  end

end