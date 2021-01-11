import Foundation

/// `NSRegularExpression` 和 `NSTextCheckingResult` 封装，用于提供 `NSRegularExpression` 匹配结果
///
/// - Tag: RegExMatches
///
/// - 通过 `Sequence` 协议支持 for-in 循环和 `enumerated {}`, `forEach {}`, etc.
/// - 通过 `Collection` 协议支持下标 (`[i]`) 调用
/// - `RegExMatches.asArray()` 可以转换成 `[RegExMatch]` 数组
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
    }

    // MARK: Sequence

    /// 用于 `IteratorProtocol`，不建议直接调用
    /// - Returns: 集合中下一个 `RegExMatch`
    public func next() -> RegExMatch? {
        guard self.matches.indices.contains(self.current) else {
            return nil
        }

        if let cached = cache[current] {
            self.current += 1
            return cached
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

    // MARK: - 类型转换

    /// 将本集合转换为 `RegExMatch` 数组
    ///
    /// 调用时将遍历 `[NSTextCheckingResult]` 中所有匹配结果，并使用每次匹配的基本信息生成 `[RegExMatch]`。
    ///
    /// 遍历结果将被缓存，加速下次单结果取值速度，例如 `RegExMatches.next()` 和 `RegExMatches.subscript(position:)`；但不会影响后续 `RegExMatches.asArray()` 取值速度，因为在 Swift 中，取得上次遍历所有非空结果的代价更大。
    ///
    /// - Returns: `[RegExMatch]` 数组
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
