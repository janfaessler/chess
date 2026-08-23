import Foundation

struct VariationManager {
    private static let keyDisambiguator: Character = "\u{1}"
    private var variations: [String: LineModel] = [:]

    func variationName(for move: MoveModel) -> String? {
        for (key, line) in variations {
            if line.all.contains(where: { $0.white?.id == move.id || $0.black?.id == move.id }) {
                return key
            }
        }
        return nil
    }

    func variation(for move: MoveModel) -> LineModel? {
        guard let name = variationName(for: move) else { return nil }
        return variations[name]
    }

    func variation(named name: String) -> LineModel? {
        variations[name] ?? LineModel()
    }

    mutating func add(name: String, line: LineModel) {
        variations[uniqueKey(for: name)] = line
    }

    static func displayName(forKey key: String) -> String {
        String(key.prefix(while: { $0 != keyDisambiguator }))
    }

    private func uniqueKey(for name: String) -> String {
        guard variations[name] != nil else { return name }
        var suffix = 2
        while variations["\(name)\(Self.keyDisambiguator)\(suffix)"] != nil { suffix += 1 }
        return "\(name)\(Self.keyDisambiguator)\(suffix)"
    }

    mutating func appendMove(_ move: MoveModel, toVariationNamed name: String) {
        variations[name]?.last?.black = move
    }

    mutating func appendPair(_ pair: MovePairModel, toVariationNamed name: String) {
        variations[name]?.add(pair)
    }

    var hasVariations: Bool { !variations.isEmpty }

    var keys: [String] { Array(variations.keys) }

    mutating func remove(named name: String) {
        variations.removeValue(forKey: name)
    }
}
