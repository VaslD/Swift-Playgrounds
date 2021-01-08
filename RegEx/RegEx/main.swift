import Foundation

var pattern = "((\\w+)[\\s.])+"
var text = "Yes. This dog is very friendly."
// Match: Yes.
//    Group 0: Yes.
//    Group 1: Yes.
//    Group 2: Yes
// Match: This dog is very friendly.
//    Group 0: This dog is very friendly.
//    Group 1: friendly.
//    Group 2: friendly

// Use helper/static methods.
if let result = try? RegEx.captures(pattern, in: text) {
    result.forEach { (array) in
        print("Match:")
        array.enumerated().forEach { (index, string) in
            print("   Capture \(index): \(string)")
        }
    }
}

print()
print("Alternatively...")
print()

// Use instance methods.
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

// Easy handling of results.
if let regex = RegEx(pattern: pattern) {
    regex.matches(in: text).asArray().forEach { (match) in
        print("Match:")
        match.groups.asMap().forEach { (key, value) in
            print("   Capture: \(value)")
        }
    }

}

_ = readLine()
