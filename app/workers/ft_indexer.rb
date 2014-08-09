class FtIndexer

  MAX_ANSWERS = 10000
  MAX_TASKS = 10000

  include Sidekiq::Worker

  def perform(app_id)
    app = App.find(app_id)
    index_tasks(app)
  end

  def index(task_id, app_id, redundancy = 0)
  	task = Task.create(input_task_id: task_id, app_id: app_id)
    if (redundancy > 0)
    	redundancy.times do
        task.answers << Answer.create!(state: Answer::STATE[:AVAILABLE])
      end
    end
    task.save
    task
  end

  def index_tasks(app)
    i = 0
    app.update_attribute(:status, App::STATE[:INDEXING])
    app.tasks.destroy_all
    Task.transaction do
      FusionTable.new(app.challenges_table_id).import(app.task_column) do |task_id|
        unless task_id.blank?
        	index(task_id, app.id, app.redundancy = 0)
          i = i + 1
          break if (i > MAX_ANSWERS)
        end
      end
    end
    app.update_attribute(:status, App::STATE[:READY])
  end

end