How to configure artifactory plugin development

go to the gradle.properties and set the artifactoryVersion to the version you are using  
go to the gradle.properties and paste in your download link for artifactory.  
link in plugins to be worked in in the etc/plugins directory (see readme there)

All of the configuration happens with gradle tasks:

To set up your ide type:  ./gradlew idea (or eclipse)
To download and configure artifactory: ./gradlew prepareArtPro
To start artifactory: ./gradlew startArtPro

Then you can run the tests present in 'artifactory-user-plugins-devenv/src/test/groovy/org/jfrog/plugindev/test' using your IDE.

To stop artifactory: ./gradlew stopArtPro

To erase all artifactory storages: ./gradlew cleanArtPro

Artifactory will be configured with the artifactory pro license present in the etc folder,
a representative set of repositories, and will poll the plugins directory for updates every 10 seconds.


Logging can be printed to the logs from within the plugin (with log.warn) and viewed by tailing the artifactory.log file, as user plugins are compiled at runtime. A basic example would be - 

```java
storage {
        beforeMove{item, targetRepoPath, properties ->
                 log.warn "triggered !";
        }
}
```

(For checking whether the beforeMove event was triggered)
