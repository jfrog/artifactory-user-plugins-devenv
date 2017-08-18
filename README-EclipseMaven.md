Howto develop User plugin with Eclipse and Maven
=================================================

**Preamble**: If you are working on Linux or Mac OS X platforms (with gradle), please prefer the [recommended solution](README.md). This howto is only a degraded solution for Windows platforms and/or Eclipse + Maven fans.

This howto provides the way to develop users plugins on Eclipse with Maven, with features: 
- Dynamic copy of groovy file (current developed user plugin) when it is saved.
- Eclipse project configuration for Groovy unit test execution

### Artifactory installation

Install Artifactory Pro and start it with dev mode:
1. Download (last) version of Artifactory Pro on [Bintray](https://dl.bintray.com/jfrog/artifactory-pro/org/artifactory/pro/jfrog-artifactory-pro/)
2. Add `${ARTIFACTORY_HOME}/etc/artifactory.lic` file with correct licence.
3. Set the tomcat port to **8088** in `${ARTIFACTORY_HOME}/tomcat/conf/server.xml` file (most common port used in unit tests)
3. Enable the users plugins reloadling in `${ARTIFACTORY_HOME}/etc/artifactory.system.properties`:

    artifactory.plugin.scripts.refreshIntervalSecs=5

### Eclipse installation

Install [Groovy-Eclipse Feature](https://github.com/groovy/groovy-eclipse/wiki) in a recent Eclipse version (containing m2e plugin).

### Project configuration

Clone [artifactory-user-plugins](https://github.com/JFrogDev/artifactory-user-plugins) project, import it, and:
1. Update into `pom.xml` file the properties `user.plugin.dev` (mandatory) / `artifactory.home.location` / `version.artifactory`
2. Configure **Groovy Nature** and **Maven Nature** on project
3. Execute m2e plugin (ALT+F5)

### Checks & execution

Verify that:
- *JRE System Library* / *Maven Dependencies* / *Groovy Libraries* are linked to your project
- The user plugin you develop is linked as build sources on project
- `artifactory-user-plugins/target/test-classes` contains groovy compiled class
- Current user plugin files (*.groovy* and *.properties*) are in `${ARTIFACTORY_HOME}/etc/plugins` directory

You can now modify the user plugin code and execute the Groovy unit test class with **Eclipse JUnit runner** (and enjoy).
 