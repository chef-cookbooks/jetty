Vagrant.configure("2") do |config|
  config.vm.box     = "opscode-ubuntu-12.04"
  config.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_chef-11.4.4.box"
 
  config.vm.hostname = "vagrant-rps-qa1-fe3001.qa.paypal.com"
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", 1024]
  end
  config.vm.provision :shell, :inline => "sudo apt-get update -y"
  config.vm.provision :shell, :inline => "sudo apt-get install vim -y"
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["#{File.expand_path("..",Dir.pwd)}"]
 
    # Turn on verbose Chef logging if necessary
    chef.log_level      = :debug
 
    # List the recipies you are going to work on/need.
    #chef.add_recipe     "minitest-handler"
    chef.add_recipe     "jetty"
    #chef.json = { "jetty" => { :java_options => "-Xmx512m -Djava.awt.headless=true -Djetty.class.path=/usr/share/where/ss/production/properties -Djava.net.preferIPv4Stack=true -Djava.net.preferIPv4Stack=true -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:MaxGCPauseMillis=10 -XX:+CMSIncrementalMode -XX:+UseParNewGC -XX:CMSInitiatingOccupancyFraction=55 -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=1099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dnewrelic.environment=Production -Dnewrelic.logfile=/var/log/jetty/newrelic_agent.log -Dnewrelic.config.file=/etc/jetty/newrelic.yml -javaagent:/usr/share/jetty/lib/ext/newrelic.jar" } }
    
  end
end
