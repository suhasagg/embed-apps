class FtSyncAnswers

  include Sidekiq::Worker

  def perform(app_id)
		App.find(app_id).sync_answers()
  end
end