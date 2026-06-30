MASTER INSTRUCTION TO PREPEND TO EVERY CODEX TASK

We are building DreamJotter, a screenplay/movie-script app.

Primary product direction:

* Desktop and mobile.
* Priority platforms: macOS first, then iPadOS/iOS.
* Later platforms: Linux, Windows, Android.
* Apple-native first, but portable core always.
* The first UI should feel excellent on Mac/iPad/iPhone.
* The core domain, screenplay engine, storage format, command system, routines, export system, and AI abstractions must remain platform-neutral.

Best final technical recommendation:

* Swift + SwiftUI for Apple app UI.
* TextKit/AppKit/UIKit wrappers later for the serious screenplay editor.
* Core logic in Swift Package modules.
* Canonical project storage is a local-first `.dreamjotter` document package.
* SwiftData may be used later only for app metadata/cache/search indexing, never as the canonical project format.
* Do not start with Flutter, Electron, Tauri, Kotlin Multiplatform, or a web editor.
* Do not build arbitrary plugins early. Build commands first, routines second, plugin API later.

Repository starting state:

* Clean git repository.
* Only a minimal one-line README.md exists.
* Nothing else exists yet.

Development style:

* This is Spec Driven Development.
* Specs are the source of truth.
* Before implementation, create clear product specs, architecture specs, acceptance criteria, data contracts, behavioral examples, and traceability.
* Favor Given/When/Then examples where useful.
* Specs should be concrete enough that tests and implementation can be generated from them later.
* Do not implement production app features unless explicitly requested by the current prompt.
* Creating lightweight validation scripts, schema examples, test placeholders, or documentation checks is allowed when useful.

Spec quality rules:

* Specs must be written for both product and engineering readers.
* Avoid vague words like “easy”, “fast”, or “smart” unless accompanied by observable behavior.
* Every feature spec should include:

  * user goal
  * scope
  * non-goals
  * user-facing behavior
  * acceptance criteria
  * edge cases
  * data model implications
  * testability notes
  * platform implications
  * future cross-platform implications
* Every milestone should have a traceability matrix.
* Every major architecture decision should have an ADR.
* Keep beginner workflows separate from pro features.
* Core specs must explicitly forbid UI-framework coupling.

Preferred repo structure:

* docs/

  * vision/
  * architecture/
  * adr/
  * specs/
  * milestones/
  * acceptance/
  * data-contracts/
  * routines/
  * plugins/
  * ai/
  * export/
  * storage/
  * editor/
  * ux/
* specs/

  * executable/
  * fixtures/
* scripts/
* README.md
* CONTRIBUTING.md
* TODO.md

Do not create an Xcode project yet unless a later prompt explicitly asks for one.
Do not create real app UI yet.
Do not create a plugin runtime yet.
Do not call external services.

