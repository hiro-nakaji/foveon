# Minimal sample configuration file for Unicorn (not Rack) when used
# with daemonization (unicorn -D) started in your working directory.
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.
# See also http://unicorn.bogomips.org/examples/unicorn.conf.rb for
# a more verbose configuration using more features.

worker_processes 4 # this should be >= nr_cpus
timeout 240
listen File.expand_path('tmp/sockets/unicorn.sock', ENV['RAILS_ROOT'])
pid File.expand_path('tmp/pids/unicorn.pid', ENV['RAILS_ROOT'])
stderr_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
stdout_path File.expand_path('log/unicorn.log', ENV['RAILS_ROOT'])
