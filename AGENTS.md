# AGENTS.md

This is a watchOS-only app. I'm new to Swift and Xcode, so explain unfamiliar concepts briefly and provide clear testing instructions.

## Compatibility
- Treat watchOS compatibility as mandatory. Verify every API, framework, SwiftUI modifier and dependency against the project's actual watchOS deployment target.
- Use Apple's official documentation and compiler diagnostics. Never assume iOS examples or APIs work on watchOS; avoid UIKit and other unsupported APIs.
- Follow watchOS design, lifecycle and resource constraints. Investigate uncertain compatibility before implementing.
- Do not change deployment targets, signing, entitlements, capabilities or bundle identifiers without explaining why and obtaining approval.

## Workflow
- Inspect relevant code, project settings and `git status` before editing. Preserve existing architecture, working behaviour and uncommitted changes.
- Make focused, maintainable changes. Avoid unnecessary rewrites, dependencies and unrelated refactoring.
- Build the actual watchOS target after significant changes; run relevant tests and fix introduced errors.
- Never claim builds or tests succeeded unless verified. State any limitations and required manual testing, especially for Siri, App Intents and device-specific behaviour.
- Never commit, push, merge, publish or discard changes without explicit permission.

## Communication
- Explain significant changes, affected files and important compatibility decisions.
- Give beginner-friendly instructions for Xcode and Apple Watch testing.
- Report actual build/test results and anything still unverified.
- Ask questions only when essential; otherwise make reasonable assumptions and state them briefly.

## Definition of Done
Changes must preserve existing functionality, comply with the actual watchOS target and deployment version, and be tested as far as the available environment permits.

## Building and running (MobileBuildMCP)
- Use the MobileBuildMCP CLI (formerly XcodeBuildMCP) instead of raw `xcodebuild`; its output is compact. No global install: `npx -y mobilebuildmcp@latest <workflow> <command>`.
- Build (verified): `npx -y mobilebuildmcp@latest simulator build --project-path "TTR Rewatched.xcodeproj" --scheme "TTR Rewatched Watch App" --simulator-id F50D2AB3-3583-4689-A628-4461EC2F9FE9` (an Apple Watch SE 3 44mm, watchOS 27.0 simulator; list others with `simulator list`). Use `simulator build-and-run` to launch it too (build-and-run itself not yet verified).
- For simulator UI driving (tap, swipe, screenshots) keep using T3's device tools / `agent-device`; the CLI's UI automation was flaky in testing. Run `agent-device` from the same working directory the session was opened in, or it fails with `DEVICE_IN_USE`.
- When finished verifying, clean up what you started: close the Device Hub session with `device_close`, then stop the simulator (T3 Device panel stop, or `xcrun simctl shutdown F50D2AB3-3583-4689-A628-4461EC2F9FE9`). Leave it running if the user is still looking at it. Only quit Xcode if you opened it; never quit one the user is using.
