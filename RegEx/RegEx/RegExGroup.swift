/// 代表一个 [RegEx Capturing Group](https://www.regular-expressions.info/brackets.html)
public struct RegExGroup {
    // Not yet implemented in Apple SDK.
    // Although a bug report has been filed. See: https://openradar.appspot.com/36612942
    @available(*, unavailable)
    public var name: String?
    
    /// 捕获的子串在原始字符串中的范围
    public let range: Range<String.Index>
    
    /// 捕获的子串
    public let string: String
    
    /// 构造方法，请勿直接使用
    init(range: Range<String.Index>, string: String) {
        self.range = range
        self.string = string
    }
}
