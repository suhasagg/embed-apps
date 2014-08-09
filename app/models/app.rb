class App < ActiveRecord::Base

  STATE = {
    READY: 0,
    INDEXING: 2
  }

  GOOGLE_TABLE_REG = /https:\/\/www\.google\.com\/fusiontables\/DataSource\?docid=(.+)/
  GIST_REG = /https:\/\/gist\.github.com\/(\d{4,})/

  # BASIC APP
  # with basic challenges and answers tables
  # TO MOVE as template
  BASIC_APP_GIST_ID = 3543287
  BASIC_APP_CHALLENGES_TABLE_ID = "1s6M2D5zZ5SC-kAvD5uJWHKEIeuivG_my9NbhkgA"
  BASIC_APP_ANSWERS_TABLE_ID = "17WOhmCa0DtVhGCcxDODljcbrZvLaJM8lURz4Tu4"


  has_many :tasks, :dependent => :destroy
  has_many :answers, :through => :tasks
  has_many :contributors, :through => :answers, :source => :user, :uniq => true
  belongs_to :user

  validates_presence_of :name
  validates_presence_of :challenges_table_url
  validates_presence_of :answers_table_url
  validates_presence_of :gist_url
  validates_presence_of :task_column

  validates_format_of :challenges_table_url, :with => GOOGLE_TABLE_REG
  validates_format_of :answers_table_url, :with => GOOGLE_TABLE_REG
  validates_format_of :gist_url, :with => GIST_REG

  attr_accessible :name,
                  :description,
                  :answers_table_url,
                  :challenges_table_url,
                  :gist_url,
                  :task_column,
                  :script,
                  :redundancy,
                  :iframe_width,
                  :iframe_height,
                  :state,
                  :image_url,
                  :user_id

  before_validation :complete_with_default_values
  after_create :post_processing

  def complete_with_default_values
    self.gist_url = Gist.new(BASIC_APP_GIST_ID).clone.url if gist_url.blank?
    self.answers_table_url = FusionTable.new(BASIC_APP_ANSWERS_TABLE_ID).clone(user.email).url if answers_table_url.blank?
    if challenges_table_url.blank?
      self.challenges_table_url = FusionTable.new(BASIC_APP_CHALLENGES_TABLE_ID ).clone(user.email).url
      self.task_column = "task_id"
      self.add_task([{input: "Hello world"}])
    end
    self.image_url = "http://payload76.cargocollective.com/1/2/88505/3839876/02_nowicki_poland_1949.jpg" if image_url.blank?
  end

  def post_processing
    download_source_code
    index_tasks
  end

  # delete all answers without
  # deleting the challenges
  def delete_answers
    ActiveRecord::Base.connection.execute("DELETE FROM answers WHERE answers.id in (SELECT answers.id from answers inner join tasks on answers.task_id = tasks.id inner join apps on tasks.app_id = apps.id where apps.id = #{self.id})")
    FusionTable.new(answers_table_url).drop()
  end

  def clone
    App.create(name:  "Copy of #{name}",
      description: "copy of #{description}",
      challenges_table_url: FusionTable.new(challenges_table_id).clone.url,
      answers_table_url: FusionTable.new(answers_table_id).clone.url,
      gist_url: Gist.new(gist_id).clone.url,
      redundancy: redundancy,
      iframe_width: iframe_width,
      iframe_height: iframe_height)
  end

  def index_tasks
   if Rails.env == "production"
      FtIndexer.perform_async(self.id)
    else
      FtIndexer.new().perform(self.id)
    end
  end

  def add_task(data)
    ft = FusionTable.new(challenges_table_id)
    taskIndexer = FtIndexer.new()

    task_id = next_generated_task_id
    data.each { |row|
      row[self.task_column] = task_id # we fill the new task_ID
      ft.add_row(row)
    }
    ft.flush

    # add the task as it was just indexed
    taskIndexer.index(task_id, id, redundancy)
  end

  def sync_answers
    ft = FusionTable.new(answers_table_id)
    self.answers.merge(Answer.to_synchronize).each { |answer|
      ft_row = answer.as_ft_row
      if (ft_row.is_a? Array)
        ft_row.each { |row| ft.add_row(row) }
      else
        ft.add_row(ft_row)
      end
      answer.update_attributes({ft_sync: false});
    }
    ft.flush
  end

  def upload_source_code
    Gist.new(gist_id).script = script
  end

  def download_source_code
    self.update_attributes(script: Gist.new(gist_id).script)
  end

  def next_task(context)
    task_manager.perform(context)
  end

  ########## PERSISTENCE AND MODEL ATTRIBUTE #################

  def task_manager
    #choice of the task manager
    (redundancy <= 0)? TasksManagerFree.new(self) : TasksManager.new(self)
  end

  def gist_id
    GIST_REG.match(gist_url)[1] unless gist_url.nil?
  end

  def answers_table_id
    gf_table_id(answers_table_url)
  end

  def challenges_table_id
    gf_table_id(challenges_table_url)
  end

  def last_contributor(max_contributors = 5)
    self.answers.answered.order("answers.updated_at desc").limit(max_contributors)
  end

  def self.create_ft_table(table_name, schema)
    FusionTable.create(table_name, schema, true, self.user.email).url
  end

  def schema
    FusionTable.new(answers_table_url).schema
  end

  def completion
    {completed: self.answers.answered.count,
      total: self.answers.count || 0}
  end

  def next_generated_task_id
    last_known_task = self.tasks.order('input_task_id desc').first
    (last_known_task.nil?)? 1 : last_known_task.input_task_id + 1
  end

protected

  def gf_table_id(gf_table_url)
     GOOGLE_TABLE_REG.match(gf_table_url)[1]
  end

  def clone_answers_table
    clone_table_id = FtDao.clone_table(answers_table_id,"Answers Table", user.email)
    "https://www.google.com/fusiontables/DataSource?docid=#{clone_table_id}"
  end

end