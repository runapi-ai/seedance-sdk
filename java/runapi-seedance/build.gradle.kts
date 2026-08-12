plugins {
  `java-library`
  `maven-publish`
}

extra["runapiSlug"] = "seedance"

description = "RunAPI Seedance Java SDK for Seedance workflows."

java {
  withSourcesJar()
  withJavadocJar()
}

dependencies {
  api("ai.runapi:runapi-core:0.4.1")

  testImplementation(platform("org.junit:junit-bom:5.10.3"))
  testImplementation("org.junit.jupiter:junit-jupiter")
}

publishing {
  publications {
    create<MavenPublication>("mavenJava") {
      from(components["java"])
      artifactId = "runapi-seedance"
      pom {
        name = "RunAPI Seedance Java SDK"
        description = "RunAPI Seedance Java SDK for Seedance workflows."
        url = "https://runapi.ai/models/seedance"
        licenses {
          license {
            name = "Apache License, Version 2.0"
            url = "https://www.apache.org/licenses/LICENSE-2.0"
          }
        }
        developers {
          developer {
            id = "runapi"
            name = "RunAPI"
            email = "contact@runapi.ai"
          }
        }
        scm {
          url = "https://github.com/runapi-ai/seedance-sdk"
          connection = "scm:git:https://github.com/runapi-ai/seedance-sdk.git"
          developerConnection = "scm:git:ssh://git@github.com/runapi-ai/seedance-sdk.git"
        }
      }
    }
  }
}
