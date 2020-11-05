namespace :rpush do
 
  desc 'Stop the rpush process'
  task :stop do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          if test("[ -f #{Rails.root}/tmp/rpush.pid ]")
            execute :bundle, :exec, :rpush, :stop
          else
            p "rpush isn't running."
          end
        end
      end
    end
  end
 
  desc 'Start the rpush process'
  task :start do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :rpush, :start
        end
      end
    end
  end
 
  desc 'Restart the rpush process'
  task :restart do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          if test("[ -f #{Rails.root}/tmp/rpush.pid ]")
            execute :bundle, :exec, :rpush, :stop
            execute :bundle, :exec, :rpush, :start
          else
            execute :bundle, :exec, :rpush, :start
          end
        end
      end
    end
  end
end