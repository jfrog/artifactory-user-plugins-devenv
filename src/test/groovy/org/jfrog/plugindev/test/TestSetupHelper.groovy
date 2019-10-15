package org.jfrog.plugindev.test

import org.jfrog.artifactory.client.ArtifactoryClientBuilder

/**
 * Created by freds on 8/4/14.
 */
class TestSetupHelper {
    static def startArtifactory() {
        def artifactory = ArtifactoryClientBuilder.create()
            .setUrl("http://localhost:8088/artifactory")
            .setUsername("admin")
            .setPassword("password")
            .build()

    }
}
