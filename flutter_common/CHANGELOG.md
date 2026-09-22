## 1.11.0

 - **FIX**: remove obsolete analyzer plugins.
 - **FIX**: resolve analysis and web build failures.
 - **FIX**(deps): update flutter and deps.
 - **FIX**(deep-links): separate web and app links.
 - **FIX**: clear CI analysis failures.
 - **FIX**: address review feedback.
 - **FIX**(app): resolve dev merge conflicts.
 - **FIX**(app,core,db): address code review findings from dev merge.
 - **FIX**(app): reuse onboarding participant.
 - **FEAT**(localization): synchronize app language with server and improve locale handling.
 - **FEAT**: Update deep link handling and environment configuration for Android and iOS.
 - **FEAT**: Enhance recovery flow with validation, constants, and integration tests.
 - **FEAT**: Introduce QR code generation and deep link sharing for study invite codes, supported by new environment variables and localization.

## 1.10.4

 - **FIX**: upgrade deps.
 - **FIX**(flutter_common): use supabase publishable key.
 - **FIX**: upgrade deps.
 - **FIX**(flutter_common): use supabase publishable key.

## 1.10.3

 - **FIX**: upgrade deps.
 - **FIX**(flutter_common): use supabase publishable key.
 - **FIX**: add flutter_common mdi package dependency.
 - **FIX**: migrate to flutter_material_design_icons in favor of deprecated material_design_icons_flutter.
 - **FIX**: upgrade deps.
 - **FIX**: migrate flutter_secure_storage v10.0.0.

## 1.10.2

 - **FIX**: update to flutter v3.41.5.
 - **FIX**: new env dev.

## 1.10.1

 - Update a dependency to the latest release.

## 1.10.0

 - **FIX**: update Supabase URL for production environment.
 - **FEAT**(flutter_common): support multiple Supabase URLs and improve connection handling.

## 1.9.3

 - **FIX**: comment out encryptedSharedPreferences option in SecureStorage.
 - **FIX**: downgrade flutter_secure_storage to version 9.2.2 to address critical bugs.

## 1.9.2

 - **FIX**: update Supabase configuration and remove debug print statements from model repository.

## 1.9.1

 - **FIX**: update Supabase configuration and remove debug print statements from model repository.

## 1.9.0

 - **FIX**: upgrade package dependencies.
 - **FIX**: update dependencies and versions in pubspec.yaml and pubspec.lock.
 - **FIX**: update deps.
 - **FIX**: update Supabase public anon key in development environment.
 - **FEAT**: update Fitbit credentials form and related dependencies.

## 1.9.0-dev.1

 - **FIX**: update Supabase public anon key in development environment.

## 1.9.0-dev.0

 - **FEAT**: update Fitbit credentials form and related dependencies.

## 1.8.13

- **FIX**: update deps.

## 1.8.12

- **FIX**: bump dependencies.

## 1.8.11

- **FIX**: improve error handling in secure storage read method.
- **FIX**: enable android encrypted shared preferences for secure storage.
- **FIX**: only main deployment and github deployment depends on core + flutter_common packages.
- **FIX**: add core and flutter_common local path dependency.

## 1.8.10

 - **FIX**: upgrade deps and flutter v3.24.5.

## 1.8.9

 - **FIX**: upgrade deps.
 - **FIX**: upgrade fvm to flutter v3.24.3.

## 1.8.8

 - **FIX**: upgrade to flutter v3.24.2.

## 1.8.7

 - **FIX**: upgrade deps.

## 1.8.6

 - **FIX**: upgrade deps.

## 1.8.5

 - **FIX**: upgrade deps.
 - **FIX**: upgrade deps.

## 1.8.4

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.8.4-dev.2

 - **FIX**: formatting issues.
 - **FIX**: formatting issues.
 - **FIX**: upgrade deps.

## 1.8.4-dev.1

 - **FIX**: formatting issues.

## 1.8.4-dev.0

 - **FIX**: upgrade deps.
 - **FIX**: put supabase cli default anon key in env.local.example.

## 1.8.3

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.8.3-dev.1

 - Update a dependency to the latest release.

## 1.8.3-dev.0

 - **FIX**: upgrade deps and migrate.

## 1.8.2

 - **FIX**: skip signin after signup if user is already authenticated. ([7e978122](https://github.com/hpi-studyu/studyu/commit/7e97812279b77fb9406fb288341c0fd9e349ad9c))
 - **FIX**: signup was not possible with flutter_secure_storage. ([26425971](https://github.com/hpi-studyu/studyu/commit/2642597141653aa724a1305456e43840d6fbebe5))

## 1.8.1

 - Update a dependency to the latest release.

## 1.8.0

 - **FIX**: migrateSharedPreferencesToSecureStorage data type. ([62f41ab8](https://github.com/hpi-studyu/studyu/commit/62f41ab8b0f18035c5405b1b02045ce2b2fe6008))
 - **FIX**(flutter_common): Add migration for SecureStorage. ([4604537d](https://github.com/hpi-studyu/studyu/commit/4604537d46e5881c91c0df27d9d30e5305cf04b3))
 - **FIX**: style of photo capture button. ([7ec85382](https://github.com/hpi-studyu/studyu/commit/7ec853828a51e7aa454563786d782e9c8ffc4e22))
 - **FIX**: storage bug. ([b7e58d09](https://github.com/hpi-studyu/studyu/commit/b7e58d09a80bfb4f62c11859d6065356085255c8))
 - **FIX**: use local dev in flutter_common assets". ([523ad961](https://github.com/hpi-studyu/studyu/commit/523ad961e3fe82b7137a63e0a3fd62c417513807))
 - **FIX**: use local dev in flutter_common assets. ([575089c0](https://github.com/hpi-studyu/studyu/commit/575089c0b9f7505fbdf18a8bd0d4d29836793c08))
 - **FIX**: new HPI dev env. ([5a1a2667](https://github.com/hpi-studyu/studyu/commit/5a1a2667ab92505f57543eb9e62c0c225af70bee))
 - **FEAT**: deprecate SharedPreferences for flutter_secure_storage. ([1ff25946](https://github.com/hpi-studyu/studyu/commit/1ff259469e3c354f57e22a3d42ce0d1c60036f44))

## 1.7.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.7.0-dev.6

 - **FIX**: upgrade deps. ([b491c9c4](https://github.com/hpi-studyu/studyu/commit/b491c9c469ee808fe1aaa50b7a50759be2378552))

## 1.7.0-dev.5

 - **FIX**: upgrade deps. ([b491c9c4](https://github.com/hpi-studyu/studyu/commit/b491c9c469ee808fe1aaa50b7a50759be2378552))

## 1.7.0-dev.4

 - **FIX**: upgrade deps. ([5327eb97](https://github.com/hpi-studyu/studyu/commit/5327eb971e6673847dc09ef56923b6a73ae73654))

## 1.7.0-dev.3

 - **FIX**: upgrade deps. ([6ad9bea4](https://github.com/hpi-studyu/studyu/commit/6ad9bea42903a25a5be5a84f2af8b70654d05616))
 - **FIX**: update gitignore files. ([939d6be4](https://github.com/hpi-studyu/studyu/commit/939d6be422ee37f2ea56b39bb3921060fd1844cd))
 - **FIX**: upgrade deps. ([7ac0d4ca](https://github.com/hpi-studyu/studyu/commit/7ac0d4cab42b1ce27ec200a5241f92d612ade499))
 - **FIX**: upgrade deps. ([3e186fc4](https://github.com/hpi-studyu/studyu/commit/3e186fc409f038102cc5fd1e6d11b73057dab8d7))

## 1.7.0-dev.2

 - **FIX**: upgrade deps. ([3e186fc4](https://github.com/hpi-studyu/studyu/commit/3e186fc409f038102cc5fd1e6d11b73057dab8d7))

## 1.7.0-dev.1

 - **FIX**: upgrade deps. ([304430c8](https://github.com/hpi-studyu/studyu/commit/304430c858d4035a279b42114c7ccf86299357a2))

## 1.7.0-dev.0

 - **FIX**: do not rely on hardcoded authcallback. ([e6787fb7](https://github.com/hpi-studyu/studyu/commit/e6787fb7027b50181441bec0a6ee5a47eec1146d))
 - **FIX**(cli): debug command line arguments. ([e16f5e49](https://github.com/hpi-studyu/studyu/commit/e16f5e4954ce3247073b31479e8b28f0ff1693df))
 - **FIX**: Use default env urls again. ([ac3c3981](https://github.com/hpi-studyu/studyu/commit/ac3c39819ff23faa99a6812e88700d29184bb9f4))
 - **FEAT**(docker): Introduce advanced cli functionality. ([a1c749aa](https://github.com/hpi-studyu/studyu/commit/a1c749aa6241d4b3521e53462db116a96c0bf246))

## 1.6.4

 - **FIX**: upgrade deps. ([f37d0a71](https://github.com/hpi-studyu/studyu/commit/f37d0a711ab9a126b7da13b7eb4fbb9b784f3725))
 - **FIX**: remove old env and add new hpi dev env. ([2ea488fe](https://github.com/hpi-studyu/studyu/commit/2ea488fe0ea169396435903bf7451a58c527058d))
 - **FIX**: upgrade deps. ([567a3b07](https://github.com/hpi-studyu/studyu/commit/567a3b07c360e55da62898e928a794a756ab0546))

## 1.6.3

 - **FIX**: upgrade deps. ([567a3b07](https://github.com/hpi-studyu/studyu/commit/567a3b07c360e55da62898e928a794a756ab0546))

## 1.6.2

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.6.2-dev.11

 - **FIX**: upgrade deps. ([6fa0e8b8](https://github.com/hpi-studyu/studyu/commit/6fa0e8b8332c0872b59c7c31042fb845f0708e73))
 - **FEAT**: switch to hpi env. ([7f1a1817](https://github.com/hpi-studyu/studyu/commit/7f1a1817d96d955cf2f9e7c7fb7467f317bec53b))

## 1.6.2-dev.10

 - **FIX**: upgrade deps. ([7cdc7c55](https://github.com/hpi-studyu/studyu/commit/7cdc7c559f64cfdd63ee07efbeeb028c418f6f4e))
 - **FIX**: upgrade deps. ([17213746](https://github.com/hpi-studyu/studyu/commit/172137469ed236dc694979bbfe017708faabbd77))

## 1.6.2-dev.9

 - **REFACTOR**: rename .env.selfhost to .env.hpi. ([dae7d461](https://github.com/hpi-studyu/studyu/commit/dae7d4617a3a45df595172672851c0f61ff14de5))
 - **REFACTOR**: rename .env.selfhost to .env.hpi. ([0c3d2252](https://github.com/hpi-studyu/studyu/commit/0c3d2252edaf7f564a417e5b8f4243161514cc37))
 - **FIX**: upgrade deps. ([aa2cb251](https://github.com/hpi-studyu/studyu/commit/aa2cb2512e3db4e31f97edea8d2bccf55e91f9d2))

## 1.6.2-dev.8

 - **FIX**: upgrade deps (switch to wakelock_plus). ([177e5057](https://github.com/hpi-studyu/studyu/commit/177e5057fb41821a2f924ffda79e1faa3119859d))
 - **FIX**: upgrade deps (switch to wakelock_plus). ([9112f5f0](https://github.com/hpi-studyu/studyu/commit/9112f5f0a9c778e2abf24f6aa585bc9f539e6ccf))

## 1.6.2-dev.7

 - **FIX**: upgrade deps (switch to wakelock_plus). ([9112f5f0](https://github.com/hpi-studyu/studyu/commit/9112f5f0a9c778e2abf24f6aa585bc9f539e6ccf))
 - **FIX**: add await-workflow action to wait for pub.dev publishing. ([7206a006](https://github.com/hpi-studyu/studyu/commit/7206a00663657f6d6256b99b0c3aca33e9b263bb))

## 1.6.2-dev.6

 - **FIX**: add await-workflow action to wait for pub.dev publishing. ([7206a006](https://github.com/hpi-studyu/studyu/commit/7206a00663657f6d6256b99b0c3aca33e9b263bb))

## 1.6.2-dev.5

 - **FIX**: upgrade deps. ([35c629aa](https://github.com/hpi-studyu/studyu/commit/35c629aa28fc5761a707168d998a425307ec6d9a))

## 1.6.2-dev.4

 - **FIX**: upgrade deps. ([b2926c39](https://github.com/hpi-studyu/studyu/commit/b2926c395988077d4aa172490dbd9c6fd75d52c6))
 - **FIX**: upgrade deps. ([daad1465](https://github.com/hpi-studyu/studyu/commit/daad146590e874bedee3f82bb72bf4b94e5c3801))

## 1.6.2-dev.3

 - **FIX**: upgrade deps. ([daad1465](https://github.com/hpi-studyu/studyu/commit/daad146590e874bedee3f82bb72bf4b94e5c3801))

## 1.6.2-dev.2

 - **REFACTOR**: rename ENV to STUDY_ENV. ([1ee25b50](https://github.com/hpi-studyu/studyu/commit/1ee25b50e2544f6a62e77ac4266b5fd4c8ba9bf2))

## 1.6.2-dev.1

 - **FIX**: add dhc db to .env. ([f81a44c0](https://github.com/hpi-studyu/studyu/commit/f81a44c0350acadb0f00c42fa5ad4a37ee604fd5))

## 1.6.2-dev.0

 - **FIX**: .env.selfhost use localhost as default. ([5dc73afb](https://github.com/hpi-studyu/studyu/commit/5dc73afb27806256a659243342fe2c16aad61cb7))
 - **DOCS**: modified docker setup. ([21897dd5](https://github.com/hpi-studyu/studyu/commit/21897dd507669d3208eb2ad0aecea3761caa3086))

## 1.6.1

 - **FIX**: improve offline mode, check earlier if device is offline. ([c7a143f5](https://github.com/hpi-studyu/studyu/commit/c7a143f5d2b16220ac72e6b533cee18ac25cd0d3))

## 1.6.0

 - **FEAT**: implement limited offline mode for app. ([cbc898f3](https://github.com/hpi-studyu/studyu/commit/cbc898f34a47535e8f950365ded92ef210137e23))

## 1.5.0

 - **FEAT**: sentry integration in core. ([0fae767f](https://github.com/hpi-studyu/studyu/commit/0fae767f0a7dc3c3409dd5179eeb870429b580cd))

## 1.4.2

 - Update a dependency to the latest release.

## 1.4.1

 - **FIX**: upgrade deps to fix invalid refresh token bug. ([6a4da159](https://github.com/hpi-studyu/studyu/commit/6a4da1594d7baed5d76f74464670ec411abc961c))

## 1.4.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 1.4.0-dev.7

 - Update a dependency to the latest release.

## 1.4.0-dev.6

 - Update a dependency to the latest release.

## 1.4.0-dev.5

 - **FEAT**: add migration option to app for studyu v2. ([82698517](https://github.com/hpi-studyu/studyu/commit/82698517843cfc4aad80c194a6e5f349343a182d))

## 1.4.0-dev.4

 - **FIX**: deploy dev-designer_v2 to new V2 production database. ([5876a990](https://github.com/hpi-studyu/studyu/commit/5876a990d89d9aeb7d0e447f76c279bb93f76414))

## 1.4.0-dev.3

 - **FIX**: add .env.staging to pubignore. ([4147cf94](https://github.com/hpi-studyu/studyu/commit/4147cf942e09bd2e86d6d6e96e5fe4da09182adc))

## 1.4.0-dev.2

 - **FIX**: preserve app language on reload. ([3603cd02](https://github.com/hpi-studyu/studyu/commit/3603cd029f1e40c660d843481bfe370a1240075d))

## 1.4.0-dev.1

 - **FIX**: merge issues. ([8a560314](https://github.com/hpi-studyu/studyu/commit/8a560314c14fcf3e37e9d40f7129a4db483e8a8a))
 - **FIX**: remove staging. ([24b6dfa9](https://github.com/hpi-studyu/studyu/commit/24b6dfa9c2eb8649c896d95620064c8a6feb1b4f))
 - **FIX**: update outdated stuff and dart generate. ([82b58bdc](https://github.com/hpi-studyu/studyu/commit/82b58bdcbf6f077003398b1a19813aa35a36bd91))
 - **FIX**: upgrade supabase_flutter (^1.3.1) and supabase (^1.4.0). ([88e6dad4](https://github.com/hpi-studyu/studyu/commit/88e6dad4cbf6f5847fe382e7969ec2e13a1dee44))
 - **FIX**: remove staging. ([059c39a0](https://github.com/hpi-studyu/studyu/commit/059c39a096e807074d13d54021cfe838a2227d77))
 - **FIX**: migration. ([3ac8f192](https://github.com/hpi-studyu/studyu/commit/3ac8f192d4191eed640340e1292bcdd1c64ece98))
 - **FIX**: upgrade to flutter 3.7.0. ([2aa80015](https://github.com/hpi-studyu/studyu/commit/2aa80015a22161773649790edf2c38742809c45b))
 - **FIX**: upgrade deps. ([1b411140](https://github.com/hpi-studyu/studyu/commit/1b41114080e405c385c15b7beb8d140193656e6a))

## 1.3.27

 - **FIX**: remove staging. ([24b6dfa9](https://github.com/hpi-studyu/studyu/commit/24b6dfa9c2eb8649c896d95620064c8a6feb1b4f))

## 1.3.26

 - Update a dependency to the latest release.

## 1.3.25

 - **FIX**: remove staging. ([059c39a0](https://github.com/hpi-studyu/studyu/commit/059c39a096e807074d13d54021cfe838a2227d77))

## 1.3.24

 - **FIX**: migration. ([3ac8f192](https://github.com/hpi-studyu/studyu/commit/3ac8f192d4191eed640340e1292bcdd1c64ece98))

## 1.3.23

 - **FIX**: upgrade to flutter 3.7.0. ([2aa80015](https://github.com/hpi-studyu/studyu/commit/2aa80015a22161773649790edf2c38742809c45b))
 - **FIX**: upgrade deps. ([1b411140](https://github.com/hpi-studyu/studyu/commit/1b41114080e405c385c15b7beb8d140193656e6a))

## 1.4.0-dev.0

 - **FIX**: upgrade deps. ([4b011445](https://github.com/hpi-studyu/studyu/commit/4b011445bb2390570c536646bb119b5a00a809ab))
 - **FIX**: .env file. ([9129ae84](https://github.com/hpi-studyu/studyu/commit/9129ae84790906bbeffaba382af8171592192722))
 - **FIX**: set correct app link. ([da56b363](https://github.com/hpi-studyu/studyu/commit/da56b3637f61b98fb792da571b31383329ac275a))
 - **FIX**: adapt temp urls to current PR. ([f2360b5d](https://github.com/hpi-studyu/studyu/commit/f2360b5df9ff9b900ed08b958bdfcd822d86ab96))
 - **FIX**: TEMPORARY designerDeepLink fix. ([cb401860](https://github.com/hpi-studyu/studyu/commit/cb401860f8945803be5dfaab0603a3e2f2761ddf))
 - **FIX**: Add .env.staging and fix workflow build. ([5f6138a3](https://github.com/hpi-studyu/studyu/commit/5f6138a3351396aaec0d93b2f55f8a7f4104e9a0))
 - **FEAT**: dont record participant progress for launched studies in test mode. ([2dc6a8ca](https://github.com/hpi-studyu/studyu/commit/2dc6a8ca72785d8929b3ecf3451d352c893fabde))
 - **FEAT**: add selective preview for eligibility check. ([af96450f](https://github.com/hpi-studyu/studyu/commit/af96450f0d98afd719acc1bce09b9148dc924123))
 - **FEAT**: TEMPORARILY change designer deep link. ([362d08bf](https://github.com/hpi-studyu/studyu/commit/362d08bfa016cb5750ab34b454e140f31a47ae46))
 - **FEAT**: decouple preview app state from live app. ([82b0e3c4](https://github.com/hpi-studyu/studyu/commit/82b0e3c4b0dfe9d957a11563546fbb3ae328731e))

## 1.3.22

 - **FIX**: upgrade deps. ([d221eae7](https://github.com/hpi-studyu/studyu/commit/d221eae7ea55fa8761d7ff7625f92eaa3488148e))

## 1.3.21

 - **FIX**: upgrade dependencies. ([bc8cda17](https://github.com/hpi-studyu/studyu/commit/bc8cda17561511d8ec05ce13bc9fcba644768ef5))

## 1.3.20

 - **FIX**: upgrade deps. ([c16d7722](https://github.com/hpi-studyu/studyu/commit/c16d7722719efa732392d0f04bf74f4eefd95406))

## 1.3.19

 - **FIX**: Add missing env to .pubignore. ([ebbb769b](https://github.com/hpi-studyu/studyu/commit/ebbb769b79c7ff61a14febbecfdeb8c8dec43128))

## 1.3.18

 - **FIX**: upgrade deps. ([18dc5206](https://github.com/hpi-studyu/studyu/commit/18dc5206aff15093338a3973ef4196ea9d78d922))

## 1.3.17

 - **FIX**: upgrade deps. ([dca763c6](https://github.com/hpi-studyu/studyu/commit/dca763c6f5531c725148bb99e25c2a2debdeadd6))

## 1.3.16

 - **FIX**: upgrade deps. ([d14c52dd](https://github.com/hpi-studyu/studyu/commit/d14c52dd492bb2e6ceed941a2d33a053276629f4))
 - **FIX**: add newlines. ([6adb5952](https://github.com/hpi-studyu/studyu/commit/6adb5952d9b358094f13d7ab192ea32d1bb70846))
 - **FIX**: use default api keys from now on consistently. ([52afef81](https://github.com/hpi-studyu/studyu/commit/52afef81b53abc23f1dec66cca46dbc8a1c8b6c6))

## 1.3.15

 - **FIX**: Use new studyu package versions. ([cfc65599](https://github.com/hpi-studyu/studyu/commit/cfc65599bca7a28490321c7731bc6e8de4cc1e0a))
 - **FIX**: Adjust to breaking dependencies. ([2f4e14bc](https://github.com/hpi-studyu/studyu/commit/2f4e14bc0a5858f18a2883a7ce3ea38e30a2b8fe))
 - **FIX**: Use API 30 required queries for opening links and sending emails. ([9aef6585](https://github.com/hpi-studyu/studyu/commit/9aef6585c9ff8cf04196d30f525dd732d14c46b4))

## 1.3.14

 - **FIX**: Use new studyu package versions. ([cfc65599](https://github.com/hpi-studyu/studyu/commit/cfc65599bca7a28490321c7731bc6e8de4cc1e0a))

## 1.3.13

 - **FIX**: Adjust to breaking dependencies. ([2f4e14bc](https://github.com/hpi-studyu/studyu/commit/2f4e14bc0a5858f18a2883a7ce3ea38e30a2b8fe))

## 1.3.12

 - **FIX**: Use API 30 required queries for opening links and sending emails. ([9aef6585](https://github.com/hpi-studyu/studyu/commit/9aef6585c9ff8cf04196d30f525dd732d14c46b4))

## 1.3.11

 - **FIX**: Upgrade dependencies. ([31ca516b](https://github.com/hpi-studyu/studyu/commit/31ca516be6518de7a41f4762b669f9059c83f3bc))

## 1.3.10

 - **FIX**: Fix linting and fix lints. ([765b3525](https://github.com/hpi-studyu/studyu/commit/765b3525c89255bbf983a825bedc45a5ef7d8706))
 - **FIX**: Upgrade flutter packages. ([d5d0387a](https://github.com/hpi-studyu/studyu/commit/d5d0387a9a7df464861070be44a9931d2ebb0547))
 - **FIX**: Upgrade deps. ([27f6e8bc](https://github.com/hpi-studyu/studyu/commit/27f6e8bc4526b14320d6d1ca3657db55db2e7c5c))

## 1.3.9

 - **FIX**: Upgrade core. ([5ccbc3d1](https://github.com/hpi-studyu/studyu/commit/5ccbc3d1577f0fb8c0cbe78bbe6b44c322d6ed7d))

## 1.3.8

 - Update a dependency to the latest release.

## 1.3.7

 - **FIX**: Upgrade core. ([19132045](https://github.com/hpi-studyu/studyu/commit/19132045c9d71ccd3c98e5eb6eb9751153a5533e))

## 1.3.6

 - **FIX**: Upgrade dependencies. ([f59a9989](https://github.com/hpi-studyu/studyu/commit/f59a9989be6238576a20f5288951745345ec84af))

## 1.3.5

 - **FIX**: Upgrade studyu core.

## 1.3.4

 - **FIX**: Supabase init and redirectUrl.
 - **CHORE**: Upgrade deps.

## 1.3.3

 - Update a dependency to the latest release.

## 1.3.2

 - **FIX**: Upgrade core.

## 1.3.1

 - **FIX**: Fix authRedirectUrl.

## 1.3.0

 - **FEAT**: Use supabase_flutter for session storing.

## 1.2.6

 - **FIX**: Do not ignore .env files.

## 1.2.5

 - **FIX**: Supabase signup not logging user in.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade studyu_core.
 - **CHORE**: Upgrade deps.

## 1.2.4

 - **FIX**: Upgrade StudyU deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps; Generate json_serializable.

## 1.2.3

 - **FIX**: Upgrade studyu_core.
 - **FIX**: Upgrade studyu deps.
 - **CHORE**: Prepare for pub.dev release.

## 1.2.2

 - Update a dependency to the latest release.

## 1.2.1

 - Update a dependency to the latest release.

## 1.2.0

 - **FIX**: Point to new staging supabase.
 - **FEAT**: Try draft: Log out, before singing in.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 1.1.1

 - **FIX**: Escape hashtag in dotenv file.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 1.1.0

 - **FEAT**: Restore from session string.
 - **FEAT**: Add app url env var.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 1.0.5

 - Update a dependency to the latest release.

## 1.0.4

 - Update a dependency to the latest release.

## 1.0.3

 - **FIX**: Upgrade supabase -> Fix jwt expired.

## 1.0.2

 - **REFACTOR**: Split signParticipant into own function.
 - **CHORE**: Upgrade studyu packages.

## 1.0.1

 - Update a dependency to the latest release.

