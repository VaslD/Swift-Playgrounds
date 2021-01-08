import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class RegExGroups: IteratorProtocol, Sequence, Collection {
    private let match: NSTextCheckingResult
    private let text: String

    private var current: Int = 0
    private var cache: [RegExGroup?]

    public init?(for match: NSTextCheckingResult, in text: String) {
        self.match = match
        self.text = text
        self.cache = [RegExGroup?](repeating: nil, count: match.numberOfRanges)

        #if canImport(UIKit)
        NotificationCenter.default.addObserver(self, selector: #selector(self.cleanup),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: UIApplication.shared)
        #endif
    }

    // MARK: Sequence

    public func next() -> RegExGroup? {
        guard self.current < self.match.numberOfRanges else {
            return nil
        }

        let bounds = self.match.range(at: self.current)
        let range = Range(bounds, in: text)!
        let substring = String(text[range])

        let next = RegExGroup(range: range, string: substring)
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
        self.match.numberOfRanges
    }

    public func index(after i: Int) -> Int {
        i + 1
    }

    public subscript(position: Int) -> RegExGroup {
        if let cached = cache[position] {
            return cached
        }

        let bounds = self.match.range(at: position)
        let range = Range(bounds, in: text)!
        let substring = String(text[range])
        return RegExGroup(range: range, string: substring)
    }

    // MARK: Maintenance

    @objc func cleanup() {
        self.cache = [RegExGroup?](repeating: nil, count: self.match.numberOfRanges)
    }

    // MARK: Casts

    public func asArray() -> [RegExGroup] {
        let compactArray = self.cache.compactMap { $0 }
        if compactArray.count == self.match.numberOfRanges {
            return compactArray
        }

        self.cache = (0 ..< self.match.numberOfRanges).map { index in
            let bounds = match.range(at: index)
            let range = Range(bounds, in: text)!
            let substring = String(text[range])
            return RegExGroup(range: range, string: substring)
        }
        return self.cache.compactMap { $0 }
    }

    public func asMap() -> [(Range<String.Index>, String)] {
        (0 ..< self.match.numberOfRanges).map { index -> (Range<String.Index>, String) in
            let bounds = match.range(at: index)
            let range = Range(bounds, in: text)!
            let substring = String(text[range])
            return (range, substring)
        }
    }
}
