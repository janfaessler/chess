# SwiftChess — Codebase Improvement Plan (Refined)

Assessment date: 2026-08-23  
Refined: 2026-08-23 (after reading all key source files)

---

## What the Initial Assessment Got Wrong

Before the plan: several items the first-pass assessment flagged as god objects were incorrect after reading the actual code.

| Type | Lines | Verdict |
|------|-------|---------|
| `ChessGame` | 87 | Clean. Simple game lifecycle, delegates everything. Not a god object. |
| `ControlModel` | 110 | Clean coordinator. Wires 3 async streams. Not a god object. |
| `MoveValidator` | 72 | Cohesive. One real code smell (dummy Move). Not a god object. |
| `BoardModel` | 185 | Mixed. Annotation management is a genuine extraction target. |
| `PgnMovesParser` | ~200 | Real god object. Handles 5 distinct parse concerns. |

The plan below reflects the actual code, not the assessment summary.

---

## Phase 0 — Critical Safety Fixes

> These are crashes and silent data corruption. Do these first, in any order.

### 0.1 Replace `try!` in FenParser
- **File**: `SwiftChessCore/Sources/SwiftChessCore/ChessUtil/FEN/FenParser.swift`
- **Problem**: `parse(trusted:)` uses `try!`. Any malformed FEN string crashes the process.
- **Fix**: Change `try!` to `try`. The `trusted:` variant should either be removed or restricted to a file-private constant used only for `PositionFactory.startingPositionFen`. All external call sites must handle `FenError`.
- **Scope**: FenParser.swift + all callers of `parse(trusted:)`.

### 0.2 Fix Silent Data Loss in Persistence
- **Files**: `SwiftDataGameCollectionRepository.swift`, `PersistenceConversions.swift`
- **Problem**: `save()` catches all errors and logs them; callers believe the save succeeded. `toGameData()` returns `nil` on decode failure; `compactMap` silently drops those games. The user has no idea their data was lost.
- **Fix**:
  - Add `throws` to `GameCollectionRepository.save()` and `load()` in the protocol.
  - Introduce `enum RepositoryError: Error { case encodingFailed(UUID), decodingFailed(UUID), persistenceFailed(Error) }`.
  - Replace the `do { ... } catch { logger.error(...) }` patterns in `SwiftDataGameCollectionRepository` with `throw RepositoryError.encodingFailed(game.id)`.
  - In `NavigationManagerModel`, catch errors from `save()` and `load()` and set a `@State var errorAlert: String?` that triggers a SwiftUI `.alert`.
- **Scope**: Protocol + SwiftDataGameCollectionRepository + NavigationManagerModel.

### 0.3 Fix `nonisolated(unsafe)` in RightClickOverlay
- **File**: `Shared/Game/Board/Views/RightClickOverlay.swift`
- **Problem**: NSEvent monitor stored with `nonisolated(unsafe)` var without synchronization, creating a potential data race under Swift 6 strict concurrency.
- **Fix**: Move the event monitor `var monitor: Any?` and all its lifecycle code into the `NSViewRepresentable.Coordinator` class, which is already isolated to the main thread via AppKit. Remove the `nonisolated(unsafe)` annotation entirely.
- **Scope**: RightClickOverlay.swift only.

### 0.4 Fix Silent Fallback in String+ChessSquare
- **File**: `Shared/Extensions/String+ChessSquare.swift`
- **Problem**: `chessFileIndex` and `chessRowIndex` return `1` for any invalid input. `"x9".chessFileIndex` silently equals `"a1".chessFileIndex`.
- **Fix**: Change both to return `Int?` (nil for invalid). All callers already operate in contexts where they can handle nil. Remove the fallback.
- **Scope**: String+ChessSquare.swift + all call sites (search for `.chessFileIndex` and `.chessRowIndex`).

---

## Phase 1 — Value Objects

> Low risk. High pay-off. These changes make every later refactor easier.

### 1.1 CastlingRights Value Object

**Why**: `Position` has 4 separate `Bool` parameters and 4 separate `Bool` properties. `CastlingRules.retainsRights` takes 5 parameters partly because of these 4 booleans. `FenParser` and `FenBuilder` each parse/emit them separately. All of this collapses into one type.

**Exact changes**:

1. Create `SwiftChessCore/Sources/SwiftChessCore/Chess/CastlingRights.swift`:
   ```
   struct CastlingRights: Equatable, Hashable, Sendable {
       let whiteKingside: Bool
       let whiteQueenside: Bool
       let blackKingside: Bool
       let blackQueenside: Bool

       static let all = CastlingRights(whiteKingside: true, whiteQueenside: true, blackKingside: true, blackQueenside: true)
       static let none = CastlingRights(whiteKingside: false, whiteQueenside: false, blackKingside: false, blackQueenside: false)

       func canCastle(kingside: Bool, color: PieceColor) -> Bool
       func revoking(kingside: Bool, for color: PieceColor) -> CastlingRights
       func revoking(for color: PieceColor) -> CastlingRights  // revoke both sides
   }
   ```

2. **Position.swift**: Replace the 4 `Bool` stored properties with `let castlingRights: CastlingRights`. Update `init` to take `castlingRights: CastlingRights` (removes 3 parameters). Update `getHash()` to `hasher.combine(castlingRights)`.

3. **PositionFactory.swift**: Update `create(...)` to build and pass a `CastlingRights`. The `retainsRights` calls become `castlingRights.revoking(...)`.

4. **CastlingRules.swift**: `hasRights(move:position:)` and `rightsState(_:color:rookStartingFile:)` become one call to `position.castlingRights.canCastle(kingside:color:)`. `retainsRights(afterMove:color:rookStartingFile:capturedPiece:oldPosition:)` becomes `retainsRights(afterMove:color:rookStartingFile:capturedPiece:rights:)`.

5. **FenParser.swift**: Parse the castling field into a single `CastlingRights` value.

6. **FenBuilder.swift**: Emit from `position.castlingRights`.

7. **Tests**: Update `FenTests` and any existing castling tests to use the new type.

**Files touched**: CastlingRights.swift (new), Position.swift, PositionFactory.swift, CastlingRules.swift, FenParser.swift, FenBuilder.swift + tests.

---

### 1.2 Square Bounds Validation

**Why**: `Square(row: 0, file: 9)` is silently valid. `MoveValidator.isMoveInBoard` re-checks bounds that the Square should enforce.

**Exact changes**:

1. **Square.swift**: Make `init(row:file:)` failable (`init?(row:file:)` returning `nil` outside 1...8 for both). Note: `Square` is currently used by existing callers via non-failable init. Each call site must be audited.
   - `Piece.createMove(_:_:_:)` — returns `Move` which already has a row/file; these are always valid at call time, so this is fine.
   - `Board.get(atRow:atFile:)` — called with raw ints from loops; wrap in `Square?` or keep the direct int-based access.
   - `MoveValidator.isMoveInBoard` — can be removed once Square validates itself.
2. Make `fileNames` and `rowNames` dictionaries `private`. Only expose `init?(string:)` as the parsing entry point.
3. Add a `Square.isValid(row: Int, file: Int) -> Bool` static helper for places that need to check before constructing.

**Note**: This is a wide change. Do it in one commit, update all call sites. `MoveValidator.isMoveInBoard` can be simplified to a nil-check on `Square(row: move.row, file: move.file)` after this.

**Files touched**: Square.swift, MoveValidator.swift, Board.swift, any code constructing Square with raw integers.

---

### 1.3 Promotion Value Object

**Why**: `Move.promoteTo: PieceType` defaults to `.queen` but any `PieceType` is accepted including `.king` and `.pawn`, which are illegal promotions. The domain should express "one of four legal promotion choices."

**Exact changes**:

1. Create `SwiftChessCore/Sources/SwiftChessCore/Chess/Enums/PromotionPiece.swift`:
   ```
   enum PromotionPiece: CaseIterable, Sendable {
       case queen, rook, bishop, knight
       var pieceType: PieceType { ... }
   }
   ```
2. **Move.swift**: Change `let promoteTo: PieceType` to `let promoteTo: PromotionPiece`. Keep `Move` constructors passing `.queen` as the default, but now the type prevents illegal values.
3. **Position.applyPromotion**: Use `move.promoteTo.pieceType` instead of `move.promoteTo`.
4. **PromotionChooseView.swift**: Already shows only legal pieces; confirm it maps to `PromotionPiece` correctly.
5. **BoardModel.doPromote**: Parameter changes from `PieceType` to `PromotionPiece`.
6. **LanParser.swift**: Parse the 5th character of a LAN move into `PromotionPiece?`.

**Files touched**: PromotionPiece.swift (new), Move.swift, Position.swift, BoardModel.swift, PromotionChooseView.swift, LanParser.swift.

---

### 1.4 BoardConstants

**Why**: `8` (board size), `100` (halfmove limit), `3` (threefold threshold), `1...8` bounds — scattered as magic numbers.

**Exact changes**:

1. Create `SwiftChessCore/Sources/SwiftChessCore/Chess/BoardConstants.swift`:
   ```
   enum BoardConstants {
       static let size = 8
       static let halfmoveClockLimit = 100
       static let threefoldRepetitionCount = 3
   }
   ```
2. Replace all `1...8` in `MoveValidator.isMoveInBoard` with `1...BoardConstants.size`.
3. Replace `100` in `DrawConditionEvaluator` with `BoardConstants.halfmoveClockLimit`.
4. Replace `3` in `DrawConditionEvaluator` with `BoardConstants.threefoldRepetitionCount`.
5. Knight deltas, pawn starting rows, castling file numbers — these belong on their respective types (`Knight`, `Pawn`, `King`, `Rook`) as named constants, not in a global enum.

**Files touched**: BoardConstants.swift (new), MoveValidator.swift, DrawConditionEvaluator.swift.

---

## Phase 2 — Targeted Extractions

> These address real violations found in the actual code, sized correctly.

### 2.1 Extract AnnotationModel from BoardModel

**Why**: `BoardModel` (185 lines) has two distinct responsibilities: chess game execution and user annotation management. The annotation half (`pgnHighlights`, `pgnArrows`, `userHighlights`, `userArrows`, `toggleUserHighlight`, `toggleUserArrow`, `clearUserAnnotations`, `updateAnnotations`, `highlightColorCycle`) can stand alone.

**Exact split**:

New file `Shared/Game/Board/AnnotationModel.swift`:
```
@Observable
class AnnotationModel {
    private static let colorCycle: [AnnotationColor] = [.green, .yellow, .red, .blue]

    private(set) var pgnHighlights: [SquareHighlight] = []
    private(set) var pgnArrows: [BoardArrow] = []
    private(set) var userHighlights: [SquareHighlight] = []
    private(set) var userArrows: [BoardArrow] = []

    var allHighlights: [SquareHighlight] { pgnHighlights + userHighlights }
    var allArrows: [BoardArrow] { pgnArrows + userArrows }

    func updatePgn(highlights: [SquareHighlight], arrows: [BoardArrow])
    func toggleHighlight(square: String)
    func toggleArrow(from: String, to: String, color: AnnotationColor)
    func clearUserAnnotations()
}
```

**BoardModel** then holds `let annotations = AnnotationModel()` and delegates all annotation calls to it. `BoardView` and `ControlModel` call `board.annotations.toggleHighlight(...)` etc.

**Why NOT further split**: The rest of BoardModel (`move`, `doMove`, `doPromote`, `getFigures`, `setFocus`, `clearFocus`, `moveFocusFigureTo`, `playFocusFigureMove`, `updatePosition`, `toggleOrientation`) is cohesive game-board execution. It does not need splitting.

**Files touched**: AnnotationModel.swift (new), BoardModel.swift, BoardView.swift, ControlModel.swift, RightClickOverlay.swift.

---

### 2.2 Fix isFieldInCheck Dummy-Move Pattern in MoveValidator

**Why**: `isFieldInCheck(_ row: Int, _ file: Int)` creates `Move(row, file, piece: $0)` — it constructs a Move object not to represent a move but as a coordinate holder. This abuses Move's contract and is confusing.

**Looking at the actual code**:
```swift
func isFieldInCheck(_ row: Int, _ file: Int) -> Bool {
    return position.figures.contains(where: {
        if $0.color == position.colorToMove { return false }
        return $0.isMovePossible(Move(row, file, piece: $0), position: position)
    })
}
```

The dummy Move is needed because `isMovePossible` on `ChessPiece` takes a `Move`. The fix requires two changes:

1. **Add a convenience method** on `MoveValidator` that does the right thing:
   ```swift
   func isSquareAttackedByOpponent(row: Int, file: Int) -> Bool { ... }
   ```
   This replaces `isFieldInCheck` at all call sites with a clearer name.

2. **Long-term**: `ChessPiece.isMovePossible` taking `Move` when it really only needs a destination coordinate is the deeper issue. This is addressed in Phase 3.

**Files touched**: MoveValidator.swift, CastlingRules.swift (which calls `isFieldInCheck`).

---

### 2.3 PgnMovesParser — Extract Sub-parsers

**Why**: This is the real god object in the codebase. A single `parse()` function handles moves, recursive variations, `{}` comment blocks, `!?` annotation glyphs, `[%csl ...]` highlight commands, and `[%cal ...]` arrow commands.

**Approach**: Do NOT attempt to rewrite from scratch. Extract incrementally:

**Step 1** — Extract `AnnotationParser`:
```swift
struct AnnotationParser {
    static func parse(_ token: String) -> MoveAnnotation?
    static func strip(_ move: String) -> String  // removes ! ? glyphs
}
```
Replace all annotation-parsing inline code in `PgnMovesParser` with calls to this.

**Step 2** — Extract `PgnHighlightArrowParser`:
```swift
struct PgnHighlightArrowParser {
    static func parseHighlights(_ comment: String) -> [SquareHighlight]
    static func parseArrows(_ comment: String) -> [BoardArrow]
}
```
The two near-identical parsing loops for `csl`/`cal` collapse into this type.

**Step 3** — Extract `PgnVariationParser`:
```swift
struct PgnVariationParser {
    static func extractVariations(_ token: String) -> [[String]]  // returns raw variation strings
}
```
The recursive parenthesis-matching logic moves here.

**Step 4** — `PgnMovesParser.parse()` then becomes a coordinator that calls each sub-parser for each token.

**Why this order**: Each step is independently testable and mergeable. Start with `AnnotationParser` (lowest risk, isolated), then `PgnHighlightArrowParser` (isolated, the two methods are nearly identical), then `PgnVariationParser` (the most complex).

**Files touched**: AnnotationParser.swift (new), PgnHighlightArrowParser.swift (new), PgnVariationParser.swift (new), PgnMovesParser.swift.

---

### 2.4 EngineSettings — Remove Singleton

**Why**: `static let shared` prevents testing and creates hidden coupling.

**Exact changes**:
1. Remove `static let shared`.
2. Add a default `init()` that keeps the same defaults.
3. `ChessEngine.init()` takes `settings: EngineSettings = EngineSettings()`.
4. `ControlModel.init` passes a `ChessEngine(settings: EngineSettings())`. In tests, pass a custom `EngineSettings` to control behaviour.

**Files touched**: EngineSettings.swift, ChessEngine.swift, ControlModel.swift.

---

### 2.5 MoveModel — Extract VariationManager

**Why**: `MoveModel` holds both move data (notation, annotation, highlights, arrows, comment) and variation management (nested `[String: [MoveModel]]` dictionary with key disambiguation logic).

**Exact changes**:
1. Create `VariationManager` struct that wraps `variations: [String: [MoveModel]]` and owns the key-disambiguation logic.
2. `MoveModel` holds `var variationManager = VariationManager()`.
3. All variation access goes through `variationManager`.

**Files touched**: VariationManager.swift (new), MoveModel.swift.

---

## Phase 3 — Design Debt

> These address the deeper structural concerns. Higher risk; each needs its own branch.

### 3.1 ChessPiece / Position Design Smell

**The actual situation** (after reading the code):

Both `ChessPiece` and `Position` live in the same Swift module (`SwiftChessCore`). There is no compile-time circular dependency — Swift handles this fine within a module. The concern is a *design* one: pieces know about `Position` for move validation, and `Position` knows about pieces for its state.

The concrete issue: `Piece.isMovePossible(_ move: Move, position: Position)` calls `position.checkNextIntersection(move)` which goes to `Board.checkNextIntersection`. Pieces need exactly one thing from Position: the ability to check if the path is clear/blocked.

**Refined fix** (simpler than the original MoveContext proposal):

Introduce a `BoardQuery` protocol in SwiftChessCore:
```swift
public protocol BoardQuery {
    func checkNextIntersection(_ move: Move) -> (any ChessPiece)?
    func isEmpty(atRow: Int, atFile: Int) -> Bool
    func isNotEmpty(atRow: Int, atFile: Int) -> Bool
}
```
`Board` already implements all three of these. Make `Board` conform to `BoardQuery`.

Change `ChessPiece.isMovePossible(_ move: Move, position: Position)` to `isMovePossible(_ move: Move, board: any BoardQuery)`.

`Position.applying()` passes `self` (which now conforms via Board forwarding, or expose `Board` conformance directly) to `isMovePossible`.

**Trade-off**: This is a meaningful change across every piece subclass and all callers of `isMovePossible`. It should only be done if there is a concrete testability need (e.g., you want to write `Pawn` unit tests without constructing a full `Position`). Otherwise, accept the design smell and leave it for Phase 6.

**Verdict**: Defer to Phase 4 unless you have immediate test-writing needs that are blocked by it.

---

### 3.2 CastlingRules — Testability Without De-statiching

**The problem with "just remove static"**: `Position` is a `struct`. It can't hold a `CastlingRules` reference. All five private static methods in `CastlingRules` are pure functions of their inputs — they are genuinely stateless. Making them instance methods adds no value unless there's a protocol to inject.

**Better fix**: Add a `CastlingRulesProtocol` protocol and make `CastlingRules` conform to it. Anywhere `CastlingRules.canCastle(...)` is called from testable code, accept `any CastlingRulesProtocol` instead of the concrete type. This costs almost nothing and unlocks injection in tests.

```swift
public protocol CastlingRulesProtocol {
    func canCastle(_ move: Move, position: Position) -> Bool
    func isCastlingMove(_ move: Move) -> Bool
    // etc.
}

struct CastlingRules: CastlingRulesProtocol {
    func canCastle(_ move: Move, position: Position) -> Bool { ... }
}
```

`King.isMovePossible` and `MoveValidator.doesMovePutOwnKingInCheck` would need to receive a `CastlingRulesProtocol` somehow. The most practical path: inject into `ChessGame` and thread it through. Leave `Position.applying()` using the concrete static for now (it's pure and not a test seam).

**Files touched**: CastlingRules.swift (add protocol conformance), EnPassantRules.swift (same pattern), PromotionRules.swift (same pattern), King.swift, MoveValidator.swift, ChessGame.swift.

---

### 3.3 Shared Notation Constants

**Why**: `MoveFactory` references notation string constants (`"O-O"`, `"O-O-O"`) that are also in `NotationFactory`, creating implicit coupling.

**Fix**: Create `ChessNotation.swift` in SwiftChessCore:
```swift
enum ChessNotation {
    static let kingsideCastle = "O-O"
    static let queensideCastle = "O-O-O"
    static let capture = "x"
    static let promotion = "="
    static let check = "+"
    static let checkmate = "#"
}
```
Replace all string literals in MoveFactory and NotationFactory with these constants.

**Files touched**: ChessNotation.swift (new), MoveFactory.swift, NotationFactory.swift.

---

## Phase 4 — Data Layer

### 4.1 Eliminate PgnGame / GameData Duplication

**The actual situation** (after reading both files):

`PgnGame` and `GameData` are structurally identical (same 4 fields, same `getTitle()` method). `PgnMove` and `MoveData` are structurally identical (same 6 fields). The reason `GameData` exists at all is:

1. `PgnGame.id` is `let id = UUID()` — re-generated on every parse, not stable across sessions.
2. `PgnGame` / `PgnMove` are not `Codable` — needed for SwiftData persistence.
3. `MoveData` has a custom `Codable` implementation for backwards compatibility with the stored JSON.

**Migration strategy**:

**Option A — Make PgnGame the only type (preferred)**:
1. Add `init(id: UUID = UUID(), ...)` to `PgnGame` so the parser creates a new id, but persistence can restore a stored one.
2. Make `PgnGame` and `PgnMove` `Codable` in SwiftChessCore. `PgnMove` already has the right shape; add `Codable` conformance matching `MoveData`'s existing JSON schema (field names are identical, so this is zero-risk).
3. Remove `GameData` and `MoveData`. Replace all uses with `PgnGame`/`PgnMove`.
4. Update `PersistenceConversions` to encode/decode `PgnGame`/`PgnMove` directly.
5. Migration concern: existing stored JSON uses `MoveData` field names — they are identical to `PgnMove` fields, so no migration is needed.

**Option B — Keep GameData but fix identity (conservative)**:
- Only fix the UUID loss: pass `pgnGame.id` through `GameData.from(pgnGame:)` instead of generating a new one.
- This is one-line fix but leaves the duplication in place.

**Recommendation**: Start with Option B to immediately stop UUID loss. Then do Option A in a dedicated branch when you have time to audit every call site.

**Files for Option A (full migration)**:
- SwiftChessCore: PgnGame.swift, PgnMove.swift (add Codable)
- App: GameData.swift (delete), MoveData.swift (delete), PersistenceConversions.swift, StructureFactory.swift, ControlModel.swift, NavigationManagerModel.swift, GameView.swift, EditGameView.swift, EditGameModel.swift.

---

### 4.2 Repository Error Propagation

**See Phase 0.2** — this is already in the critical fixes. Phase 4 extends it:

After Phase 0.2 introduces `throws`, also:
- Define `RepositoryError` as a typed enum rather than forwarding raw SwiftData errors.
- Add a `load() async throws -> [GameCollection]` variant for async contexts.
- `NavigationManagerModel.init` should call `load()` in a `Task` and handle errors gracefully (show an alert, not crash).

---

### 4.3 Extract PgnImportService

**Why**: `GameCollectionRepository.importGames(from:)` is in the persistence protocol — it has nothing to do with persisting data. It parses a file.

**Fix**:
1. Create `Shared/DataManagment/PgnImportService.swift`:
   ```swift
   struct PgnImportService {
       func importGames(from url: URL) throws -> [PgnGame]
   }
   ```
   Move `SwiftDataGameCollectionRepository.getFileContent(_:)` and the `PgnParser` call into this service.
2. Remove `importGames` from `GameCollectionRepository` protocol and `SwiftDataGameCollectionRepository`.
3. `NavigationManagerModel` calls `PgnImportService().importGames(from: url)` then `repository.save(...)`.

**Files touched**: PgnImportService.swift (new), GameCollectionRepository.swift, SwiftDataGameCollectionRepository.swift, NavigationManagerModel.swift.

---

### 4.4 Remove Codable from Domain Models

**Only relevant if doing Option A in 4.1** (keeping `GameData`/`MoveData` means they must stay `Codable`).

If Option A is chosen: after deleting `GameData` and `MoveData`, `Codable` on `PgnGame`/`PgnMove` lives in SwiftChessCore. Move the JSON encoding concern to an extension in the `Persistence/` folder instead, to keep SwiftChessCore free of serialisation knowledge:

```swift
// In Shared/DataManagment/Persistence/PgnCodable.swift
extension PgnGame: Codable { ... }
extension PgnMove: Codable { ... }
```

---

### 4.5 GameCollection Aggregate Invariants

**File**: `Shared/DataManagment/Structs/GameCollection.swift`

**Fix**: Make `games` `private(set)`. Add `mutating func addGame(_ game: GameData)`, `mutating func removeGame(id: UUID)`, `mutating func updateGame(_ game: GameData)`. This creates a single enforcement point for future invariants.

---

## Phase 5 — Test Quality

### 5.1 Add CastlingRulesTests (Missing, High Value)

Create `Tests/SwiftChessCoreTests/Chess/CastlingRulesTests.swift`.

Minimum test cases:

| Scenario | Expected |
|----------|----------|
| White kingside castling in clean position | succeeds |
| White queenside castling in clean position | succeeds |
| Black kingside / queenside in clean position | succeeds |
| King passes through attacked square | blocked |
| King is in check | blocked |
| Destination square is attacked | blocked |
| King has moved previously | rights lost |
| Kingside rook has moved | rights lost |
| Queenside rook has moved | rights lost |
| Kingside rook captured | rights lost |
| Pieces between king and rook | blocked |
| En passant capture of rook after castling (edge case) | handled |

Use `ChessTestBase` or FEN setup via `FenParser.parse(...)`.

---

### 5.2 Fix ChessTestBase Assertion Model

**File**: `Tests/SwiftChessCoreTests/Chess/ChessTestBase.swift`

**Problem**: Uses `Issue.record(...)` which records a failure but does not stop or fail the test. The inverted guard logic (`guard ... == false else { return }`) makes tests hard to reason about.

**Fix**:
1. Replace `Issue.record("message")` with `#expect(condition, "message")` or `#require(condition, "message")` (the latter stops the test on failure).
2. Remove the inverted guard patterns. Express assertions positively:
   ```swift
   // Old
   guard someCondition == false else { return }
   Issue.record("expected failure")
   
   // New
   #expect(someCondition == false)
   ```
3. Remove the duplicate overloads of `moveAndAssert` and `captureAndAssert`. One overload each.

---

### 5.3 Fix MoveFactoryTests State Coupling

**File**: `Tests/SwiftChessCoreTests/Chess/MoveFactoryTests.swift`

Move `boardCache` initialisation into each test method or a `setUp` equivalent using `@Test` attribute setup. Eliminate shared mutable state between tests. Each test must be independently runnable in any order.

---

### 5.4 Expand FenParser Tests

**File**: `Tests/SwiftChessCoreTests/Chess/FenTests.swift`

Add these cases (all should throw `FenError`, not crash):
- Wrong number of ranks (7 or 9 segments in part 1)
- Invalid piece character in board
- Invalid castling rights string (e.g. `"KKK"`)
- Invalid en passant square (e.g. `"z9"`)
- Non-integer halfmove clock
- Halfmove clock exceeding 100

---

### 5.5 Add PgnParser Robustness Tests

**File**: `Tests/SwiftChessCoreTests/ChessUtil/PgnParserTests.swift`

Add:
- Unterminated variation (unclosed `(`)
- Unterminated comment (unclosed `{`)
- Missing result tag — should parse moves but report unknown result
- Variations nested 3+ levels deep
- Annotation on the last move of a game

---

### 5.6 Rename Non-descriptive Tests

- `FenTests.testExample()` → rename to describe what it verifies
- `FieldTest.testExample()` → rename
- `GameStateTests.testGropsAttack()` → likely `testGrobAttack()` (Grob's Attack opening)
- `NotationTests.testSimpleCastleWithTryingWrongMoves()` → split into `testCastleSucceeds()` + `testIllegalMoveRejectedDuringCastling()`

---

## Phase 6 — Long-Term Architecture

> These are larger structural goals. Plan each as a separate, scoped project.

### 6.1 Hexagonal Architecture for SwiftChessCore

Goal: isolate the chess domain from all I/O (FEN, PGN, LAN).

Structure:
- **Domain**: `ChessGame`, `Position`, `Board`, `Move`, value objects — no import of parsing code
- **Ports**: `MoveNotationPort` (protocol for parsing and serialising moves), `PositionNotationPort`
- **Adapters**: `FenAdapter`, `LanAdapter`, `PgnAdapter` implementing the ports

This requires reorganising SwiftChessCore into sub-directories or sub-targets. Do this as a dedicated package restructure project, not alongside feature work.

### 6.2 PGN Grammar / AST Pipeline

Replace the stateful regex-heavy string walker with:

`PgnTokenizer` → `[PgnToken]` → `PgnParser` → `PgnAst` → `PgnInterpreter` → `PgnGame`

Each stage is independently testable. Errors are caught at the grammar level with precise source locations. This is a complete rewrite of the PGN parsing layer — schedule it separately from Phase 2.3 (which is an incremental improvement, not a rewrite).

### 6.3 Arrow Geometry Extraction

**File**: `Shared/Game/Board/Views/BoardArrowsView.swift`

Extract `ArrowGeometry` struct with `path(from: String, to: String, in boardSize: CGFloat) -> Path`. Pure geometry, no SwiftUI state, independently unit-testable.

### 6.4 Property-Based Testing for Parsers

Add fuzz-style tests to `FenTests`, `PgnParserTests`, and `LanParserTests`:
- Generate random legal FEN strings programmatically and verify round-trip stability.
- Feed random strings to all parsers and assert no crash (result may be nil/error, but never a crash).

---

## Revised Priority Matrix

| Priority | Issue | Primary Files | Risk |
|----------|-------|---------------|------|
| 🔴 P0 | `try!` crash in FenParser | FenParser.swift | Low |
| 🔴 P0 | Silent game loss in persistence | Repository, Conversions | Medium |
| 🔴 P0 | `nonisolated(unsafe)` race | RightClickOverlay.swift | Low |
| 🔴 P0 | Silent fallback in String+ChessSquare | String+ChessSquare.swift | Low |
| 🟠 P1 | CastlingRights value object | Position, CastlingRules, FEN | Medium |
| 🟠 P1 | Square bounds validation | Square.swift | Medium |
| 🟠 P1 | PromotionPiece value object | Move, Pawn, BoardModel | Low |
| 🟠 P1 | BoardConstants | DrawConditionEvaluator, MoveValidator | Low |
| 🟠 P1 | ChessTestBase → #expect | ChessTestBase.swift | Low |
| 🟠 P1 | Add CastlingRulesTests | New file | Low |
| 🟡 P2 | Extract AnnotationModel | BoardModel.swift | Low |
| 🟡 P2 | Fix isFieldInCheck dummy-Move | MoveValidator.swift | Low |
| 🟡 P2 | PgnMovesParser sub-parsers (3 steps) | PgnMovesParser.swift | Medium |
| 🟡 P2 | EngineSettings DI | EngineSettings.swift | Low |
| 🟡 P2 | MoveModel → VariationManager | MoveModel.swift | Medium |
| 🟡 P2 | Fix UUID loss in PgnGame→GameData (Option B) | GameData.swift | Low |
| 🟡 P2 | MoveFactoryTests shared state | MoveFactoryTests.swift | Low |
| 🟢 P3 | ChessNotation constants | MoveFactory, NotationFactory | Low |
| 🟢 P3 | CastlingRulesProtocol for testability | CastlingRules.swift | Low |
| 🟢 P3 | Extract PgnImportService | Repository, NavManager | Low |
| 🟢 P3 | GameCollection aggregate enforcement | GameCollection.swift | Low |
| 🟢 P3 | Expand FenParser + PgnParser tests | Test files | Low |
| 🔵 P4 | Eliminate PgnGame/GameData (Option A) | Many files | High |
| 🔵 P4 | BoardQuery protocol / ChessPiece coupling | ChessPiece, Position | Medium |
| 🔵 P4 | Remove Codable from domain | GameData, MoveData | Medium |
| ⚪ P6 | Hexagonal architecture | SwiftChessCore (restructure) | Very High |
| ⚪ P6 | PGN grammar/AST pipeline | PgnParser chain (rewrite) | High |
| ⚪ P6 | Property-based parser testing | Test files | Medium |

---

## Key Corrections from Initial Assessment

| Item | Initial Assessment | Corrected |
|------|-------------------|-----------|
| `ControlModel` | God object, needs splitting | Clean 110-line coordinator. Do not split. |
| `ChessGame` | God class | Clean 87-line game lifecycle. Do not split. |
| `MoveValidator` | God class | Clean 72-line struct. One code smell only. |
| ChessPiece/Position cycle | "Circular dependency, use MoveContext" | Same-module design smell. Use BoardQuery protocol (simpler). |
| De-static rules types | "Just remove static keywords" | Position is a struct; can't hold references. Use protocol for testability instead. |
| PgnGame/GameData | "Just delete GameData" | PgnGame.id is unstable (re-generated on parse). Fix UUID loss first; full migration is Phase 4. |
