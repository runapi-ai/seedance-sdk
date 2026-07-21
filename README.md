<p align="center">
  <a href="https://runapi.ai"><img src="https://runapi.ai/icon.svg" height="56" alt="RunAPI"></a>
</p>

<h3 align="center">
  <a href="https://github.com/runapi-ai/seedance-sdk">Seedance API SDK for RunAPI</a>
</h3>

<p align="center">
  Seedance API SDKs for JavaScript, Python, Ruby, Go, Java, and PHP on RunAPI.
</p>

<div align="center">

[![npm](https://img.shields.io/npm/v/@runapi.ai/seedance)](https://www.npmjs.com/package/@runapi.ai/seedance)
[![PyPI](https://img.shields.io/pypi/v/runapi-seedance)](https://pypi.org/project/runapi-seedance/)
[![RubyGems](https://img.shields.io/gem/v/runapi-seedance)](https://rubygems.org/gems/runapi-seedance)
[![Go Reference](https://pkg.go.dev/badge/github.com/runapi-ai/seedance-sdk/go.svg)](https://pkg.go.dev/github.com/runapi-ai/seedance-sdk/go)
[![Maven Central](https://img.shields.io/maven-central/v/ai.runapi/runapi-seedance)](https://central.sonatype.com/artifact/ai.runapi/runapi-seedance)
[![License](https://img.shields.io/github/license/runapi-ai/seedance-sdk)](https://github.com/runapi-ai/seedance-sdk/blob/main/LICENSE)

</div>
<br/>

The Seedance API SDK packages JavaScript, Python, Ruby, Go, Java, and PHP clients for Seedance on RunAPI. Use it for text-to-video workflows when your app needs typed request builders, predictable task polling, file upload helpers, account helpers, and consistent RunAPI errors.

Seedance is listed in the RunAPI model catalog at https://runapi.ai/models/seedance. Variant pages below carry pricing, rate-limit, and commercial-usage details. The public `seedance-sdk` repository groups the non-PHP language packages, examples, CI, and release tags for this model. The PHP package is released from a split Composer repository.

## Install

```bash
npm install @runapi.ai/seedance
pip install runapi-seedance
gem install runapi-seedance
go get github.com/runapi-ai/seedance-sdk/go@latest
```

Gradle:

```kotlin
dependencies {
  implementation("ai.runapi:runapi-seedance:0.1.4")
}
```

Maven:

```xml
<dependency>
  <groupId>ai.runapi</groupId>
  <artifactId>runapi-seedance</artifactId>
  <version>0.1.4</version>
</dependency>
```

Use the Java BOM when installing multiple RunAPI Java modules:

```kotlin
dependencies {
  implementation(platform("ai.runapi:runapi-bom:0.2.3"))
  implementation("ai.runapi:runapi-seedance")
}
```

The PHP package is published from the split Composer repository as `runapi-ai/seedance`; see https://github.com/runapi-ai/seedance-php for PHP install and examples.

## What you can build

- Build apps, agent workflows, batch jobs, and production services around Seedance requests.
- Install only the language package your app needs while keeping one model-specific repository for docs and releases.
- Use `create` for submit-only jobs, `get` for status lookup, and `run` for submit-and-poll scripts.
- Upload local files, URL files, or base64 files through shared RunAPI file helpers.
- Handle validation, authentication, rate limits, insufficient credits, task failures, and polling timeouts through RunAPI SDK errors.

## Java quick start

```java
import ai.runapi.seedance.SeedanceClient;
import ai.runapi.seedance.types.TextToVideoParams;
import ai.runapi.seedance.types.CompletedTextToVideoResponse;
import ai.runapi.seedance.types.TextToVideoModel;

SeedanceClient client = SeedanceClient.builder()
    .apiKey(System.getenv("RUNAPI_API_KEY"))
    .build();

CompletedTextToVideoResponse result = client.textToVideo().run(
    TextToVideoParams.builder()
        .model(TextToVideoModel.SEEDANCE_1_5_PRO)
        .durationSeconds(5)
        .prompt("A fast tracking shot through a futuristic train station")
        .aspectRatio("16:9")
        .outputResolution("480p")
        .build()
);
```

Java packages target Java 8 bytecode and are tested on Java 8, 11, 17, and 21. Each model artifact depends on `ai.runapi:runapi-core`, so application code normally installs only `ai.runapi:runapi-seedance`.

## Task lifecycle

Most media endpoints are asynchronous. `create()` submits a task and returns its id, `get(id)` fetches the latest task state, and `run(params)` creates the task and polls until it reaches a terminal state. In web request handlers, prefer `create()` plus webhook or later `get()` polling so the server does not hold a worker open.

## Repository layout

- `js/` publishes `@runapi.ai/seedance`.
- `python/` publishes `runapi-seedance`.
- `ruby/` publishes `runapi-seedance`.
- `go/` publishes `github.com/runapi-ai/seedance-sdk/go` and depends on `github.com/runapi-ai/core-sdk/go`.
- `java/` publishes `ai.runapi:runapi-seedance` and depends on `ai.runapi:runapi-core`.

## Public links

- Model page: https://runapi.ai/models/seedance
- SDK docs: https://runapi.ai/docs#sdk-seedance
- Product docs: https://runapi.ai/docs#seedance
- SDK repository: https://github.com/runapi-ai/seedance-sdk
- PHP package repository: https://github.com/runapi-ai/seedance-php
- Skill repository: https://github.com/runapi-ai/seedance
- Provider comparison: https://runapi.ai/providers/bytedance
- Full catalog: https://runapi.ai/models

## Pricing and variants

Use the most specific Seedance variant page for pricing, rate limits, and commercial usage:
- [v1 lite](https://runapi.ai/models/seedance/v1-lite)
- [v1 pro](https://runapi.ai/models/seedance/v1-pro)
- [v1 pro fast](https://runapi.ai/models/seedance/v1-pro-fast)
- [1.5 pro](https://runapi.ai/models/seedance/1.5-pro)
- [2.0](https://runapi.ai/models/seedance/2.0)
- [2.0 fast](https://runapi.ai/models/seedance/2.0-fast)
- [2.0 mini](https://runapi.ai/models/seedance/2-mini)

Default pricing link for the Seedance SDK: https://runapi.ai/models/seedance/v1-lite

## File storage

RunAPI-generated file URLs are temporary. Download and store generated images, videos, audio, or other files in your own durable storage within 7 days; do not treat returned URLs as long-term assets.

## FAQ

### Which package should I install for Seedance work?

Install the model package for your language: `@runapi.ai/seedance` on npm, `runapi-seedance` on PyPI, `runapi-seedance` on RubyGems, `github.com/runapi-ai/seedance-sdk/go`, `ai.runapi:runapi-seedance` on Maven Central, or `runapi-ai/seedance` on Packagist. Install core SDK packages only when you are building shared SDK infrastructure.

### Where should public links point?

Primary Seedance links point to https://runapi.ai/models/seedance. Pricing and usage-policy links point to variant pages such as https://runapi.ai/models/seedance/v1-lite. Provider comparisons point to https://runapi.ai/providers/bytedance, and broad browsing points to https://runapi.ai/models.

## License

Licensed under the Apache License, Version 2.0.
