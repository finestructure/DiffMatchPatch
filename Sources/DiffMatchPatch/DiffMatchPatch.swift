// 'Swifty' API wrapper for ObjC diff_match_patch module

import diff_match_patch

func computeDiff(a: String?, b: String?, checklines: Bool = true) -> [Diff] {
    let dmp = DiffMatchPatch()
    if let a = a, let b = b {
        return dmp.diff_main(ofOldString: a, andNewString: b, checkLines: checklines)
    } else {
        return [Diff]()
    }
}
