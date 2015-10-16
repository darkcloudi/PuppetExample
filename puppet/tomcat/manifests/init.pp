#install_dir: where the tomcat server is deployed to, if the install_dir param is passed in through
#site.pp or note.pp it will use that. This is a good way to install or users home directory for testing on a
#personal dev box
#Factor needs to be installed to determine $id
#This project is not properly configured and not tested it was created as an example for demo in terms of what I want
#for the dev network, use this as a starting point

class tomcat ($install_dir = "/home/$id", $version = 8.0.28, $started=true, $live = false, $mongo_host, $mongo_port = 27017) {
   $tomcat_dir = $install_dir/tomcat

   if $live {
       exec { "install-tomcat-live":
       command => "clone_tomcat logs=${install_dir}/ops_logs ${tomcat_dir}",
       path => "${path}:/home/$id/scripts",
       creates => "${tomcat_dir}",
       before => File["${tomcat_dir}/conf/"],
      }
   }

   #This is just an example of what you may want to do if you want to configure a dev box or another box
   if ! $live {
    exec { "install-tomcat-dev":
          command => "clone_tomcat logs=${install_dir}/dev_logs ${tomcat_dir}",
          path => "${path}:/home/$id/scripts",
          creates => "${tomcat_dir}",
          before => File["${tomcat_dir}/conf/lib"],
         }

   }

   #create libs directory
   file { "${tomcat_dir}/conf/lib" :
       ensure => directory,
       source => "puppet:///modules/tomcat/props/libs",
       purge => false,
       recurse => true,
   }

    #default properties, if you need ops specific props you can have an if condition check for live
      file { "${tomcat_dir}/conf/lib/sam.properties" :
          content => template('tomcat/sam.properties'),
          ensure => file,
          before => Service['tomcat'],
      }

   if ($live) {
      file {"/home/${id}/.bashrcSam":
          content => templates('tomcat/bashrc'),
          mode => 644,
      }
   }

   service { "tomcat" :
       ensure => running,
       hasrestart => false,
       hasstatus => false,
       provider => base,

       start => "${install_dir}/tomcat/bin/catalina.sh start"
       stop => "${install_dir}/tomcat/bin/catalina.sh stop"
       #You can also do a ps -ef for tomcat and grep to see if its running
       status => "${install_dir}/tomcat/bin/catalina.sh status"

   }



   #Make my shell script executable
      file {
          "$tomcat_dir/conf/scripts/configure-tomcat.sh" :
           ensure => file,
           #Script with additional configuration
           content => template('tomcat/configure-tomcat.sh'),
           mode => 700,
      }

      exec {
                "run-cli-script" :
                 require => [ Service["tomcat"], "${tomcat_dir}/conf/scripts/configure-tomcat.sh" ],
                 #Execute script
                 command => "${tomcat_dir}/conf/scripts/configure-tomcat.sh",
                 path => "${path}",
                 #If the temp file (props.congifured) is created then don't need to run the CLI script again
                 unless => "ls ${tomcat_dir}/props/libs/tomcat.configured",
            }

}