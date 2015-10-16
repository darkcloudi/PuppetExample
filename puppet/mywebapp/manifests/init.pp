#install_dir: where the tomcat server is deployed to, if the install_dir param is passed in through
#site.pp or note.pp it will use that. This is a good way to install or users home directory for testing on a
#personal dev box
#Factor needs to be installed to determine $id

class mywebapp ($install_dir = "/home/$id") {
   $tomcat_dir = $install_dir/tomcat

   #Deploy my old release of code as want to keep old version deployed
   file {
       "$tomcat_dir/deployments/mywebapp-1.0.0.war" :
        source => "puppet:///modules/mywebapp/mywebapp-1.0.0.war",
        mode => 644,
   }

   #Deploy latest release of code as want to keep old version deployed
   # project.version comes from maven project
      file {
          "$tomcat_dir/deployments/mywebapp-${project.version}.war" :
           source => "puppet:///modules/mywebapp/mywebapp-${project.version}.war",
           mode => 644,
      }

}