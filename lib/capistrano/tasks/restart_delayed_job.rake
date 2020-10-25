namespace :deploy do
  desc 'Restart delayed job'
  task :restart_delayed_job do
    on roles(:app) do
      within "#{current_path}" do # /home/deploy/proj_name/current
        with rails_env: fetch(:stage) do # production
          execute :dlrestart, "restart delayed job"
        end
      end
    end
  end
end