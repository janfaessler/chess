# SwiftChess Improvement Plan

## Test Quality & UI Polish

Do opportunistically when touching related files. No structural dependencies.

### 1 — Consolidate duplicated test scenarios
**Files:** `NotationTests.swift`, `RawMovesTests.swift`, `CastlingRulesTests.swift`, `EnPassantRulesTests.swift`

En passant, short castle, and long castle sequences are set up nearly identically in multiple test files. When a rule change requires updating one of these sequences, the same game sequence must be updated in every file that copies it — currently up to four places for castling.

Extract common game sequences into a `GameSequences` fixture in `ChessTestBase`. Each test file calls the fixture and asserts its own concern: notation output, raw move list, or rule state. Only do this if a change would currently require updating the same sequence in three or more places — otherwise the duplication is harmless.

### 2 — Fix shared test state
**Files:** `MoveListTests.swift:7`, `MoveHistoryTests.swift:7`, `MoveStructureTests.swift:6`

All three declare `let testee = MoveListModel()` at struct level. Swift Testing runs `@Test` functions in parallel by default. A struct-level instance is shared between parallel runs: if test A appends moves and test B checks for an empty list, they observe each other's mutations.

Instantiate `testee` inside each `@Test` function so every test starts with a fresh, independent model.

### 3 — Add missing edge case tests

- **Castling rights after rook capture**: If an opponent captures the rook on h1, white should lose kingside castling rights. This rule interaction (capture removes rights, not just rook movement) is easy to miss and currently untested.
- **GameData round-trip**: The existing `testToGameData_validData_roundTrips` test in `PersistenceConversionsTests.swift` is minimal. Expand it to verify that games with variations, annotations, and highlights survive a `GameData → GameEntity → GameData` round-trip without data loss.

Note: En passant-with-promotion and insufficient material are already covered by `NotationTests.swift:31–42` / `RawMovesTests.swift:73–84` and `DrawConditionEvaluatorTests.swift` — do not duplicate them.

### 4 — Break up tests longer than 30 lines
**Files:** `RawMovesTests.swift:199–218`, `MoveStructureTests.swift:160–223`, `PgnParserTests.swift:6–90`

Each `@Test` should set up state, perform one action, and assert one outcome. Extract multi-move game sequences into named local helpers or `ChessTestBase` replay utilities.

### 5 — Extract duplicated view components

- **`PromotionChooseView.swift:21–40`**: Four identical promotion piece buttons differ only in their `PromotionPiece` value. Use `ForEach(PromotionPiece.allCases)` with a `PromotionPieceButton` component.
- **`BoardNavigationView.swift:8–69`**: Five nearly identical navigation button patterns. Extract a `NavigationButton` view accepting a label, icon, and action.
- Note: `ChessEngine.swift` lines 47–54 load two *different* eval files — these are intentionally separate and should NOT be merged.

### 6 — Cache legalMoves in BoardModel
**File:** `BoardView.swift:29`

`model.getLegalMoves()` calls `game.getPossibleMoves(forPiece:)` on every SwiftUI body evaluation inside a `ForEach`. The legal move list only changes when `focus` changes, so it is recomputed hundreds of times between the two events that actually matter.

Cache the result in `BoardModel` as a stored value cleared in `focus`'s `didSet`. With the `@Observable` macro, downstream views automatically re-render when the cached value is replaced.

### 7 — Fix SettingsView Binding creation
**File:** `SettingsView.swift:14, 21, 28, 35`

Four properties use manual `Binding(get:set:)` closures, creating new `Binding` value types on every render pass. With `@Observable`, the `@Bindable` wrapper provides `$settings.coreCount` etc. as stable projected values that do not allocate on render.

### 8 — Consider Canvas for board background
**File:** `BoardBackgroundView.swift:12–42`

The 8×8 nested `ForEach` produces 64 `ZStack` view nodes with identity tracking. A `Canvas` with a single `draw` closure replaces 64 view nodes with one drawing command and zero diffing overhead.

Verify with Instruments that this view is actually a render bottleneck before refactoring.

### 9 — Add file size guard in PgnFilesRepository
**File:** `PgnFilesRepository.swift:22–31`

`String(contentsOfFile:)` has no size limit. Loading a multi-gigabyte PGN file allocates the full file contents as a Swift `String` before any parsing begins, which exhausts memory and crashes the app.

Add a guard using `FileManager.default.attributesOfItem(atPath:)`. Define a reasonable maximum (e.g. 50 MB) and surface a user-facing error for files that exceed it.

### 10 — Fix VariationView stale @State
**File:** `VariationView.swift:8–9`

SwiftUI preserves `@State` values based on view identity, not on the value of bound data. When the parent passes a different `MoveModel` to the same `VariationView` instance, `collapsed` retains the expansion state of the previous variation.

Add `.onChange(of: move.id) { collapsed = []; pendingDeleteVariation = nil }` to reset local state whenever the bound move changes.
