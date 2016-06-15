// 'Swifty' API wrapper for ObjC diff_match_patch module

import diff_match_patch

func computeDiff(a: String?, b: String?, checklines: Bool = true) -> [Diff] {
    let dmp = DiffMatchPatch()
    if let diffs = dmp.diff_main(ofOldString: a, andNewString: b, checkLines: checklines) {
        return NSArray(array: diffs) as! [Diff]
    } else {
        return [Diff]()
    }
}
