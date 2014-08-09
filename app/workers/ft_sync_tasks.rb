class FtSyncTasks

  include Sidekiq::Worker

  def perform(app_id, rows)
    App.find(app_id).add_task(rows)
  end
end