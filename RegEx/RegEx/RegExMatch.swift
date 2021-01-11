import Foundation

public struct RegExMatch {
    // Not yet implemented in Apple SDK.
    // Although a bug report has been filed. See: https://openradar.appspot.com/36612942
    @available(*, unavailable)
    public var name: String?

    public let range: Range<String.Index>
    public let string: String
    public let groups: RegExGroups

    public init(range: Range<String.Index>, string: String, groups: RegExGroups) {
        self.range = range
        self.string = string
        self.groups = groups
    }

    public init?(for match: NSTextCheckingResult, in text: String) {
        guard match.resultType == .regularExpression else {
            return nil
        }

        self.groups = RegExGroups(for: match, in: text)!
        self.range = Range(match.range, in: text)!
        self.string = String(text[self.range])
    }
}
