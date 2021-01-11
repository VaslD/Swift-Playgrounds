import Foundation

/// `NSRegularExpression` 和 `NSTextCheckingResult` 封装。
///
/// - Tag: RegEx
///
/// - `NSRange` 参数调整为 Swift `Range`
/// - 提供 [RegExGroups](x-source-tag://RegExGroups) 和 [RegExMatches](x-source-tag://RegExMatches)
/// 封装的结果，方便使用遍历、映射和取值语法
/// - 提供类型函数，无需实例化快速匹配 RegEx 和指定字符串并获取捕获结果
public class RegEx {
    public typealias EnumerationBlock = (RegExMatch?, NSRegularExpression.MatchingFlags) -> Bool

    /// 被封装的 `NSRegularExpression` 类型
    private let regex: NSRegularExpression

    /// RegEx 表达式
    ///
    /// 表达式创建后不可更改。如有需要请重新实例化 [RegEx](x-source-tag://RegEx)。
    public var pattern: String { self.regex.pattern }

    /// RegEx 全局匹配规则
    ///
    /// 匹配规则创建后不可更改。如有需要请重新实例化 [RegEx](x-source-tag://RegEx)。
    public var options: NSRegularExpression.Options { self.regex.options }

    /// 通过表达式字符串构建 [RegEx](x-source-tag://RegEx) 用于后续匹配
    ///
    /// 要快速、一次性检查某个表达式是否匹配字符串，或需要获取捕获的部分字符，可以调用无需实例化的类型方法。只有当需要重复使用某个表达式匹配多个字符串时，才建议保留一个实例。
    ///
    /// 如果表达式或与规则的组合不合法，构建将失败，返回 `nil`。
    ///
    /// - Parameters:
    ///   - pattern: 表达式
    ///   - options: 全局匹配规则（可选）
    public init?(pattern: String, options: NSRegularExpression.Options = []) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return nil }
        self.regex = regex
    }

    /// 封装 `NSRegularExpression` 实例，用于后续匹配
    ///
    /// 要快速、一次性检查某个表达式是否匹配字符串，或需要获取捕获的部分字符，可以调用无需实例化的类型方法。只有当需要重复使用某个表达式匹配多个字符串时，才建议保留一个实例。
    ///
    /// - Parameter regEx: 被封装的实例
    public init(regEx: NSRegularExpression) {
        self.regex = regEx
    }

    // MARK: - Interface

    /// 检查当前 RegEx 在指定字符串中的匹配
    ///
    /// 无论是否提供附加规则，适用的全局匹配规则都会生效。
    ///
    /// - Parameters:
    ///   - text: 被检查的字符串
    ///   - options: 附加规则（可选）
    /// - Returns: 是否匹配
    public func hasMatch(in text: String,
                         with options: NSRegularExpression.MatchingOptions = []) -> Bool
    {
        let range = NSRange(text.startIndex..., in: text)
        return self.regex.rangeOfFirstMatch(in: text, options: options, range: range).location != NSNotFound
    }

    /// 检查当前 RegEx 在指定字符串中指定位置区间的匹配
    ///
    /// 无论是否提供附加规则，适用的全局匹配规则都会生效。
    ///
    /// - Parameters:
    ///   - text: 被检查的字符串
    ///   - options: 附加规则，如果没有需提供 `[]`
    ///   - range: 检查区间
    /// - Returns: 是否匹配
    public func hasMatch(in text: String,
                         with options: NSRegularExpression.MatchingOptions,
                         for range: Range<String.Index>) -> Bool
    {
        self.regex.rangeOfFirstMatch(in: text, options: options, range: NSRange(range, in: text)).location != NSNotFound
    }

    /// 在指定字符串中匹配 RegEx 并取得捕获结果
    ///
    /// 无论是否提供附加规则，适用的全局匹配规则都会生效。
    ///
    /// **警告：此方法将完整执行一次 RegEx 匹配并返回结果，可能需要长时间执行。**
    ///
    /// - Parameters:
    ///   - text: 被检查的字符串
    ///   - options: 附加规则（可选）
    /// - Returns: `RegExMatches` 封装
    public func matches(in text: String,
                        with options: NSRegularExpression.MatchingOptions = []) -> RegExMatches
    {
        RegExMatches(match: self.regex, with: options, in: text)
    }

    /// 在指定字符串中指定区间匹配 RegEx 并取得捕获结果
    ///
    /// 无论是否提供附加规则，适用的全局匹配规则都会生效。
    ///
    /// **警告：此方法将完整执行一次 RegEx 匹配并返回结果，可能需要长时间执行。**
    ///
    /// - Parameters:
    ///   - text: 被检查的字符串
    ///   - options: 附加规则，如果没有需提供 `[]`
    ///   - range: 检查区间
    /// - Returns: `RegExMatches` 封装
    public func matches(in text: String,
                        with options: NSRegularExpression.MatchingOptions,
                        for range: Range<String.Index>) -> RegExMatches
    {
        RegExMatches(match: self.regex, with: options, for: range, in: text)
    }

    /// 枚举每次 RegEx 匹配并执行回调
    ///
    /// 回调接收封装的 `RegExMatch` 和本次匹配的 `NSRegularExpression.MatchingFlags`，并需要返回 `Bool` 示意是否终止匹配。
    ///
    /// 回调频率和可取得的值取决于匹配进度和附加规则，请参阅
    /// `NSRegularExpression.enumerateMatches(in:options:range:using:)`。
    ///
    /// - Parameters:
    ///   - text: 被检查的字符串
    ///   - options: 附加规则（可选）
    ///   - block: 回调闭包
    public func enumerateMatches(in text: String,
                                 with options: NSRegularExpression.MatchingOptions = [],
                                 using block: EnumerationBlock)
    {
        let range = text.startIndex ..< text.endIndex
        self.enumerateMatches(in: text, with: options, for: range, using: block)
    }

    /// 枚举每次 RegEx 匹配并执行回调
    ///
    /// 回调接收封装的 `RegExMatch` 和本次匹配的 `NSRegularExpression.MatchingFlags`，并需要返回 `Bool` 示意是否终止匹配。
    ///
    /// 回调频率和可取得的值取决于匹配进度和附加规则，请参阅
    /// `NSRegularExpression.enumerateMatches(in:options:range:using:)`。
    ///
    /// - Parameters:
    ///   - text: 被检查的字符串
    ///   - options: 附加规则，如果没有需提供 `[]`
    ///   - range: 检查区间
    ///   - block: 回调闭包
    public func enumerateMatches(in text: String,
                                 with options: NSRegularExpression.MatchingOptions,
                                 for range: Range<String.Index>,
                                 using block: EnumerationBlock)
    {
        let bounds = NSRange(range, in: text)
        self.regex.enumerateMatches(in: text, options: options, range: bounds) { result, flags, shouldStop in
            let match: RegExMatch?
            if let result = result {
                match = RegExMatch(for: result, in: text)
            } else {
                match = nil
            }
            shouldStop.pointee = ObjCBool(block(match, flags))
        }
    }
}

// MARK: - Shortcuts

public extension RegEx {
    /// 检查 RegEx 在指定字符串中的匹配
    ///
    /// - Parameters:
    ///   - pattern: RegEx 表达式
    ///   - regExOptions: RegEx 全局匹配规则
    ///   - matchingOptions: 附加规则
    ///   - text: 被检查的字符串
    /// - Throws: 如果表达式或规则组合不合法，创建 `NSRegularExpression` 时可能抛出异常
    /// - Returns: 是否匹配
    static func hasMatch(_ pattern: String,
                         regExOptions: NSRegularExpression.Options = [],
                         matchingOptions: NSRegularExpression.MatchingOptions = [],
                         in text: String) throws -> Bool
    {
        let regex = try NSRegularExpression(pattern: pattern, options: regExOptions)
        return RegEx.hasMatch(regex, with: matchingOptions, in: text)
    }

    /// 检查 RegEx 在指定字符串中的匹配
    ///
    /// - Parameters:
    ///   - regEx: `NSRegularExpression` 实例
    ///   - matchingOptions: 附加规则
    ///   - text: 被检查的字符串
    /// - Returns: 是否匹配
    static func hasMatch(_ regEx: NSRegularExpression,
                         with matchingOptions: NSRegularExpression.MatchingOptions = [],
                         in text: String) -> Bool
    {
        let range = text.startIndex ..< text.endIndex
        return RegEx.hasMatch(regEx, with: matchingOptions, in: text, for: range)
    }

    /// 检查 RegEx 在指定字符串中指定区间的匹配
    ///
    /// - Parameters:
    ///   - pattern: RegEx 表达式
    ///   - regExOptions: RegEx 全局匹配规则
    ///   - matchingOptions: 附加规则
    ///   - text: 被检查的字符串
    ///   - range: 检查区间
    /// - Throws: 如果表达式或规则组合不合法，创建 `NSRegularExpression` 时可能抛出异常
    /// - Returns: 是否匹配
    static func hasMatch(_ pattern: String,
                         regExOptions: NSRegularExpression.Options = [],
                         matchingOptions: NSRegularExpression.MatchingOptions = [],
                         in text: String,
                         for range: Range<String.Index>) throws -> Bool
    {
        let regex = try NSRegularExpression(pattern: pattern, options: regExOptions)
        return RegEx.hasMatch(regex, in: text, for: range)
    }

    /// 检查 RegEx 在指定字符串中指定区间的匹配
    ///
    /// - Parameters:
    ///   - regEx: `NSRegularExpression` 实例
    ///   - matchingOptions: 附加规则
    ///   - text: 被检查的字符串
    ///   - range: 检查区间
    /// - Returns: 是否匹配
    static func hasMatch(_ regEx: NSRegularExpression,
                         with matchingOptions: NSRegularExpression.MatchingOptions = [],
                         in text: String,
                         for range: Range<String.Index>) -> Bool
    {
        let bounds = NSRange(range, in: text)
        return regEx.rangeOfFirstMatch(in: text, options: matchingOptions, range: bounds).location != NSNotFound
    }

    /// 在指定字符串中匹配 RegEx 并取得捕获结果
    ///
    /// **警告：此方法将完整执行一次 RegEx 匹配并返回结果，可能需要长时间执行。**
    ///
    /// - Parameters:
    ///   - pattern: RegEx 表达式
    ///   - regExOptions: RegEx 全局匹配规则
    ///   - matchingOptions: 附加规则
    ///   - text: 被检查的字符串
    /// - Throws: 如果表达式或规则组合不合法，创建 `NSRegularExpression` 时可能抛出异常
    /// - Returns: 全部匹配和每次匹配捕获的字符串组成的二维数组
    static func captures(_ pattern: String,
                         regExOptions: NSRegularExpression.Options = [],
                         matchingOptions: NSRegularExpression.MatchingOptions = [],
                         in text: String) throws -> [[String]]
    {
        let regex = try NSRegularExpression(pattern: pattern, options: regExOptions)
        return RegEx.captures(regex, with: matchingOptions, in: text)
    }

    /// 在指定字符串中匹配 RegEx 并取得捕获结果
    ///
    /// **警告：此方法将完整执行一次 RegEx 匹配并返回结果，可能需要长时间执行。**
    ///
    /// - Parameters:
    ///   - regEx: `NSRegularExpression` 实例
    ///   - matchingOptions: 附加规则
    ///   - text: 被检查的字符串
    /// - Returns: 全部匹配和每次匹配捕获的字符串组成的二维数组
    static func captures(_ regEx: NSRegularExpression,
                         with matchingOptions: NSRegularExpression.MatchingOptions = [],
                         in text: String) -> [[String]]
    {
        let range = text.startIndex ..< text.endIndex
        return RegEx.captures(regEx, with: matchingOptions, in: text, for: range)
    }

    /// 在指定字符串中指定区间匹配 RegEx 并取得捕获结果
    ///
    /// **警告：此方法将完整执行一次 RegEx 匹配并返回结果，可能需要长时间执行。**
    ///
    /// - Parameters:
    ///   - pattern: RegEx 表达式
    ///   - regExOptions: RegEx 全局匹配规则
    ///   - matchingOptions: 附加规则
    ///   - text: 被检查的字符串
    ///   - range: 检查区间
    /// - Throws: 如果表达式或规则组合不合法，创建 `NSRegularExpression` 时可能抛出异常
    /// - Returns: 全部匹配和每次匹配捕获的字符串组成的二维数组
    static func captures(_ pattern: String,
                         regExOptions: NSRegularExpression.Options = [],
                         matchingOptions: NSRegularExpression.MatchingOptions = [],
                         in text: String,
                         for range: Range<String.Index>) throws -> [[String]]
    {
        let regex = try NSRegularExpression(pattern: pattern, options: regExOptions)
        return RegEx.captures(regex, with: matchingOptions, in: text, for: range)
    }

    /// 在指定字符串中指定区间匹配 RegEx 并取得捕获结果
    ///
    /// **警告：此方法将完整执行一次 RegEx 匹配并返回结果，可能需要长时间执行。**
    ///
    /// - Parameters:
    ///   - regEx: `NSRegularExpression` 实例
    ///   - matchingOptions: 附加规则
    ///   - text: 被检查的字符串
    ///   - range: 检查区间
    /// - Returns: 全部匹配和每次匹配捕获的字符串组成的二维数组
    static func captures(_ regEx: NSRegularExpression,
                         with matchingOptions: NSRegularExpression.MatchingOptions = [],
                         in text: String,
                         for range: Range<String.Index>) -> [[String]]
    {
        let bounds = NSRange(range, in: text)
        let matches = regEx.matches(in: text, options: matchingOptions, range: bounds)
        return matches.map { (match) -> [String] in
            (0 ..< match.numberOfRanges).compactMap { (index) -> String? in
                let bounds = match.range(at: index)
                guard let substringRange = Range(bounds, in: text) else { return nil }
                return String(text[substringRange])
            }
        }
    }
}
