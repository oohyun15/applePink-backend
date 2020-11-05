namespace :rpush do
 
  def args
    fetch(:rpush_args, "")
  end

  desc 'Stop the rpush process'
  task :stop do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :rpush, :stop, :"-e #{fetch(:rails_env)}"
        end
      end
    end
  end
 
  desc 'Start the rpush process'
  task :start do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, :rpush, args, :start, :"-e #{fetch(:rails_env)}"
        end
      end
    end
  end
 
  desc 'Restart the rpush process'
  task :restart do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do          
          execute :bundle, :exec, :rpush, :stop, :"-e #{fetch(:rails_env)}" rescue nil
          execute :bundle, :exec, :rpush, args, :start, :"-e #{fetch(:rails_env)}" 
        end
      end
    end
  end
end