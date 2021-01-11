import Foundation

/// `NSTextCheckingResult` 封装，用于提供 `NSRegularExpression` 匹配结果
///
/// - Tag: RegExGroups
///
/// - 通过 `Sequence` 协议支持 for-in 循环和 `enumerated {}`, `forEach {}`, etc.
/// - 通过 `Collection` 协议支持下标 (`[i]`) 调用
/// - `RegExGroups.asArray()` 可以转换成 `[RegExGroup]` 数组
/// - `RegExGroups.asMap()` 可以转换成 `[(Range<String.Index>, String)]` 键值数组
public class RegExGroups: IteratorProtocol, Sequence, Collection {
    private let match: NSTextCheckingResult
    private let text: String

    private var current: Int = 0
    private var cache: [RegExGroup?]

    public init?(for match: NSTextCheckingResult, in text: String) {
        self.match = match
        self.text = text
        self.cache = [RegExGroup?](repeating: nil, count: match.numberOfRanges)
    }

    // MARK: Sequence

    /// 用于 `IteratorProtocol`，不建议直接调用
    /// - Returns: 集合中下一个 `RegExGroup`
    public func next() -> RegExGroup? {
        guard self.current < self.match.numberOfRanges else {
            return nil
        }

        if let cached = cache[current] {
            self.current += 1
            return cached
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

    // MARK: - 类型转换

    /// 将本集合转换为 `RegExGroup` 数组
    ///
    /// 调用时将遍历 `NSTextCheckingResult` 中所有匹配结果，并使用每次匹配的基本信息生成 `RegExGroup`。
    ///
    /// 遍历结果将被缓存，加速下次单结果取值速度，例如 `RegExGroup.next()` 和 `RegExGroup.subscript(position:)`；但不会影响后续 `RegExGroup.asArray()` 取值速度，因为在 Swift 中，取得上次遍历所有非空结果的代价更大。
    ///
    /// - Returns: `[RegExGroup]` 数组
    public func asArray() -> [RegExGroup] {
        self.cache = (0 ..< self.match.numberOfRanges).map { index in
            let bounds = match.range(at: index)
            let range = Range(bounds, in: text)!
            let substring = String(text[range])
            return RegExGroup(range: range, string: substring)
        }
        return self.cache.compactMap { $0 }
    }

    /// 将本集合转换为 `Range<String.Index>` 和 `String` 键值元组的数组
    ///
    /// 调用时将遍历 `NSTextCheckingResult` 中所有匹配结果，并使用每次匹配在原始字符串中的位置和捕获的字符生成键值。
    ///
    /// 与字典 (`Dictionary`) 不同，键值元组不会去重、且有序，因为 RegEx 匹配中顺序、重复出现的位置和空字符在不同场景下都有各自的意义。由于 Swift 不支持 splatting（将集合作为参数调用可变参数函数），而 `KeyValuePairs` 没有其他构造函数，因此无法返回 `KeyValuePairs`。详见 https://bugs.swift.org/browse/SR-128
    ///
    /// 调用结果不参与缓存。
    ///
    /// - Returns: `(Range<String.Index>, String)` 键值数组
    public func asMap() -> [(Range<String.Index>, String)] {
        (0 ..< self.match.numberOfRanges).map { index -> (Range<String.Index>, String) in
            let bounds = match.range(at: index)
            let range = Range(bounds, in: text)!
            let substring = String(text[range])
            return (range, substring)
        }
    }
}
