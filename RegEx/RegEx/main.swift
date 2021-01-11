import Foundation

var pattern = "((\\w+)[\\s.])+"
var text = "Yes. This dog is very friendly."
/*
 Match: Yes.
   Group 0: Yes.
   Group 1: Yes.
   Group 2: Yes
 Match: This dog is very friendly.
   Group 0: This dog is very friendly.
   Group 1: friendly.
   Group 2: friendly
 */

// Use helper/static methods.
if let result = try? RegEx.captures(pattern, in: text) {
    result.forEach { array in
        print("Match:")
        array.enumerated().forEach { index, string in
            print("   Capture \(index): \(string)")
        }
    }
}

print()
print("Alternatively...")
print()

// Use instance methods and for-in loop.
if let regex = RegEx(pattern: pattern) {
    for match in regex.matches(in: text) {
        print("Match:")
        for capture in match.groups {
            print("   Capture: \(capture.string)")
        }
    }
}

print()
print("Even better...")
print()

// Easy handling of results if you want to deal with only arrays.
if let regex = RegEx(pattern: pattern) {
    regex.matches(in: text).asArray().forEach { match in
        print("Match:")
        match.groups.asMap().forEach { key, value in
            print("   Capture: \(value)")
        }
    }
}

print()

// Only the second match remains.
if let regex = RegEx(pattern: pattern) {
    // WARNING: DEMO ONLY! DO NOT USE THIS CODE!
    // Swift Strings are Unicode (not UTF-8/UTF-16/UTF-32) by design.
    // Unicode works well with CJK and other non-Latin languages by counting each human-readable character per index.
    // UTF-8/UTF-16/UTF-32's indexes are fundamentally different. They sometimes split characters per index.
    // If you need a Range, make a Range properly from the String itself. DO NOT use UTF-8 ranges as a shortcut.
    // It works here doesn't mean it always works.
    for match in regex.matches(in: text, with: [], for: text.utf8.index(text.startIndex, offsetBy: 5) ..< text.endIndex)
    {
        print("Match:")
        for capture in match.groups {
            print("   Capture: \(capture.string)")
        }
    }
}

_ = readLine()
