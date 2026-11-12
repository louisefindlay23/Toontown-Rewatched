# App Intents Integration Tests

`AppIntentsIntegrationTests.swift` belongs to the **TTR Rewatched App Intents Tests** watchOS UI test target. It imports AppIntentsTesting, not the app's Swift source, so it queries and invokes the installed app through Apple's App Intents infrastructure.

Requires Xcode with AppIntentsTesting and a watchOS 27.2 or newer device or simulator. The APIs are declared available from watchOS 27, but the framework binary shipped with this Xcode requires 27.2 (the 27.0 simulator fails to load it with a missing `DeferredValueResolverFactory` symbol). Only the integration test target requires watchOS 27.2; the shipping app continues to target watchOS 9. The test runner uses the app's existing signing team and a separate test bundle identifier.

## Run in Xcode

1. Open `TTR Rewatched.xcodeproj`.
2. Choose **TTR Rewatched App Intents Tests** in the scheme menu.
3. Choose your connected Apple Watch or a watchOS 27.2 or newer simulator as the destination.
4. Choose **Product > Test** (Command-U).
5. Open the Report navigator (Command-9) to inspect the result and any error.

The test launches the watch app, resolves Toontown Central questions through the registered entity query, checks their identifiers, and runs `BestStreetIntent` with the resolved entities. Expected answers are Punchline Place at 40 percent for Cashbot and Silly Street at 25 percent for Bossbot.

An entity lookup failure identifies a registration/query problem. An invocation error identifies a system dispatch or parameter transfer problem. A wrong answer identifies an output problem. A passing test confirms those paths work, but does **not** confirm Siri recognizes speech, chooses the intent, or speaks/displays the custom dialog. The testing framework's resolved result exposes the returned value, not Siri's final presentation.

The existing **TTR Rewatched Watch AppTests** scheme remains the separate macOS unit test suite for street ranking and query logic.

## If the runner cannot start

A timeout while enabling automation mode happens before the test assertions. Keep the physical Watch unlocked and connected, confirm Developer Mode is enabled, and retry Product > Test in Xcode. Treat this as an unexecuted integration test, not a passing or failing intent assertion.

If a simulator reports a missing symbol in AppIntentsTypeSupport, check its OS version against the framework binary in your installed Xcode. A watchOS 27.0 simulator is incompatible with the AppIntentsTesting binary in the current Xcode; use 27.2 or later.
