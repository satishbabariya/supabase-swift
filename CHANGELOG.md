# Changelog

## [2.10.1](https://github.com/supabase/supabase-swift/compare/v2.10.0...v2.10.1) (2024-05-15)


### Bug Fixes

* race condition when accessing SupabaseClient ([#386](https://github.com/supabase/supabase-swift/issues/386)) ([811e222](https://github.com/supabase/supabase-swift/commit/811e222dd486625eb9ba8937be139563bdc10d43))

## [2.10.0](https://github.com/supabase/supabase-swift/compare/v2.9.0...v2.10.0) (2024-05-14)


### Features

* expose Realtime options on SupabaseClient ([#377](https://github.com/supabase/supabase-swift/issues/377)) ([9cfafdb](https://github.com/supabase/supabase-swift/commit/9cfafdbb4a321dd523f33319bdd7e69e8d77a0ea))


### Bug Fixes

* **auth:** adds missing redirectTo query item to updateUser ([#380](https://github.com/supabase/supabase-swift/issues/380)) ([5d1a997](https://github.com/supabase/supabase-swift/commit/5d1a9970a2024a686a013873cb70eaae64ba4aa6))
* **auth:** header being overridden ([#379](https://github.com/supabase/supabase-swift/issues/379)) ([866a039](https://github.com/supabase/supabase-swift/commit/866a0395043030dd1574deb97360e2d47040efae))
* **postgrest:** update parameter of `is` filter to allow only `Bool` or `nil` ([#382](https://github.com/supabase/supabase-swift/issues/382)) ([4ba1c7a](https://github.com/supabase/supabase-swift/commit/4ba1c7a6c5a13c0a2b4b067aad5c747d7d621e93))
* **storage:** headers overridden ([#384](https://github.com/supabase/supabase-swift/issues/384)) ([b40c34a](https://github.com/supabase/supabase-swift/commit/b40c34a63fbbc0760d3f6e70ed7b69b08f9e70c8))

## [2.9.0](https://github.com/supabase/supabase-swift/compare/v2.8.5...v2.9.0) (2024-05-10)


### Features

* **auth:** Adds `currentSession` and `currentUser` properties ([#373](https://github.com/supabase/supabase-swift/issues/373)) ([4b01556](https://github.com/supabase/supabase-swift/commit/4b015565edbdb761ead8294ebb66d05da5a48b59))
* **functions:** invoke function with custom query params ([#376](https://github.com/supabase/supabase-swift/issues/376)) ([b4b9276](https://github.com/supabase/supabase-swift/commit/b4b9276512acccc673c36e35f06e69755e2a5dc7))
* improve HTTP Error ([#372](https://github.com/supabase/supabase-swift/issues/372)) ([ea25236](https://github.com/supabase/supabase-swift/commit/ea252365511773f93ef35bc2aa80c6098612de57))
* **storage:** copy objects between buckets ([69d05ef](https://github.com/supabase/supabase-swift/commit/69d05eff5dbb413b8b2a5ba565f7f5e19a6e0ab6))
* **storage:** move objects between buckets ([69d05ef](https://github.com/supabase/supabase-swift/commit/69d05eff5dbb413b8b2a5ba565f7f5e19a6e0ab6))


### Bug Fixes

* **auth:** sign out regardless of request success ([#375](https://github.com/supabase/supabase-swift/issues/375)) ([25178e2](https://github.com/supabase/supabase-swift/commit/25178e212dcc0dba4a712e9b7ec3ed93575efdf9))

## [2.8.5](https://github.com/supabase/supabase-swift/compare/v2.8.4...v2.8.5) (2024-05-08)


### Bug Fixes

* throw generic HTTPError ([#368](https://github.com/supabase/supabase-swift/issues/368)) ([782e940](https://github.com/supabase/supabase-swift/commit/782e940437a8a72d3243847c04fb37ef2f5fe7f0))

## [2.8.4](https://github.com/supabase/supabase-swift/compare/v2.8.3...v2.8.4) (2024-05-08)


### Bug Fixes

* **functions:** invoke with custom http method ([#367](https://github.com/supabase/supabase-swift/issues/367)) ([a283b68](https://github.com/supabase/supabase-swift/commit/a283b68cf49faa4c5bd2bb870e0840900fc7af35))

## [2.8.3](https://github.com/supabase/supabase-swift/compare/v2.8.2...v2.8.3) (2024-05-07)


### Bug Fixes

* **auth:** extract both query and fragment from URL ([#365](https://github.com/supabase/supabase-swift/issues/365)) ([e9c7c8c](https://github.com/supabase/supabase-swift/commit/e9c7c8c29002c9be1bf523deefc25e036d3c4a2a))

## [2.8.2](https://github.com/supabase/supabase-swift/compare/v2.8.1...v2.8.2) (2024-05-06)


### Bug Fixes

* **auth:** sign out should ignore 403s ([#359](https://github.com/supabase/supabase-swift/issues/359)) ([7c4e62b](https://github.com/supabase/supabase-swift/commit/7c4e62b3d0dcc6f307639abb3ef8ad792589fab1))

## [2.8.1](https://github.com/supabase/supabase-swift/compare/v2.8.0...v2.8.1) (2024-04-29)


### Bug Fixes

* **auth:** add missing is_anonymous field ([#355](https://github.com/supabase/supabase-swift/issues/355)) ([854dc42](https://github.com/supabase/supabase-swift/commit/854dc42659ed9c634271562b93169bb82e06890e))

## [2.8.0](https://github.com/supabase/supabase-swift/compare/v2.7.0...v2.8.0) (2024-04-22)


### Features

* **functions:** add experimental invoke with streamed responses ([#346](https://github.com/supabase/supabase-swift/issues/346)) ([2611b09](https://github.com/supabase/supabase-swift/commit/2611b091c871cf336de954f169240647efdf0339))
* **functions:** add support for specifying function region ([#347](https://github.com/supabase/supabase-swift/issues/347)) ([f470874](https://github.com/supabase/supabase-swift/commit/f470874f8dd8b0077a44e7243fc1d91993ae5fa9))
* **postgrest:** add geojson, explain, and new filters ([#343](https://github.com/supabase/supabase-swift/issues/343)) ([56c8117](https://github.com/supabase/supabase-swift/commit/56c81171d1e610e0286f7122522890d2b4001c2b))
* **realtime:** add closure based methods ([#345](https://github.com/supabase/supabase-swift/issues/345)) ([dfe09bc](https://github.com/supabase/supabase-swift/commit/dfe09bc804a06a06743884cbf56c5890409e9a87))


### Bug Fixes

* linux build ([#350](https://github.com/supabase/supabase-swift/issues/350)) ([e62ad89](https://github.com/supabase/supabase-swift/commit/e62ad891c80b037aada972f7c11e806f70c6aa50))
* **storage:** getSignedURLs method using wrong encoder ([#352](https://github.com/supabase/supabase-swift/issues/352)) ([d1b0672](https://github.com/supabase/supabase-swift/commit/d1b06728670ed2bb204693f69a81e584cd5c1a73))

## [2.7.0](https://github.com/supabase/supabase-swift/compare/v2.6.0...v2.7.0) (2024-04-16)


### Features

* **auth:** add `getLinkIdentityURL` ([#342](https://github.com/supabase/supabase-swift/issues/342)) ([202383d](https://github.com/supabase/supabase-swift/commit/202383d355dfaa9aab0e03680d9fedb9bdfc02d9))
* **auth:** add `signInWithOAuth` ([#299](https://github.com/supabase/supabase-swift/issues/299)) ([1290bcf](https://github.com/supabase/supabase-swift/commit/1290bcfb39fb156de0283888b47ba1532107f468))
* expose PostgrestClient methods directly in SupabaseClient ([#336](https://github.com/supabase/supabase-swift/issues/336)) ([aca50a5](https://github.com/supabase/supabase-swift/commit/aca50a557339f9872896b03988b737c56589fba7))


### Bug Fixes

* **postgrest:** race condition when executing request ([#327](https://github.com/supabase/supabase-swift/issues/327)) ([8063610](https://github.com/supabase/supabase-swift/commit/80636105e154a28f418f01f4af8b30987239b8f3))
* **postgrest:** race condition when setting fetchOptions and execute method call ([#325](https://github.com/supabase/supabase-swift/issues/325)) ([97d1900](https://github.com/supabase/supabase-swift/commit/97d1900d26272777f864803a0290573b39f47f00))

## [2.6.0](https://github.com/supabase-community/supabase-swift/compare/2.5.1...v2.6.0) (2024-04-03)


### Features

* **auth:** Add `signInAnonymously` ([#297](https://github.com/supabase-community/supabase-swift/issues/297)) ([4c25a3e](https://github.com/supabase-community/supabase-swift/commit/4c25a3eac392b319154ffb3d5d33a0686e3781a4))
