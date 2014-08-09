class Task < ActiveRecord::Base

  belongs_to :app

  has_many :answers, :dependent => :destroy

  validates :input_task_id, :uniqueness => {:scope => :app_id}
  attr_accessible :state, :input_task_id, :app_id, :gold_answer, :answers

  scope :available, lambda {
    joins(:answers).where("answers.state = ?", Answer::STATE[:AVAILABLE])
  }

  scope :done_by_username, lambda { |username|
    joins(:answers=>:user).where("answers.state!=?", Answer::STATE[:AVAILABLE]).where("users.username=?", username)
  }

  scope :not_done_by, lambda { |user|
    tasks_done_ids=Task.joins(:answers).where("answers.user_id=?", user)
    unless (tasks_done_ids.empty?)
      where("#{self.table_name}.id not in (?)", tasks_done_ids)
    end
  }

  scope :not_done_by_username, lambda { |username|
    # not optimized
    tasks_done_ids=Task.joins(:answers=>:user).where("answers.state!=?", Answer::STATE[:AVAILABLE]).where("users.username=?", username)
    unless (tasks_done_ids.empty?)
      where("#{self.table_name}.id not in (?)", tasks_done_ids)
    end
  }

  def done_by?(user)
    self.answers.where("answers.user_id=?",user).count!=0
  end

  def completion_ratio
    completed, size = self.completion
    completed.to_f/size.to_f
  end

  def completion
    completed = self.answers.answered.count
    size = self.answers.count
    [completed, size]
  end

  def to_param
    input_task_id
  end

  def as_json(params = {})
    answer = self.answers.available.first
    {
      :id => self.input_task_id,
      :created_at => self.created_at,
      :gftable => {
        :ft_task_column => self.app.task_column,
        :ft_table => self.app.challenges_table_id
      } ,
      :answer_id => (answer.nil?)? nil : answer.id
    }
  end

end
