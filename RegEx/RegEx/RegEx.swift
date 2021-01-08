import Foundation

public class RegEx {
    private let regex: NSRegularExpression

    public var pattern: String { self.regex.pattern }

    public var options: NSRegularExpression.Options { self.regex.options }

    public init?(pattern: String, options: NSRegularExpression.Options = []) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return nil }
        self.regex = regex
    }

    public init(regEx: NSRegularExpression) {
        self.regex = regEx
    }

    // MARK: - Interface

    public func hasMatch(in text: String,
                         with options: NSRegularExpression.MatchingOptions = []) -> Bool
    {
        let range = NSRange(text.startIndex..., in: text)
        return self.regex.rangeOfFirstMatch(in: text, options: options, range: range).location != NSNotFound
    }

    public func hasMatch(in text: String,
                         with options: NSRegularExpression.MatchingOptions,
                         for range: Range<String.Index>) -> Bool
    {
        self.regex.rangeOfFirstMatch(in: text, options: options, range: NSRange(range, in: text)).location != NSNotFound
    }
    
    public func matches(in text: String,
                        with options: NSRegularExpression.MatchingOptions = []) -> RegExMatches
    {
        RegExMatches(match: self.regex, with: options, in: text)
    }

    public func matches(in text: String,
                        with options: NSRegularExpression.MatchingOptions,
                        for range: Range<String.Index>) -> RegExMatches
    {
        RegExMatches(match: self.regex, with: options, for: range, in: text)
    }
}

// MARK: - Shortcuts

public extension RegEx {
    static func hasMatch(_ pattern: String, in text: String) throws -> Bool {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        return RegEx.hasMatch(regex, in: text)
    }

    static func hasMatch(_ regEx: NSRegularExpression, in text: String) -> Bool {
        guard !text.isEmpty else { return false }
        let range = NSRange(text.startIndex..., in: text)
        return regEx.firstMatch(in: text, options: [], range: range) != nil
    }

    static func captures(_ pattern: String, in text: String) throws -> [[String]] {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        return RegEx.captures(regex, in: text)
    }

    static func captures(_ regEx: NSRegularExpression, in text: String) -> [[String]] {
        guard !text.isEmpty else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        let matches = regEx.matches(in: text, options: [], range: range)
        return matches.map { (match) -> [String] in
            (0 ..< match.numberOfRanges).compactMap { (index) -> String? in
                let bounds = match.range(at: index)
                guard let substringRange = Range(bounds, in: text) else { return nil }
                return String(text[substringRange])
            }
        }
    }
}
