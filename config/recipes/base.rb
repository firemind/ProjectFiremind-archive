def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

def ensure_line(file, line)
  "fgrep '#{line}' #{file} > /dev/null || #{sudo} echo '#{line}' >> #{file}"
end

namespace :deploy do
  desc "Install everything onto the server"
  task :install do
    run "#{sudo} apt-get -y update"
    #run "#{sudo} apt-get -y install python-software-properties"
  end
end
