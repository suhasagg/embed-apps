#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake/dsl_definition'

Mechanicalmap::Application.load_tasks

namespace :db do

  desc "fix app "
  task :fix => :environment do
    App.all.each { |app|
      if App::GOOGLE_TABLE_REG.match(app.challenges_table_url).nil?
      app.challenges_table_url = "https://www.google.com/fusiontables/DataSource?docid=#{app.challenges_table_url}"
      end
      if App::GOOGLE_TABLE_REG.match(app.answers_table_url).nil?
        app.answers_table_url = "https://www.google.com/fusiontables/DataSource?docid=#{app.answers_table_url}"
      end
      if App::GIST_REG.match(app.gist_url).nil?
        app.gist_url = "https://gist.github.com/#{app.gist_url}"
      end
      app.save
    }
  end

end

namespace :app do

  desc "synch answers"
  task :sync => :environment do
        FtDao.instance.sync_answers(answers)
  end

  desc "synch answers"
  task :sync => :environment do
    App.all.each { |app|
       puts "app: #{app.name}"

      answers=app.answers.answered.where(:ft_sync => false)
      if (answers.size>0)
        puts "#{answers.size} answers to synchronize"
        FtDao.instance.sync_answers(answers)
      end
    }
  end

  desc "reindex required answers"
  task :answers_gen => :environment do
    App.first.tasks.each { |task|
      1.times do
        task.answers<<Answer.create!(:state => Answer::STATE[:AVAILABLE])
      end
    }
  end

end