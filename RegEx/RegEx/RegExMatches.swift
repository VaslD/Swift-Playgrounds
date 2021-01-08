import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class RegExMatches: IteratorProtocol, Sequence, Collection {
    private let matches: [NSTextCheckingResult]
    private let text: String

    private var current: Int = 0
    private var cache: [RegExMatch?]

    public init(match regEx: NSRegularExpression,
                with options: NSRegularExpression.MatchingOptions = [],
                for range: Range<String.Index>? = nil,
                in text: String)
    {
        let bounds = range == nil ? NSRange(text.startIndex..., in: text) : NSRange(range!, in: text)
        self.matches = regEx.matches(in: text, options: options, range: bounds)
        self.text = text
        self.cache = [RegExMatch?](repeating: nil, count: self.matches.count)

        #if canImport(UIKit)
        NotificationCenter.default.addObserver(self, selector: #selector(self.cleanup),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: UIApplication.shared)
        #endif
    }

    public init?(for matches: [NSTextCheckingResult], in text: String) {
        guard matches.allSatisfy({ (match) -> Bool in
            match.resultType == .regularExpression
        }) else {
            return nil
        }

        self.matches = matches
        self.text = text
        self.cache = [RegExMatch?](repeating: nil, count: matches.count)

        #if canImport(UIKit)
        NotificationCenter.default.addObserver(self, selector: #selector(self.cleanup),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: UIApplication.shared)
        #endif
    }

    // MARK: Sequence

    public func next() -> RegExMatch? {
        guard self.matches.indices.contains(self.current) else {
            return nil
        }

        let match = self.matches[self.current]
        let next = RegExMatch(for: match, in: text)!
        defer {
            if cache[current] == nil {
                cache[current] = next
            }

            current += 1
        }

        return next
    }

    // MARK: Collection

    public var startIndex: Int {
        0
    }

    public var endIndex: Int {
        self.matches.endIndex
    }

    public func index(after i: Int) -> Int {
        i + 1
    }

    public subscript(position: Int) -> RegExMatch {
        if let cached = cache[position] {
            return cached
        }

        let match = self.matches[position]
        return RegExMatch(for: match, in: self.text)!
    }

    // MARK: Maintenance

    @objc func cleanup() {
        self.cache = [RegExMatch?](repeating: nil, count: self.matches.count)
    }

    // MARK: Casts

    public func asArray() -> [RegExMatch] {
        let compactArray = self.cache.compactMap { $0 }
        if compactArray.count == self.matches.count {
            return compactArray
        }

        self.cache = self.matches.map { match in
            RegExMatch(for: match, in: self.text)
        }
        return self.cache.compactMap { $0 }
    }
}
