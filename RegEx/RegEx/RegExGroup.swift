public struct RegExGroup {
    // Not yet implemented in Apple SDK.
    // Although a bug report has been filed. See: https://openradar.appspot.com/36612942
    @available(*, unavailable)
    public var name: String?

    public let range: Range<String.Index>
    public let string: String

    public init(range: Range<String.Index>, string: String) {
        self.range = range
        self.string = string
    }
}
