## 4.10.0

 - **REFACTOR**: Optimize widget instantiation and clean up imports in recovery flow tests.
 - **REFACTOR**: Rename wordlist constants and export recovery utilities from the core package.
 - **REFACTOR**(app): simplify questionnaire flow.
 - **REFACTOR**: Update `share_plus` API usage, simplify QR scanner camera setup and color opacity, and streamline menu positioning.
 - **REFACTOR**: centralize study fetching logic by moving `fetchById` and `fetchByInviteCode` methods to the `Study` model.
 - **FIX**(designer): transmit preview studies outside urls.
 - **FIX**: remove obsolete analyzer plugins.
 - **FIX**(recovery): make account recovery retry-safe and revoke old sessions.
 - **FIX**(designer): address invite review feedback.
 - **FIX**(core): add flutter_test dev dependency.
 - **FIX**(designer): restore invite code create and dismiss flow.
 - **FIX**(deps): bump deps.
 - **FIX**(core): correct choice visibility evaluation.
 - **FIX**(designer): secure participant study previews.
 - **FIX**(ci): resolve invite flow checks.
 - **FIX**(app): resolve dev merge conflicts.
 - **FIX**(app): show recovery phrase after dashboard opens.
 - **FIX**(designer): preserve free text conditional semantics.
 - **FIX**(app,core,db): address code review findings from dev merge.
 - **FIX**: address code review findings across app, core, and designer.
 - **FIX**(designer): support free-text length conditions.
 - **FIX**(app): require review for restored answers.
 - **FIX**(app): resolve questionnaire controller merge conflicts.
 - **FIX**(deps): update flutter and deps.
 - **FIX**(deep-links): separate web and app links.
 - **FIX**: clear CI analysis failures.
 - **FIX**: Update exception handling in rejoin study service and improve recovery flow tests.
 - **FEAT**(invite-codes): make invite codes case-insensitive and space-trimmed.
 - **FEAT**: refactor deep link generation for invite codes.
 - **FEAT**: Enhance recovery flow with validation, constants, and integration tests.
 - **FEAT**: Introduce QR code generation and deep link sharing for study invite codes, supported by new environment variables and localization.
 - **FEAT**: Introduce recovery phrase and rejoin study features with new onboarding screens, core utilities, and localization.
 - **FEAT**(app): support required choice selections.
 - **FEAT**(app): add invite QR flow.
 - **FEAT**: Upgrade recovery phrase system to 128-bit IDs, updating encoding logic and UI to support 13 words.
 - **FEAT**: Update deep link handling and environment configuration for Android and iOS.

## 4.9.0

 - **REFACTOR**: clean up date question localization and validation messages.
 - **FIX**: upgrade deps.
 - **FIX**: upgrade deps.
 - **FEAT**: Enhance Date Question Functionality with Time Input and Localization.
 - **FEAT**: remove initial date handling from date question components.
 - **FEAT**: enhance Answer class to support DateTime serialization in JSON.
 - **FEAT**: add DateQuestion and DateQuestionWidget for date selection in questionnaires.

## 4.8.1

 - **FIX**: upgrade deps.
 - **FIX**: upgrade deps.

## 4.8.0

 - **FIX**: migrate csv.
 - **FIX**: update to flutter v3.41.5.
 - **FEAT**: Add persistent user-defined study filters and active filter state to user preferences.

## 4.7.1

 - **FIX**(designer_v2): update code for Riverpod 3.x compatibility.
 - **FIX**: study length calculation and update localization for study schedule.

## 4.7.0

 - **REFACTOR**: improve code formatting and readability in body-related files.
 - **REFACTOR**: add localization support for Fitbit data sync messages and improve code formatting.
 - **REFACTOR**: improve code formatting and readability in localization and conditional question files.
 - **REFACTOR**: rename core FitbitCredentials to FitbitAuthCredentials.
 - **FIX**: upgrade package dependencies.
 - **FIX**: update dependencies and versions in pubspec.yaml and pubspec.lock.
 - **FIX**: remove trailing slashes from environment URLs to prevent double slashes in paths.
 - **FIX**: update conditional logic to use NumericComparator for better clarity.
 - **FIX**: pain question error on save.
 - **FIX**: make LogicType json compatible.
 - **FIX**: preserve ids for choices.
 - **FIX**: only throw ExtractionFailedException for study screen.
 - **FIX**: streams and dynamic cast bugs.
 - **FIX**: update conditionArray on changes correctly, only include latter questions.
 - **FIX**: rebuild form, enable preview, use currentQuestionId.
 - **FIX**: update deps.
 - **FIX**: add fitbit question json type to question model.
 - **FEAT**: update pain type in body pain and selector.
 - **FEAT**: pain type model.
 - **FEAT**: add pain type and body part children support.
 - **FEAT**: implement pain selection question inside designer.
 - **FEAT**: add pain selection question and body part selection widgets.
 - **FEAT**: initial version for conditional questions.
 - **FEAT**: update Fitbit credentials form and related dependencies.
 - **FEAT**: fitbit_credentials table and integration.
 - **FEAT**: update Fitbit data handling and syncing process.
 - **FEAT**(fitbit): update sleep data model and sleep fetch.
 - **FEAT**: sleep and step data.
 - **FEAT**: fitbit questionnaire form.
 - **FEAT**: fitbit credentials base for study model.

## 4.6.1

- **FIX**: update deps.

## 4.6.0

- **FIX**: bump dependencies.
- **FIX**: study reset process by removing unnecessary user ID handling.
- **FIX**: reset subject temp fix.
- **FEAT**: enhance study reset functionality to support user-specific data deletion.

## 4.5.0

- **FIX**: upgrade deps.
- **FEAT**: add Descriptive Stats section to the designer and core.
- **FEAT**: add gauge comparison section with form view.
- **FEAT**: add textual summary section to report with form view and validation.

## 4.5.0-dev.0

 - **REFACTOR**: rename core FitbitCredentials to FitbitAuthCredentials.
 - **FIX**: add fitbit question json type to question model.
 - **FEAT**: update Fitbit credentials form and related dependencies.
 - **FEAT**: fitbit_credentials table and integration.
 - **FEAT**: update Fitbit data handling and syncing process.
 - **FEAT**(fitbit): update sleep data model and sleep fetch.
 - **FEAT**: sleep and step data.
 - **FEAT**: fitbit questionnaire form.
 - **FEAT**: fitbit credentials base for study model.

## 4.4.9

 - **FIX**: upgrade deps and flutter v3.24.5.

## 4.4.8

 - **FIX**: upgrade deps.
 - **FIX**: upgrade fvm to flutter v3.24.3.

## 4.4.7

 - **FIX**: upgrade to flutter v3.24.2.
 - **FIX**: result history filter.

## 4.4.6

 - **FIX**: upgrade deps.

## 4.4.5

 - **FIX**: upgrade deps.

## 4.4.4

 - **FIX**: upgrade deps.
 - **FIX**: upgrade deps.

## 4.4.3

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 4.4.3-dev.2

 - **FIX**: keep eligibility criterion.
 - **FIX**: empty description init value.
 - **FIX**: formatting issues.
 - **FIX**: formatting issues.
 - **FIX**: migrate app to status.
 - **FIX**: users not able to continue closed study.
 - **FIX**: upgrade deps.
 - **FEAT**: deprecate published for study_status.
 - **FEAT**: close study using is_closed column.
 - **FEAT**: close study.

## 4.4.3-dev.1

 - **PERF**: improve dashboard study fetching.
 - **FIX**: formatting issues.
 - **FIX**: upgrade deps.

## 4.4.3-dev.0

 - **FIX**: upgrade deps.

## 4.4.2

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 4.4.2-dev.1

 - **REFACTOR**: improved app config error handling.

## 4.4.2-dev.0

 - **FIX**: upgrade deps and migrate.

## 4.4.1

 - **FIX**: check if result is QuestionnaireState. ([c7535804](https://github.com/hpi-studyu/studyu/commit/c7535804281f9bbdf757a2eb11df03940eceeec9))

## 4.4.0

 - **REFACTOR**: use upload again. ([af9ec38e](https://github.com/hpi-studyu/studyu/commit/af9ec38e99f28688eba63c8037e74213b9762481))
 - **REFACTOR**: rename path to blobPath. ([8517bd0f](https://github.com/hpi-studyu/studyu/commit/8517bd0f54432677e68b168a644baafe105550f0))
 - **REFACTOR**: move blob_storage_handler.dart and add download feature. ([9546e7d0](https://github.com/hpi-studyu/studyu/commit/9546e7d094286f28933fab5b7a50b7048b48215e))
 - **FIX**: defer upload of multimodal files. ([e8324cab](https://github.com/hpi-studyu/studyu/commit/e8324cabd5dc7b20d1be529ae8ba94d51ab5eb39))
 - **FIX**: delete multimodal data on leaving study. ([bcd3a461](https://github.com/hpi-studyu/studyu/commit/bcd3a4613b7f387585925128362624748f2ba655))
 - **FIX**: upgrade deps, move multimodal from core to app, migrate switch case. ([c4c1bd1e](https://github.com/hpi-studyu/studyu/commit/c4c1bd1e7e234535291b609deda21ea0e12b8506))
 - **FIX**: add versions to pub devs. ([6948ca1e](https://github.com/hpi-studyu/studyu/commit/6948ca1e60b6c3d6a740863a05ca6702079c8310))
 - **FIX**: upgrade deps (switch to wakelock_plus). ([1000d89c](https://github.com/hpi-studyu/studyu/commit/1000d89cd4df62bbfedfb5238f0e427c4d2d2c08))
 - **FEAT**: add offline handling for multimodal files. ([92e3d3b3](https://github.com/hpi-studyu/studyu/commit/92e3d3b3732543ecf2bcfa855cb20ef3cc3123de))
 - **FEAT**: add maximum recording duration to designer. ([c601e0ba](https://github.com/hpi-studyu/studyu/commit/c601e0ba1a327c01a2c88f5a323d24bbd558cdf3))

## 4.3.3

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 4.3.3-dev.5

 - **REFACTOR**: login process and offline mode. ([aab64a42](https://github.com/hpi-studyu/studyu/commit/aab64a429df81037eb6cd9c06b7eb89b282a1a05))
 - **REFACTOR**: improve return type of publishedPublicStudies(). ([fedec441](https://github.com/hpi-studyu/studyu/commit/fedec441fd4f0f39fe35e7cb89b2922a10ac9ea3))
 - **REFACTOR**: create abstract exception and rename ExtractedSupabaseListResult. ([5ef1bc43](https://github.com/hpi-studyu/studyu/commit/5ef1bc4378c2ac35e9781a040c4868910291794b))
 - **REFACTOR**: bind faulty studies to return value. ([e6b4ed70](https://github.com/hpi-studyu/studyu/commit/e6b4ed70d367ddb9e8b1e7fd0015d0f70a179a0c))
 - **REFACTOR**: remove ExtractedSupabaseListResult. ([0d3f4af9](https://github.com/hpi-studyu/studyu/commit/0d3f4af9d201556ba5ec0884741969e7dfa47b71))
 - **FIX**: upgrade deps. ([b491c9c4](https://github.com/hpi-studyu/studyu/commit/b491c9c469ee808fe1aaa50b7a50759be2378552))
 - **FIX**: make offline mode more reliable. ([45370246](https://github.com/hpi-studyu/studyu/commit/45370246253bfdf1a884a7e873ef68d4542e8e55))
 - **FIX**: remove unnecessary code. ([0634d971](https://github.com/hpi-studyu/studyu/commit/0634d971f9576be4ca663c6cc2f7543bab2374ff))
 - **FIX**: future-proof deserialization of studies. ([ca7c3145](https://github.com/hpi-studyu/studyu/commit/ca7c3145cd663dda47716ffa4ac5cef3fb25da84))
 - **FEAT**: rework deserialization of unsupported types to throw exception. ([54956cf1](https://github.com/hpi-studyu/studyu/commit/54956cf17c879dce27821da3a85f2d8d509542e7))

## 4.3.3-dev.4

 - **REFACTOR**: login process and offline mode. ([aab64a42](https://github.com/hpi-studyu/studyu/commit/aab64a429df81037eb6cd9c06b7eb89b282a1a05))
 - **REFACTOR**: improve return type of publishedPublicStudies(). ([fedec441](https://github.com/hpi-studyu/studyu/commit/fedec441fd4f0f39fe35e7cb89b2922a10ac9ea3))
 - **REFACTOR**: create abstract exception and rename ExtractedSupabaseListResult. ([5ef1bc43](https://github.com/hpi-studyu/studyu/commit/5ef1bc4378c2ac35e9781a040c4868910291794b))
 - **REFACTOR**: bind faulty studies to return value. ([e6b4ed70](https://github.com/hpi-studyu/studyu/commit/e6b4ed70d367ddb9e8b1e7fd0015d0f70a179a0c))
 - **REFACTOR**: remove ExtractedSupabaseListResult. ([0d3f4af9](https://github.com/hpi-studyu/studyu/commit/0d3f4af9d201556ba5ec0884741969e7dfa47b71))
 - **FIX**: upgrade deps. ([b491c9c4](https://github.com/hpi-studyu/studyu/commit/b491c9c469ee808fe1aaa50b7a50759be2378552))
 - **FIX**: make offline mode more reliable. ([45370246](https://github.com/hpi-studyu/studyu/commit/45370246253bfdf1a884a7e873ef68d4542e8e55))
 - **FIX**: remove unnecessary code. ([0634d971](https://github.com/hpi-studyu/studyu/commit/0634d971f9576be4ca663c6cc2f7543bab2374ff))
 - **FIX**: check min app version improvements. ([8d36dc78](https://github.com/hpi-studyu/studyu/commit/8d36dc78771d748483bbf3ad22794a95e73dad06))
 - **FIX**: future-proof deserialization of studies. ([ca7c3145](https://github.com/hpi-studyu/studyu/commit/ca7c3145cd663dda47716ffa4ac5cef3fb25da84))
 - **FEAT**: rework deserialization of unsupported types to throw exception. ([54956cf1](https://github.com/hpi-studyu/studyu/commit/54956cf17c879dce27821da3a85f2d8d509542e7))
 - **FEAT**: check min app version and force update. ([08f33618](https://github.com/hpi-studyu/studyu/commit/08f3361865aa4b158e9e29e69efd30547db9991a))

## 4.3.3-dev.3

 - **FIX**: upgrade deps. ([5327eb97](https://github.com/hpi-studyu/studyu/commit/5327eb971e6673847dc09ef56923b6a73ae73654))

## 4.3.3-dev.2

 - **FIX**: upgrade deps. ([6ad9bea4](https://github.com/hpi-studyu/studyu/commit/6ad9bea42903a25a5be5a84f2af8b70654d05616))
 - **FIX**: update gitignore files. ([939d6be4](https://github.com/hpi-studyu/studyu/commit/939d6be422ee37f2ea56b39bb3921060fd1844cd))
 - **FIX**: upgrade deps. ([7ac0d4ca](https://github.com/hpi-studyu/studyu/commit/7ac0d4cab42b1ce27ec200a5241f92d612ade499))
 - **FIX**: upgrade deps. ([3e186fc4](https://github.com/hpi-studyu/studyu/commit/3e186fc409f038102cc5fd1e6d11b73057dab8d7))

## 4.3.3-dev.1

 - **REFACTOR**: rename analytics. ([98386b03](https://github.com/hpi-studyu/studyu/commit/98386b03ada1a47d28469afbd15e3bde411ef6b9))
 - **REFACTOR**: enable cache again and add new logger. ([e0ad446f](https://github.com/hpi-studyu/studyu/commit/e0ad446fe03c94261782606a186a0364dbe87428))
 - **REFACTOR**: rename free text attributes. ([f145b425](https://github.com/hpi-studyu/studyu/commit/f145b425e885501993f5ec60aa5028c68024cb0a))
 - **FIX**: upgrade deps. ([3e186fc4](https://github.com/hpi-studyu/studyu/commit/3e186fc409f038102cc5fd1e6d11b73057dab8d7))
 - **FIX**: quickfix for free text eligibility. ([5bb2e42b](https://github.com/hpi-studyu/studyu/commit/5bb2e42b89383611fd9cd0882c1cdb6df4c07544))
 - **FIX**: upgrade deps. ([304430c8](https://github.com/hpi-studyu/studyu/commit/304430c858d4035a279b42114c7ccf86299357a2))
 - **FIX**: upgrade deps. ([1940357e](https://github.com/hpi-studyu/studyu/commit/1940357e4d9975743c0913825aa585958410ebca))
 - **FIX**: type checks and matching. ([92629cb4](https://github.com/hpi-studyu/studyu/commit/92629cb4395d8e456a0531647d6ba1de4a77a92f))
 - **FIX**: type checks. ([b85e073d](https://github.com/hpi-studyu/studyu/commit/b85e073d7075b8d45d15f32e62d5761416cdad4a))
 - **FEAT**: implement free_text for designer. ([f0ce3512](https://github.com/hpi-studyu/studyu/commit/f0ce3512f28b1eaae1bc69f75701038e42e6936d))

## 4.3.3-dev.0

 - **FIX**: upgrade deps. ([304430c8](https://github.com/hpi-studyu/studyu/commit/304430c858d4035a279b42114c7ccf86299357a2))
 - **FIX**: type checks and matching. ([92629cb4](https://github.com/hpi-studyu/studyu/commit/92629cb4395d8e456a0531647d6ba1de4a77a92f))
 - **FIX**: type checks. ([b85e073d](https://github.com/hpi-studyu/studyu/commit/b85e073d7075b8d45d15f32e62d5761416cdad4a))

## 4.3.2

 - **FIX**: upgrade deps. ([f37d0a71](https://github.com/hpi-studyu/studyu/commit/f37d0a711ab9a126b7da13b7eb4fbb9b784f3725))
 - **FIX**: upgrade deps. ([567a3b07](https://github.com/hpi-studyu/studyu/commit/567a3b07c360e55da62898e928a794a756ab0546))

## 4.3.1

 - **FIX**: upgrade deps. ([567a3b07](https://github.com/hpi-studyu/studyu/commit/567a3b07c360e55da62898e928a794a756ab0546))

## 4.3.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 4.3.0-dev.10

 - **FIX**: upgrade deps. ([6fa0e8b8](https://github.com/hpi-studyu/studyu/commit/6fa0e8b8332c0872b59c7c31042fb845f0708e73))

## 4.3.0-dev.9

 - **FIX**: upgrade deps. ([7cdc7c55](https://github.com/hpi-studyu/studyu/commit/7cdc7c559f64cfdd63ee07efbeeb028c418f6f4e))
 - **FIX**: upgrade deps. ([17213746](https://github.com/hpi-studyu/studyu/commit/172137469ed236dc694979bbfe017708faabbd77))

## 4.3.0-dev.8

 - **FIX**: make analytics fully optional. ([67d58887](https://github.com/hpi-studyu/studyu/commit/67d588879a69a9105cd2e54c08f2a2feae1224a2))
 - **FIX**: upgrade deps. ([aa2cb251](https://github.com/hpi-studyu/studyu/commit/aa2cb2512e3db4e31f97edea8d2bccf55e91f9d2))
 - **FIX**: study was not returned completely. ([324e2ceb](https://github.com/hpi-studyu/studyu/commit/324e2ceb2afe25df5ee06cd2450865137efe7ae1))
 - **FIX**: make Repo urls optional. ([d0a96ea8](https://github.com/hpi-studyu/studyu/commit/d0a96ea8413bed3e86a4448da6f06b35b4b9adca))
 - **FIX**: tag color. ([9baddd1d](https://github.com/hpi-studyu/studyu/commit/9baddd1d3df22ebb45fa5117f724fd9b98b31b98))
 - **FIX**: tag related sql. ([59882b7e](https://github.com/hpi-studyu/studyu/commit/59882b7e86b7145131733c4d6851cf621b676fc8))
 - **FIX**: study_tags was null for new studies. ([db57e09f](https://github.com/hpi-studyu/studyu/commit/db57e09f841164b39d587c5ba6479a1f7a73b57e))
 - **FIX**: make color nullable and int, add tags to dashboard. ([ef7532a3](https://github.com/hpi-studyu/studyu/commit/ef7532a3e571abd140cfbeee1e2e1b6fd14f9ed6))
 - **FIX**: tag type. ([cf39195b](https://github.com/hpi-studyu/studyu/commit/cf39195b540fe6b65e4d600586041b3c19d90d52))
 - **FEAT**: working tags with foreign key study_tag. ([8d4eaa92](https://github.com/hpi-studyu/studyu/commit/8d4eaa925c8a921bfa70f0afae6a57a155a55c9e))
 - **FEAT**: display and update tags correctly. ([b96dcf8a](https://github.com/hpi-studyu/studyu/commit/b96dcf8a25def52dfc59bc65206177e0ab4a25d8))
 - **FEAT**: initial study tags. ([615d5b62](https://github.com/hpi-studyu/studyu/commit/615d5b629a2ae5d9998d50b1a0f119fa62a2bc87))

## 4.3.0-dev.7

 - **FIX**: upgrade deps (switch to wakelock_plus). ([177e5057](https://github.com/hpi-studyu/studyu/commit/177e5057fb41821a2f924ffda79e1faa3119859d))
 - **FIX**: upgrade deps (switch to wakelock_plus). ([9112f5f0](https://github.com/hpi-studyu/studyu/commit/9112f5f0a9c778e2abf24f6aa585bc9f539e6ccf))

## 4.3.0-dev.6

 - **FIX**: upgrade deps (switch to wakelock_plus). ([9112f5f0](https://github.com/hpi-studyu/studyu/commit/9112f5f0a9c778e2abf24f6aa585bc9f539e6ccf))

## 4.3.0-dev.5

 - **FIX**: add await-workflow action to wait for pub.dev publishing. ([7206a006](https://github.com/hpi-studyu/studyu/commit/7206a00663657f6d6256b99b0c3aca33e9b263bb))

## 4.3.0-dev.4

 - **FIX**: upgrade deps. ([35c629aa](https://github.com/hpi-studyu/studyu/commit/35c629aa28fc5761a707168d998a425307ec6d9a))

## 4.3.0-dev.3

 - **FIX**: upgrade deps. ([b2926c39](https://github.com/hpi-studyu/studyu/commit/b2926c395988077d4aa172490dbd9c6fd75d52c6))
 - **FIX**: upgrade deps. ([daad1465](https://github.com/hpi-studyu/studyu/commit/daad146590e874bedee3f82bb72bf4b94e5c3801))

## 4.3.0-dev.2

 - **FIX**: upgrade deps. ([daad1465](https://github.com/hpi-studyu/studyu/commit/daad146590e874bedee3f82bb72bf4b94e5c3801))

## 4.3.0-dev.1

 - **FIX**: analytics same key. ([b2412c42](https://github.com/hpi-studyu/studyu/commit/b2412c422263c8f1e08f5fe6197ac412fe5941c6))

## 4.3.0-dev.0

 - **FEAT**: store analytics data in the backend and support caching. ([f3e70610](https://github.com/hpi-studyu/studyu/commit/f3e7061081f631d74c6df0ea78024ace6ea1f333))

## 4.2.0

 - **FEAT**: implement limited offline mode for app. ([cbc898f3](https://github.com/hpi-studyu/studyu/commit/cbc898f34a47535e8f950365ded92ef210137e23))

## 4.1.0

 - **FIX**: slider design overhaul. ([75589ca1](https://github.com/hpi-studyu/studyu/commit/75589ca1f443f4ef779a8766cc9150cda74fb3bb))
 - **FIX**: slider design overhaul. ([b5a6b8ad](https://github.com/hpi-studyu/studyu/commit/b5a6b8ad18c67d2ab5b21313ff5740f175d9b7eb))
 - **FEAT**: sentry integration in core. ([0fae767f](https://github.com/hpi-studyu/studyu/commit/0fae767f0a7dc3c3409dd5179eeb870429b580cd))

## 4.0.2

 - **FIX**: slider design overhaul. ([b5a6b8ad](https://github.com/hpi-studyu/studyu/commit/b5a6b8ad18c67d2ab5b21313ff5740f175d9b7eb))

## 4.0.1

 - **FIX**: upgrade deps to fix invalid refresh token bug. ([6a4da159](https://github.com/hpi-studyu/studyu/commit/6a4da1594d7baed5d76f74464670ec411abc961c))

## 4.0.0

 - Graduate package to a stable release. See pre-releases prior to this version for changelog entries.

## 4.0.0-dev.5

 - **FIX**: do not schedule notifications for not started studies. ([b57f57c3](https://github.com/hpi-studyu/studyu/commit/b57f57c30a798030171a9bbcd32a5fb109bb20c0))
 - **FIX**: use utc for all datetime comparisons. ([e20e6bd8](https://github.com/hpi-studyu/studyu/commit/e20e6bd8e4c5174a22cd97840fa45ddf663e2359))
 - **FIX**: revert scheduleFor workaround. ([5bec03e9](https://github.com/hpi-studyu/studyu/commit/5bec03e9743e2db047db710361d3d2cecc10e25f))

## 4.0.0-dev.4

 - **FIX**: fallback to check for progress without a periodId. ([146e1bae](https://github.com/hpi-studyu/studyu/commit/146e1bae80291bcd9d8fab853a2770a807da4393))

## 4.0.0-dev.3

 - **FIX**: choice expression v2 workaround. ([2368d8c8](https://github.com/hpi-studyu/studyu/commit/2368d8c8eb2a97f76bc38bfd374a4d59ad7efbb9))
 - **FIX**: show dashboard correctly for the day if intervention cycle occurs. ([f4eba956](https://github.com/hpi-studyu/studyu/commit/f4eba956be2509643c17530385f151d7e3937c0f))

## 4.0.0-dev.2

 - **FIX**: designerV2 TaskInstance support for single completionperiods to restore live preview functionality. ([45792baf](https://github.com/hpi-studyu/studyu/commit/45792bafb0291914228ed4af058c821eb6be2f6d))
 - **FIX**: designerV2 TaskInstance support for single completionperiods to restore live preview functionality. ([6a85f162](https://github.com/hpi-studyu/studyu/commit/6a85f16252b91f9d8dc3b92f7deb00fef293f032))
 - **FIX**: notification have wrong ids. ([144b8d7d](https://github.com/hpi-studyu/studyu/commit/144b8d7dc834e0b0d38f5ae4a0f658300f4af073))
 - **FIX**: task instance named constructor. ([c88094f1](https://github.com/hpi-studyu/studyu/commit/c88094f1d7eb007f1926c2f7281b7d89a4a4dc3d))
 - **FIX**: only get selected intervention tasks for completed check. ([5f2ae32d](https://github.com/hpi-studyu/studyu/commit/5f2ae32d743c210fa4c2e780a0ec73b76d177360))
 - **FIX**: pointerinterceptor for survey. ([077290c0](https://github.com/hpi-studyu/studyu/commit/077290c016750df836be8765c82de0497cf35faf))
 - **FEAT**: rename TimedTask to TaskInstance and make it mandatory. ([42f4ee14](https://github.com/hpi-studyu/studyu/commit/42f4ee14dd1d30c0df11b8e3e221c842c3fcc8af))

## 4.0.0-dev.1

 - **FIX**: merge issues. ([8a560314](https://github.com/hpi-studyu/studyu/commit/8a560314c14fcf3e37e9d40f7129a4db483e8a8a))
 - **FIX**: report null value. ([8602cc10](https://github.com/hpi-studyu/studyu/commit/8602cc10b427ac9a67c7b44b46f57ba1b72d4768))
 - **FIX**: notification debug mode, do not schedule past notifications. ([366d6886](https://github.com/hpi-studyu/studyu/commit/366d68867811f9d5332a7be41b48e5db30441aca))
 - **FIX**: update outdated stuff and dart generate. ([82b58bdc](https://github.com/hpi-studyu/studyu/commit/82b58bdcbf6f077003398b1a19813aa35a36bd91))
 - **FIX**: typo. ([be191ab9](https://github.com/hpi-studyu/studyu/commit/be191ab95ce9477742666ddf06e571cff6ceff65))
 - **FIX**: upgrade supabase_flutter (^1.3.1) and supabase (^1.4.0). ([88e6dad4](https://github.com/hpi-studyu/studyu/commit/88e6dad4cbf6f5847fe382e7969ec2e13a1dee44))
 - **FIX**: migration. ([3ac8f192](https://github.com/hpi-studyu/studyu/commit/3ac8f192d4191eed640340e1292bcdd1c64ece98))
 - **FIX**: do not show interventions with empty titles. ([2a9abe76](https://github.com/hpi-studyu/studyu/commit/2a9abe764d245062548cff5a1a43251a9fc14a4f))
 - **FIX**: Skip consentCheck if study doesn't have one. ([5675d92a](https://github.com/hpi-studyu/studyu/commit/5675d92af89849bf8fb22ee99bfcf5a61408b5a4))
 - **FIX**: upgrade to flutter 3.7.0. ([2aa80015](https://github.com/hpi-studyu/studyu/commit/2aa80015a22161773649790edf2c38742809c45b))
 - **FIX**: remove form_builder_extra_fields in favor of flex_color_picker due to flutter version incompatibility. ([1e21b738](https://github.com/hpi-studyu/studyu/commit/1e21b738fcc3f0e1a13beb62ccd08c752d35930e))
 - **FIX**: upgrade deps. ([1b411140](https://github.com/hpi-studyu/studyu/commit/1b41114080e405c385c15b7beb8d140193656e6a))
 - **FEAT**: early release customSequence. ([f65c64d7](https://github.com/hpi-studyu/studyu/commit/f65c64d7a828125c7f36e3dcf08262e42f78ba29))
 - **FEAT**: - Results of tasks with multiple completion periods are now saved uniquely. ([bf9e2818](https://github.com/hpi-studyu/studyu/commit/bf9e2818b5dc88102f69a7e773b5f9ccea0e7c73))

## 3.8.2

 - **FIX**: notification debug mode, do not schedule past notifications. ([366d6886](https://github.com/hpi-studyu/studyu/commit/366d68867811f9d5332a7be41b48e5db30441aca))

## 3.8.1

 - **FIX**: migration. ([3ac8f192](https://github.com/hpi-studyu/studyu/commit/3ac8f192d4191eed640340e1292bcdd1c64ece98))

## 3.8.0

 - **FIX**: do not show interventions with empty titles. ([2a9abe76](https://github.com/hpi-studyu/studyu/commit/2a9abe764d245062548cff5a1a43251a9fc14a4f))
 - **FIX**: Skip consentCheck if study doesn't have one. ([5675d92a](https://github.com/hpi-studyu/studyu/commit/5675d92af89849bf8fb22ee99bfcf5a61408b5a4))
 - **FIX**: upgrade to flutter 3.7.0. ([2aa80015](https://github.com/hpi-studyu/studyu/commit/2aa80015a22161773649790edf2c38742809c45b))
 - **FIX**: remove form_builder_extra_fields in favor of flex_color_picker due to flutter version incompatibility. ([1e21b738](https://github.com/hpi-studyu/studyu/commit/1e21b738fcc3f0e1a13beb62ccd08c752d35930e))
 - **FIX**: upgrade deps. ([1b411140](https://github.com/hpi-studyu/studyu/commit/1b41114080e405c385c15b7beb8d140193656e6a))
 - **FIX**: answer parse error. ([a47e1fb3](https://github.com/hpi-studyu/studyu/commit/a47e1fb3521cbc5b2a40ebb3dd3a9e3020699f56))
 - **FEAT**: - Results of tasks with multiple completion periods are now saved uniquely. ([bf9e2818](https://github.com/hpi-studyu/studyu/commit/bf9e2818b5dc88102f69a7e773b5f9ccea0e7c73))

## 4.0.0-dev.0

> Note: This release has breaking changes.

 - **FIX**: upgrade deps. ([4b011445](https://github.com/hpi-studyu/studyu/commit/4b011445bb2390570c536646bb119b5a00a809ab))
 - **FIX**: password reset. ([5c3fda47](https://github.com/hpi-studyu/studyu/commit/5c3fda4791bd5aed957dbe721babe701fb462f50))
 - **FIX**: leave study with soft delete & delete data option with hard delete. ([8006f0f6](https://github.com/hpi-studyu/studyu/commit/8006f0f6c9a63eb6ede1b9b25f8dc77b1fef7616))
 - **FIX**: correctly position annotations / labels for scale questions. ([acfa3524](https://github.com/hpi-studyu/studyu/commit/acfa3524fcc7e9c2f5237398e271b9390fe6e1e1))
 - **FIX**: make autosave indicator work again. ([6664589f](https://github.com/hpi-studyu/studyu/commit/6664589f27195190dcf21cebdc77719af5db19c0))
 - **FIX**: null error when loading appconfig. ([ef720c47](https://github.com/hpi-studyu/studyu/commit/ef720c47744b03797dcf7fd51e063579bf6642be))
 - **FIX**: answer parse error. ([a47e1fb3](https://github.com/hpi-studyu/studyu/commit/a47e1fb3521cbc5b2a40ebb3dd3a9e3020699f56))
 - **FIX**: Json serialization bug & remove copy draft redirect. ([39860a45](https://github.com/hpi-studyu/studyu/commit/39860a45329ad55fdea66968d91f2edd596ef3ec))
 - **FEAT**: enable screening logic for scale questions. ([4f956be1](https://github.com/hpi-studyu/studyu/commit/4f956be135f9b8c36304d22166c5b2a751be1ee3))
 - **FEAT**: colored scale questions. ([305377d3](https://github.com/hpi-studyu/studyu/commit/305377d38d59f42c7d310a58b2b1b61cf85922c2))
 - **FEAT**: improve scale widget in app. ([1d2652aa](https://github.com/hpi-studyu/studyu/commit/1d2652aa5e3fd1d7dcc929ebf7f69b004b5f3147))
 - **FEAT**: add scale question-type to app + improved annotation layout. ([169ef10d](https://github.com/hpi-studyu/studyu/commit/169ef10d145a0b4e9da104af9fd22817b1c14d82))
 - **FEAT**: implement study registry properly. ([1cc329c0](https://github.com/hpi-studyu/studyu/commit/1cc329c0e2d119f19994b5f1be0f490a03ebb3b1))
 - **FEAT**: dont record participant progress for launched studies in test mode. ([2dc6a8ca](https://github.com/hpi-studyu/studyu/commit/2dc6a8ca72785d8929b3ecf3451d352c893fabde))
 - **FEAT**: data export. ([1a099135](https://github.com/hpi-studyu/studyu/commit/1a099135d66b1a2bc25bfed8d1e10cf5c6e48a78))
 - **FEAT**: Add createdAt key to Study object. ([7ac66a40](https://github.com/hpi-studyu/studyu/commit/7ac66a40e0fbe5b5385d92dd24342201316a0288))
 - **BREAKING** **CHANGE**: Database changes, so that only studies which are both published and open can be viewed. ([f8e85013](https://github.com/hpi-studyu/studyu/commit/f8e85013a23dd0450ce75e97fa0d751c6d4af055))

## 3.7.15

 - **FIX**: upgrade deps. ([d221eae7](https://github.com/hpi-studyu/studyu/commit/d221eae7ea55fa8761d7ff7625f92eaa3488148e))
 - **FIX**: update factories for json sequelize update. ([2970b00f](https://github.com/hpi-studyu/studyu/commit/2970b00f00cc4644238f5186821d45c8b6a9fc2e))
 - **FIX**: update generated *.g.dart files. ([a931675c](https://github.com/hpi-studyu/studyu/commit/a931675ca4fad8fe24f873c9d97e4c7d4739972d))

## 3.7.14

 - **FIX**: upgrade dependencies. ([bc8cda17](https://github.com/hpi-studyu/studyu/commit/bc8cda17561511d8ec05ce13bc9fcba644768ef5))

## 3.7.13

 - **FIX**: upgrade deps. ([c16d7722](https://github.com/hpi-studyu/studyu/commit/c16d7722719efa732392d0f04bf74f4eefd95406))

## 3.7.12

 - **FIX**: upgrade deps. ([18dc5206](https://github.com/hpi-studyu/studyu/commit/18dc5206aff15093338a3973ef4196ea9d78d922))

## 3.7.11

 - **FIX**: upgrade deps. ([dca763c6](https://github.com/hpi-studyu/studyu/commit/dca763c6f5531c725148bb99e25c2a2debdeadd6))

## 3.7.10

 - **FIX**: upgrade deps. ([d14c52dd](https://github.com/hpi-studyu/studyu/commit/d14c52dd492bb2e6ceed941a2d33a053276629f4))
 - **FIX**: Upgrade fl_chart to 0.46 and fix minor breaking change. ([c0399ba9](https://github.com/hpi-studyu/studyu/commit/c0399ba9f622383a6dae8002ea1c2d1aca2edc16))

## 3.7.9

 - **FIX**: Upgrade fl_chart to 0.46 and fix minor breaking change. ([c0399ba9](https://github.com/hpi-studyu/studyu/commit/c0399ba9f622383a6dae8002ea1c2d1aca2edc16))
 - **FIX**: Adjust to breaking dependencies. ([2f4e14bc](https://github.com/hpi-studyu/studyu/commit/2f4e14bc0a5858f18a2883a7ce3ea38e30a2b8fe))

## 3.7.8

 - **FIX**: Adjust to breaking dependencies. ([2f4e14bc](https://github.com/hpi-studyu/studyu/commit/2f4e14bc0a5858f18a2883a7ce3ea38e30a2b8fe))

## 3.7.7

 - **FIX**: Upgrade dependencies. ([31ca516b](https://github.com/hpi-studyu/studyu/commit/31ca516be6518de7a41f4762b669f9059c83f3bc))

## 3.7.6

 - **FIX**: Fix linting and fix lints. ([765b3525](https://github.com/hpi-studyu/studyu/commit/765b3525c89255bbf983a825bedc45a5ef7d8706))
 - **FIX**: Upgrade flutter packages. ([d5d0387a](https://github.com/hpi-studyu/studyu/commit/d5d0387a9a7df464861070be44a9931d2ebb0547))
 - **FIX**: Upgrade deps. ([27f6e8bc](https://github.com/hpi-studyu/studyu/commit/27f6e8bc4526b14320d6d1ca3657db55db2e7c5c))

## 3.7.5

 - **FIX**: Revert "fix: Update generated files". ([5e512f89](https://github.com/hpi-studyu/studyu/commit/5e512f890774c52e794ac63ee87a556e5188e193))

## 3.7.4

 - **FIX**: Upgrade dependencies. ([f59a9989](https://github.com/hpi-studyu/studyu/commit/f59a9989be6238576a20f5288951745345ec84af))
 - **FIX**: Update generated files. ([0627db30](https://github.com/hpi-studyu/studyu/commit/0627db3064a44d0538aa490868f7332411a1347c))

## 3.7.3

 - **REFACTOR**: Import symbols from supabase package.
 - **FIX**: Use this.toJson.
 - **CHORE**: Upgrade deps.

## 3.7.2

 - **FIX**: Upgrade deps.

## 3.7.1

 - **FIX**: Make appUrl and projectGeneratorUrl nullable.

## 3.7.0

 - **FEAT**: Add ability to initialize with existing.
 - **CHORE**: Upgrade deps.

## 3.6.0

 - **FIX**: Return empty CSV if no results yet.
 - **FEAT**: Add gitUrl and webUrl.
 - **CHORE**: Upgrade deps.

## 3.5.0

 - **FIX**: Update deeplinks for designer.
 - **FEAT**: Add fetchResultsCSVTable.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps; Generate json_serializable.
 - **CHORE**: Use pub.dev hosted version of core and common.

## 3.4.2

 - **FIX**: Correct column snail case naming.

## 3.4.1

 - **REFACTOR**: Make supabase vars public.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 3.4.0

 - **FEAT**: Add method to check if elgibility is defined.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 3.3.2

 - **REFACTOR**: Table columns now have underscores.
 - **REFACTOR**: No need to use late init here.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 3.3.1

 - **FIX**: Do not require stats to be fetched.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 3.3.0

 - **FEAT**: Add app url env var.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 3.2.0

 - **REFACTOR**: Add default constructor for TimeOfDay.
 - **FIX**: Add default times.
 - **FEAT**: Add contains to CompletionPeriod.
 - **FEAT**: Spilt reminderTime and unlock/locking times.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: publish packages.
 - **CHORE**: publish packages.

## 3.1.0

 - **FIX**: Fetch Subject with Study and Progress.
 - **FEAT**: Indicate days left in current intervention.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Add pub.dev release needed files.

## 3.0.1

 - **FIX**: Upgrade supabase -> Fix jwt expired.
 - **CHORE**: Add status error logging.

## 3.0.0

> Note: This release has breaking changes.

 - **STYLE**: Format.
 - **STYLE**: Address lints.
 - **REFACTOR**: Filtering published studies now via RLS.
 - **REFACTOR**: Cleanup app language.
 - **REFACTOR**: Rename numberOfPhases => numberOfInterventions.
 - **REFACTOR**: Add isBaseline to Intervention.
 - **REFACTOR**: Rename StudyUConfig->AppConfig.
 - **REFACTOR**: Rename studyou_core -> studyu_core.
 - **REFACTOR**: Split Visibility into Participation and ResultSharing.
 - **REFACTOR**: Self manage state.
 - **REFACTOR**: Replace deprecated buttons with new ones.
 - **REFACTOR**: Change StudyQueries to dart extensions.
 - **REFACTOR**: Load env from common.
 - **REFACTOR**: Move StudyQueries to model class.
 - **REFACTOR**: No need for extensions.
 - **REFACTOR**: Core only uses dart; added flutter common.
 - **REFACTOR**: Repo Provider->GitProvider.
 - **REFACTOR**: Questionnaire -> StudyUQuestionnaire.
 - **REFACTOR**: Rename StudySubject variables to subject.
 - **REFACTOR**: AVOID using cast(); Use List.from.
 - **REFACTOR**: Generate ids on client.
 - **REFACTOR**: Remove unneeded result properties.
 - **REFACTOR**: Save results in separate table.
 - **REFACTOR**: Rename UserStudy -> StudySubject.
 - **REFACTOR**: startDate -> startedAt.
 - **REFACTOR**: Generate startDate on server.
 - **REFACTOR**: Pass interventionIds.
 - **REFACTOR**: Replace InterventionSet with List<Intervention>.
 - **REFACTOR**: Migrate Parse to Supabase.
 - **REFACTOR**: Make everything late, since set fromJson.
 - **REFACTOR**: Do not include baseline in generateWith.
 - **REFACTOR**: Embed Study in userStudy.
 - **REFACTOR**: Add json_serializable to tables.
 - **REFACTOR**: Migrate to null-safety.
 - **REFACTOR**: Prepare for null-safety.
 - **REFACTOR**: Make more methods static.
 - **REFACTOR**: Further improvements to SupabaseObjects.
 - **REFACTOR**: Add default tableName to SupabaseObject.
 - **REFACTOR**: Time->ScheduleTime for less collisions.
 - **REFACTOR**: Reorg core library.
 - **REFACTOR**: Improve Supabase objects.
 - **REFACTOR**: Move ParseConfig queries to core.
 - **REFACTOR**: Restructure package.
 - **REFACTOR**: Only save selectedInterventions in DB.
 - **FIX**: Fix compatibility with newest beta.
 - **FIX**: Fix installation-id for back4app.
 - **FIX**: Don't call constructor to call extension.
 - **FIX**: Do not depend on flutter.
 - **FIX**: Make some attributes optional.
 - **FIX**: Remove dotenv dependency.
 - **FIX**: Use clientKey instead of masterKey.
 - **FIX**: Fix missing selected keys for csv download.
 - **FIX**: Add redirectTo for non web.
 - **FIX**: Masterkey needed to create a user.
 - **FIX**: Use ParseHTTPClient for web bc faster.
 - **FIX**: Results only working for questionnaires.
 - **FIX**: Only fetch keys required for study selection.
 - **FIX**: Fix error display on start.
 - **FIX**: Make fhirQuestionnaire not required.
 - **FIX**: Fix for CI.
 - **FIX**: Fix next day creating more progress.
 - **FIX**: redirectTo now working thanks to.
 - **FIX**: ParseInit not reloading on error.
 - **FIX**: Add default study icon.
 - **FIX**: ParseFetchOneFutureBuilder refresh.
 - **FIX**: json_serializer DateTime.parse needs toString.
 - **FIX**: Scaffold.of deprecated.
 - **FIX**: Default study participation is invite only.
 - **FIX**: Fix release build web: Remove type.toString.
 - **FIX**: Future retry button not reloading.
 - **FIX**: Return null rather than failing to parse.
 - **FIX**: resultProperty can be null.
 - **FIX**: Force reload if parse query different.
 - **FIX**: Upgrade packages to beta channel.
 - **FEAT**: Add preselectedInterventionIds.
 - **FEAT**: Show name of sequence ABBA, ABAB.
 - **FEAT**: Use fhir questionnaire with fallback.
 - **FEAT**: Add login screen.
 - **FEAT**: Add StudyToken model.
 - **FEAT**: Add data logging to error.
 - **FEAT**: Add Github/GitLab login via gotrue.
 - **FEAT**: Add FHIR Questionnaire Widget.
 - **FEAT**: Add header, footer to task.
 - **FEAT**: Rework terms & privacy screen.
 - **FEAT**: Add 3 statistics to study.
 - **FEAT**: Add more study statistic and helpers.
 - **FEAT**: Add primaryKeyFiler.
 - **FEAT**: Add IRB contact field.
 - **FEAT**: Add visibility and userId to study.
 - **FEAT**: Replace User with locally generated UUID.
 - **FEAT**: Add FileSaveDialog + Gradle upgrade.
 - **FEAT**: Add invites to study model.
 - **FEAT**: Add support for study invite code.
 - **FEAT**: Add collaborators.
 - **FEAT**: Move edit button to fab + fixes.
 - **FEAT**: Add editorEmails + helpers to Study.
 - **FEAT**: Add update repo study data.
 - **FEAT**: Rearrange studies on dashboard.
 - **CI**: Update format of .g.dart files.
 - **CHORE**: Add mono_repo config.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Setup .env files again.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove deps override.
 - **CHORE**: Use gotrue from git.
 - **CHORE**: Upgrade Parse to Null-safety.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Move packages to null-safety.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade lint to 1.5.3.
 - **CHORE**: Format code.
 - **CHORE**: Rename packages + prefix with studyu.
 - **CHORE**: Remove rule which is now part of lint.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade supabase deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade dependencies.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Rename StudyToken -> StudyInvite.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade parse sdk.
 - **CHORE**: Upgrade deps mostly stable null-safety deps.
 - **CHORE**: Replace deprecated upsert.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Adjust formatting.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade pdf to 2.0.0.
 - **CHORE**: Cleanup json_annotation remains.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Enable for core; remove avoid_as.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Add comment about keeping toString.
 - **CHORE**: Upgrade dependencies.
 - **CHORE**: Add melos, tool for managing packages.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove unused file.
 - **CHORE**: Remove left over gitlab ci.
 - **CHORE**: Add publish_to: none for linter.
 - **CHORE**: fix formatting.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Remove mono_repo files.
 - **CHORE**: Add master key env var.
 - **CHORE**: Adapt docker setup to supabase and melos.
 - **CHORE**: Upgrade parse sdk.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Downgrade parse to working commit.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Switch back to parse sdk repo.
 - **CHORE**: Upgrade packages.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **CHORE**: Upgrade deps.
 - **BREAKING** **REFACTOR**: Merge StudyDetails into Study.

