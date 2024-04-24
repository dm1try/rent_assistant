# frozen_string_literal: true

require 'mina/git'
require 'mina/deploy'
require 'mina/bundler'
require 'mina/rbenv'

deploy_user =  ENV['USER'] || 'deploy'

set :application_name, 'rent_assistant'
set :domain, ENV['DOMAIN']
set :deploy_to, "/home/#{deploy_user}/app"
set :repository, 'https://github.com/dm1try/rent_assistant.git'
set :branch, ENV['BRANCH'] || 'main'
set :execution_mode, :system
set :rbenv_path, "/home/#{deploy_user}/.rbenv"
set :rbenv_ruby, '3.2.2'

# Optional settings:
set :user, deploy_user         # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
 set :shared_dirs, fetch(:shared_dirs, []).push('config')
#set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  invoke :'rbenv:load'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  command %(mkdir -p "#{fetch(:shared_path)}/config")
  command %(mkdir -p "#{fetch(:shared_path)}/data")
end

desc 'Deploys the current version to the server.'
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    command %(cd apps/catalog && bundle config set without development test && bundle install && cd ../..)
    command %(cd apps/crawler && bundle config set without development test && bundle install && cd ../..)
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %(sudo /home/#{deploy_user}/.rbenv/shims/foreman export systemd /etc/systemd/system -a #{fetch(:application_name)} -u #{fetch(:user)} -l #{fetch(:shared_path)}/log -f Procfile.prod -e config/.env.prod)
        command %(sudo systemctl daemon-reload)
        command %(sudo systemctl restart #{fetch(:application_name)}.target)
      end
    end
  end
end
