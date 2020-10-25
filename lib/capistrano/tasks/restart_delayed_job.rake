namespace :deploy do
  desc 'Restart delayed job'
  task :restart_delayed_job do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: fetch(:stage) do
          execute "rake", "jobs:workoff"
        end
      end
    end
  end
end