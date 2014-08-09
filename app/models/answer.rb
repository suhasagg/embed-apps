class Answer < ActiveRecord::Base

  STATE = {
    AVAILABLE: 0,
    COMPLETED: 2
  }

  belongs_to :user, :touch => true
  belongs_to :task
  has_one :app, :through => :task

  scope :available, where(:state => STATE[:AVAILABLE])
  scope :not_available, where("state != ?", STATE[:AVAILABLE])
  scope :answered, where(:state => STATE[:COMPLETED])
  scope :to_synchronize, answered.where(:ft_sync=>false)


  #any kind of answer e.g string , json
  # interpreted by the related aggregator
  attr_accessible :state, :answer, :user, :ft_sync

  def done_by?(user)
    self.user != user
  end

  # if some fields are not present
  # we enriched the answers with default values
  def input_from_form(rows)
    default_options = {
      "task_id" => self.task.input_task_id,
      "answer_id" => self.id,
      "user_id" => self.user.username,
      "created_at" => DateTime.now
    }
    self.answer = rows.map { |row|
      row.merge(default_options) { |key, v1, v2| v1 }
    }.to_json
  end

  # as fusion table row
  def as_ft_row()
    begin
      ActiveSupport::JSON.decode(self.answer)
    rescue
      YAML::load(self.answer)
    end
  end

  def as_json(options = {})
    {
      :user => (self.user.nil?)? nil : self.user.username,
      :updated_at => self.updated_at,
      :content => self.answer,
      :state => STATE.invert[state]
    }
  end
end
