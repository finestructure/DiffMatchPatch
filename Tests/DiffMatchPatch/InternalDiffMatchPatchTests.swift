// This file was originally called 'DiffMatchPathTest.m' when it was part of
// the Objective-C version of diffmatchpatch. The tests have been translated to
// Swift so they can be run with SPM.

import XCTest
@testable import diff_match_patch


class InternalDiffMatchPatchTests: XCTestCase {

    func test_diff_commonPrefixTest() {
        let dmp = DiffMatchPatch()

        // Detect any common suffix.
        // Null case.
        XCTAssertEqual(0, dmp.diff_commonPrefix(ofFirstString: "abc", andSecondString: "xyz"), "Common suffix null case failed.")

        // Non-null case.
        XCTAssertEqual(4, dmp.diff_commonPrefix(ofFirstString: "1234abcdef", andSecondString: "1234xyz"), "Common suffix non-null case failed.")

        // Whole case.
        XCTAssertEqual(4, dmp.diff_commonPrefix(ofFirstString: "1234", andSecondString: "1234xyz"), "Common suffix whole case failed.")
    }


    func test_diff_commonSuffixTest() {
        let dmp = DiffMatchPatch()

        // Detect any common suffix.
        // Null case.
        XCTAssertEqual(0, dmp.diff_commonSuffix(ofFirstString: "abc", andSecondString:"xyz"), "Detect any common suffix. Null case.")

        // Non-null case.
        XCTAssertEqual(4, dmp.diff_commonSuffix(ofFirstString: "abcdef1234", andSecondString:"xyz1234"), "Detect any common suffix. Non-null case.")

        // Whole case.
        XCTAssertEqual(4, dmp.diff_commonSuffix(ofFirstString: "1234", andSecondString:"xyz1234"), "Detect any common suffix. Whole case.")
    }
    

    func test_diff_commonOverlap() {
        let dmp = DiffMatchPatch()

        // Detect any suffix/prefix overlap.
        // Null case.
        XCTAssertEqual(0, dmp.diff_commonOverlap(ofFirstString: "", andSecondString:"abcd"), "Detect any suffix/prefix overlap. Null case.")

        // Whole case.
        XCTAssertEqual(3, dmp.diff_commonOverlap(ofFirstString: "abc", andSecondString:"abcd"), "Detect any suffix/prefix overlap. Whole case.")

        // No overlap.
        XCTAssertEqual(0, dmp.diff_commonOverlap(ofFirstString: "123456", andSecondString:"abcd"), "Detect any suffix/prefix overlap. No overlap.")

        // Overlap.
        XCTAssertEqual(3, dmp.diff_commonOverlap(ofFirstString: "123456xxx", andSecondString:"xxxabcd"), "Detect any suffix/prefix overlap. Overlap.")

        // Unicode.
        // Some overly clever languages (C#) may treat ligatures as equal to their
        // component letters.  E.g. U+FB01 == 'fi'
        XCTAssertEqual(0, dmp.diff_commonOverlap(ofFirstString: "fi", andSecondString:"\u{0000fb01}i"), "Detect any suffix/prefix overlap. Unicode.")
    }


    func test_diff_halfmatch() {
        let dmp = DiffMatchPatch()
        dmp.diff_Timeout = 1
        var expectedResult = [String]()

        // No match.
        XCTAssertNil(dmp.diff_halfMatch(ofFirstString: "1234567890", andSecondString:"abcdef"), "No match #1.")

        XCTAssertNil(dmp.diff_halfMatch(ofFirstString: "12345", andSecondString:"23"), "No match #2.")

        // Single Match.
        expectedResult = ["12", "90", "a", "z", "345678"]
        XCTAssertEqual(expectedResult, dmp.diff_halfMatch(ofFirstString: "1234567890", andSecondString:"a345678z") as! [String], "Single Match #1.")

        expectedResult = ["a", "z", "12", "90", "345678"]
        XCTAssertEqual(expectedResult, dmp.diff_halfMatch(ofFirstString: "a345678z", andSecondString:"1234567890") as! [String], "Single Match #2.")

        expectedResult = ["abc", "z", "1234", "0", "56789"]
        XCTAssertEqual(expectedResult, dmp.diff_halfMatch(ofFirstString: "abc56789z", andSecondString:"1234567890") as! [String], "Single Match #3.")

        expectedResult = ["a", "xyz", "1", "7890", "23456"]
        XCTAssertEqual(expectedResult, dmp.diff_halfMatch(ofFirstString: "a23456xyz", andSecondString:"1234567890") as! [String], "Single Match #4.")

        // Multiple Matches.
        expectedResult = ["12123", "123121", "a", "z", "1234123451234"]
        XCTAssertEqual(expectedResult, dmp.diff_halfMatch(ofFirstString: "121231234123451234123121", andSecondString:"a1234123451234z") as! [String], "Multiple Matches #1.")

        expectedResult = ["", "-=-=-=-=-=", "x", "", "x-=-=-=-=-=-=-="]
        XCTAssertEqual(expectedResult, dmp.diff_halfMatch(ofFirstString: "x-=-=-=-=-=-=-=-=-=-=-=-=", andSecondString:"xx-=-=-=-=-=-=-=") as! [String], "Multiple Matches #2.")

        expectedResult = ["-=-=-=-=-=", "", "", "y", "-=-=-=-=-=-=-=y"]
        XCTAssertEqual(expectedResult, dmp.diff_halfMatch(ofFirstString: "-=-=-=-=-=-=-=-=-=-=-=-=y", andSecondString:"-=-=-=-=-=-=-=yy") as! [String], "Multiple Matches #3.")

        // Non-optimal halfmatch.
        // Optimal diff would be -q+x=H-i+e=lloHe+Hu=llo-Hew+y not -qHillo+x=HelloHe-w+Hulloy
        expectedResult = ["qHillo", "w", "x", "Hulloy", "HelloHe"]
        XCTAssertEqual(expectedResult, dmp.diff_halfMatch(ofFirstString: "qHilloHelloHew", andSecondString:"xHelloHeHulloy") as! [String], "Non-optimal halfmatch.")

        // Optimal no halfmatch.
        dmp.diff_Timeout = 0
        XCTAssertNil(dmp.diff_halfMatch(ofFirstString: "qHilloHelloHew", andSecondString:"xHelloHeHulloy"), "Optimal no halfmatch.")
    }

}

// func test_diff_linesToChars() {
//   let dmp = DiffMatchPatch()
//   NSArray *result;
//
//   // Convert lines down to characters.
//   NSMutableArray *tmpVector = [NSMutableArray array];  // Array of NSString objects.
//   [tmpVector addObject:""];
//   [tmpVector addObject:"alpha\n"];
//   [tmpVector addObject:"beta\n"];
//   result = [dmp diff_linesToCharsForFirstString:"alpha\nbeta\nalpha\n", andSecondString:"beta\nalpha\nbeta\n"];
//   XCTAssertEqual("\001\002\001", [result objectAtIndex:0], "Shared lines #1.")
//   XCTAssertEqual("\002\001\002", [result objectAtIndex:1], "Shared lines #2.")
//   XCTAssertEqual(tmpVector, (NSArray *)[result objectAtIndex:2], "Shared lines #3.")
//
//   [tmpVector removeAllObjects];
//   [tmpVector addObject:""];
//   [tmpVector addObject:"alpha\r\n"];
//   [tmpVector addObject:"beta\r\n"];
//   [tmpVector addObject:"\r\n"];
//   result = [dmp diff_linesToCharsForFirstString:"", andSecondString:"alpha\r\nbeta\r\n\r\n\r\n"];
//   XCTAssertEqual("", [result objectAtIndex:0], "Empty string and blank lines #1.")
//   XCTAssertEqual("\001\002\003\003", [result objectAtIndex:1], "Empty string and blank lines #2.")
//   XCTAssertEqual(tmpVector, (NSArray *)[result objectAtIndex:2], "Empty string and blank lines #3.")
//
//   [tmpVector removeAllObjects];
//   [tmpVector addObject:""];
//   [tmpVector addObject:"a"];
//   [tmpVector addObject:"b"];
//   result = [dmp diff_linesToCharsForFirstString:"a", andSecondString:"b"];
//   XCTAssertEqual("\001", [result objectAtIndex:0], "No linebreaks #1.")
//   XCTAssertEqual("\002", [result objectAtIndex:1], "No linebreaks #2.")
//   XCTAssertEqual(tmpVector, (NSArray *)[result objectAtIndex:2], "No linebreaks #3.")
//
//   // More than 256 to reveal any 8-bit limitations.
//   unichar n = 300;
//   [tmpVector removeAllObjects];
//   NSMutableString *lines = [NSMutableString string];
//   NSMutableString *chars = [NSMutableString string];
//   NSString *currentLine;
//   for (unichar x = 1; x < n + 1; x++) {
//     currentLine = [NSString stringWithFormat:"%d\n", (int)x];
//     [tmpVector addObject:currentLine];
//     [lines appendString:currentLine];
//     [chars appendString:[NSString stringWithFormat:"%C", x]];
//   }
//   XCTAssertEqual(n, tmpVector.count, "More than 256 #1.")
//   XCTAssertEqual(n, chars.length, "More than 256 #2.")
//   [tmpVector insertObject:"" atIndex:0];
//   result = [dmp diff_linesToCharsForFirstString:lines andSecondString:""];
//   XCTAssertEqual(chars, [result objectAtIndex:0], "More than 256 #3.")
//   XCTAssertEqual("", [result objectAtIndex:1], "More than 256 #4.")
//   XCTAssertEqual(tmpVector, (NSArray *)[result objectAtIndex:2], "More than 256 #5.")
//
//   [dmp release];
// }
//
// func test_diff_charsToLines() {
//   let dmp = DiffMatchPatch()
//
//   // Convert chars up to lines.
//   NSArray *diffs = [
//       [Diff diffWithOperation:OperationDiffEqual andText:"\001\002\001"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"\002\001\002")]
//   NSMutableArray *tmpVector = [NSMutableArray array]; // Array of NSString objects.
//   [tmpVector addObject:""];
//   [tmpVector addObject:"alpha\n"];
//   [tmpVector addObject:"beta\n"];
//   [dmp diff_chars:diffs toLines:tmpVector];
//   NSArray *expectedResult = [
//       [Diff diffWithOperation:OperationDiffEqual andText:"alpha\nbeta\nalpha\n"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"beta\nalpha\nbeta\n")]
//   XCTAssertEqual(expectedResult, diffs, "Shared lines.")
//
//   // More than 256 to reveal any 8-bit limitations.
//   unichar n = 300;
//   [tmpVector removeAllObjects];
//   NSMutableString *lines = [NSMutableString string];
//   NSMutableString *chars = [NSMutableString string];
//   NSString *currentLine;
//   for (unichar x = 1; x < n + 1; x++) {
//     currentLine = [NSString stringWithFormat:"%d\n", (int)x];
//     [tmpVector addObject:currentLine];
//     [lines appendString:currentLine];
//     [chars appendString:[NSString stringWithFormat:"%C", x]];
//   }
//   XCTAssertEqual(n, tmpVector.count, "More than 256 #1.")
//   XCTAssertEqual(n, chars.length, "More than 256 #2.")
//   [tmpVector insertObject:"" atIndex:0];
//   diffs = [NSArray arrayWithObject:[Diff diffWithOperation:OperationDiffDelete andText:chars]];
//   [dmp diff_chars:diffs toLines:tmpVector];
//   XCTAssertEqual([NSArray arrayWithObject:[Diff diffWithOperation:OperationDiffDelete andText:lines]], diffs, "More than 256 #3.")
//
//   [dmp release];
// }
//
// func test_diff_cleanupMerge() {
//   let dmp = DiffMatchPatch()
//   NSMutableArray *expectedResult = nil;
//
//   // Cleanup a messy diff.
//   // Null case.
//   NSMutableArray *diffs = [NSMutableArray array];
//   [dmp diff_cleanupMerge:diffs];
//   XCTAssertEqual([NSMutableArray array], diffs, "Null case.")
//
//   // No change case.
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"a"), [Diff diffWithOperation:OperationDiffDelete andText:"b"), [Diff diffWithOperation:OperationDiffInsert andText:"c")]
//   [dmp diff_cleanupMerge:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"a"), [Diff diffWithOperation:OperationDiffDelete andText:"b"), [Diff diffWithOperation:OperationDiffInsert andText:"c")]
//   XCTAssertEqual(expectedResult, diffs, "No change case.")
//
//   // Merge equalities.
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"a"), [Diff diffWithOperation:OperationDiffEqual andText:"b"), [Diff diffWithOperation:OperationDiffEqual andText:"c")]
//   [dmp diff_cleanupMerge:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"abc")]
//   XCTAssertEqual(expectedResult, diffs, "Merge equalities.")
//
//   // Merge deletions.
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffDelete andText:"a"), [Diff diffWithOperation:OperationDiffDelete andText:"b"), [Diff diffWithOperation:OperationDiffDelete andText:"c")]
//   [dmp diff_cleanupMerge:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffDelete andText:"abc")]
//   XCTAssertEqual(expectedResult, diffs, "Merge deletions.")
//
//   // Merge insertions.
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffInsert andText:"a"), [Diff diffWithOperation:OperationDiffInsert andText:"b"), [Diff diffWithOperation:OperationDiffInsert andText:"c")]
//   [dmp diff_cleanupMerge:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffInsert andText:"abc")]
//   XCTAssertEqual(expectedResult, diffs, "Merge insertions.")
//
//   // Merge interweave.
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffDelete andText:"a"), [Diff diffWithOperation:OperationDiffInsert andText:"b"), [Diff diffWithOperation:OperationDiffDelete andText:"c"), [Diff diffWithOperation:OperationDiffInsert andText:"d"), [Diff diffWithOperation:OperationDiffEqual andText:"e"), [Diff diffWithOperation:OperationDiffEqual andText:"f")]
//   [dmp diff_cleanupMerge:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffDelete andText:"ac"), [Diff diffWithOperation:OperationDiffInsert andText:"bd"), [Diff diffWithOperation:OperationDiffEqual andText:"ef")]
//   XCTAssertEqual(expectedResult, diffs, "Merge interweave.")
//
//   // Prefix and suffix detection.
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffDelete andText:"a"), [Diff diffWithOperation:OperationDiffInsert andText:"abc"), [Diff diffWithOperation:OperationDiffDelete andText:"dc")]
//   [dmp diff_cleanupMerge:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"a"), [Diff diffWithOperation:OperationDiffDelete andText:"d"), [Diff diffWithOperation:OperationDiffInsert andText:"b"), [Diff diffWithOperation:OperationDiffEqual andText:"c")]
//   XCTAssertEqual(expectedResult, diffs, "Prefix and suffix detection.")
//
//   // Prefix and suffix detection with equalities.
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"x"), [Diff diffWithOperation:OperationDiffDelete andText:"a"), [Diff diffWithOperation:OperationDiffInsert andText:"abc"), [Diff diffWithOperation:OperationDiffDelete andText:"dc"), [Diff diffWithOperation:OperationDiffEqual andText:"y")]
//   [dmp diff_cleanupMerge:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"xa"), [Diff diffWithOperation:OperationDiffDelete andText:"d"), [Diff diffWithOperation:OperationDiffInsert andText:"b"), [Diff diffWithOperation:OperationDiffEqual andText:"cy")]
//   XCTAssertEqual(expectedResult, diffs, "Prefix and suffix detection with equalities.")
//
//   // Slide edit left.
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"a"), [Diff diffWithOperation:OperationDiffInsert andText:"ba"), [Diff diffWithOperation:OperationDiffEqual andText:"c")]
//   [dmp diff_cleanupMerge:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffInsert andText:"ab"), [Diff diffWithOperation:OperationDiffEqual andText:"ac")]
//   XCTAssertEqual(expectedResult, diffs, "Slide edit left.")
//
//   // Slide edit right.
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"c"), [Diff diffWithOperation:OperationDiffInsert andText:"ab"), [Diff diffWithOperation:OperationDiffEqual andText:"a")]
//   [dmp diff_cleanupMerge:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"ca"), [Diff diffWithOperation:OperationDiffInsert andText:"ba")]
//   XCTAssertEqual(expectedResult, diffs, "Slide edit right.")
//
//   // Slide edit left recursive.
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"a"), [Diff diffWithOperation:OperationDiffDelete andText:"b"), [Diff diffWithOperation:OperationDiffEqual andText:"c"), [Diff diffWithOperation:OperationDiffDelete andText:"ac"), [Diff diffWithOperation:OperationDiffEqual andText:"x")]
//   [dmp diff_cleanupMerge:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffDelete andText:"abc"), [Diff diffWithOperation:OperationDiffEqual andText:"acx")]
//   XCTAssertEqual(expectedResult, diffs, "Slide edit left recursive.")
//
//   // Slide edit right recursive.
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"x"), [Diff diffWithOperation:OperationDiffDelete andText:"ca"), [Diff diffWithOperation:OperationDiffEqual andText:"c"), [Diff diffWithOperation:OperationDiffDelete andText:"b"), [Diff diffWithOperation:OperationDiffEqual andText:"a")]
//   [dmp diff_cleanupMerge:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"xca"), [Diff diffWithOperation:OperationDiffDelete andText:"cba")]
//   XCTAssertEqual(expectedResult, diffs, "Slide edit right recursive.")
//
//   [dmp release];
// }
//
// func test_diff_cleanupSemanticLossless() {
//   let dmp = DiffMatchPatch()
//   NSMutableArray *expectedResult = nil;
//
//   // Slide diffs to match logical boundaries.
//   // Null case.
//   NSMutableArray *diffs = [NSMutableArray array];
//   [dmp diff_cleanupSemanticLossless:diffs];
//   XCTAssertEqual([NSMutableArray array], diffs, "Null case.")
//
//   // Blank lines.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"AAA\r\n\r\nBBB"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"\r\nDDD\r\n\r\nBBB"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"\r\nEEE")]
//   [dmp diff_cleanupSemanticLossless:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"AAA\r\n\r\n"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"BBB\r\nDDD\r\n\r\n"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"BBB\r\nEEE")]
//   XCTAssertEqual(expectedResult, diffs, "Blank lines.")
//
//   // Line boundaries.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"AAA\r\nBBB"),
//       [Diff diffWithOperation:OperationDiffInsert andText:" DDD\r\nBBB"),
//       [Diff diffWithOperation:OperationDiffEqual andText:" EEE")]
//   [dmp diff_cleanupSemanticLossless:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"AAA\r\n"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"BBB DDD\r\n"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"BBB EEE")]
//   XCTAssertEqual(expectedResult, diffs, "Line boundaries.")
//
//   // Word boundaries.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"The c"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"ow and the c"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"at.")]
//   [dmp diff_cleanupSemanticLossless:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"The "),
//       [Diff diffWithOperation:OperationDiffInsert andText:"cow and the "),
//       [Diff diffWithOperation:OperationDiffEqual andText:"cat.")]
//   XCTAssertEqual(expectedResult, diffs, "Word boundaries.")
//
//   // Alphanumeric boundaries.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"The-c"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"ow-and-the-c"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"at.")]
//   [dmp diff_cleanupSemanticLossless:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"The-"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"cow-and-the-"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"cat.")]
//   XCTAssertEqual(expectedResult, diffs, "Alphanumeric boundaries.")
//
//   // Hitting the start.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"a"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"a"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"ax")]
//   [dmp diff_cleanupSemanticLossless:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"a"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"aax")]
//   XCTAssertEqual(expectedResult, diffs, "Hitting the start.")
//
//   // Hitting the end.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"xa"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"a"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"a")]
//   [dmp diff_cleanupSemanticLossless:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"xaa"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"a")]
//   XCTAssertEqual(expectedResult, diffs, "Hitting the end.")
//
//   // Alphanumeric boundaries.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"The xxx. The "),
//       [Diff diffWithOperation:OperationDiffInsert andText:"zzz. The "),
//       [Diff diffWithOperation:OperationDiffEqual andText:"yyy.")]
//   [dmp diff_cleanupSemanticLossless:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"The xxx."),
//       [Diff diffWithOperation:OperationDiffInsert andText:" The zzz."),
//       [Diff diffWithOperation:OperationDiffEqual andText:" The yyy.")]
//   XCTAssertEqual(expectedResult, diffs, "Sentence boundaries.")
//
//   [dmp release];
// }
//
// func test_diff_cleanupSemantic() {
//   let dmp = DiffMatchPatch()
//   NSMutableArray *expectedResult = nil;
//
//   // Cleanup semantically trivial equalities.
//   // Null case.
//   NSMutableArray *diffs = [NSMutableArray array];
//   [dmp diff_cleanupSemantic:diffs];
//   XCTAssertEqual([NSMutableArray array], diffs, "Null case.")
//
//   // No elimination #1.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"ab"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"cd"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"12"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"e")]
//   [dmp diff_cleanupSemantic:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"ab"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"cd"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"12"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"e")]
//   XCTAssertEqual(expectedResult, diffs, "No elimination #1.")
//
//   // No elimination #2.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"abc"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"ABC"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"1234"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"wxyz")]
//   [dmp diff_cleanupSemantic:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"abc"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"ABC"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"1234"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"wxyz")]
//   XCTAssertEqual(expectedResult, diffs, "No elimination #2.")
//
//   // Simple elimination.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"a"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"b"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"c")]
//   [dmp diff_cleanupSemantic:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"abc"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"b")]
//   XCTAssertEqual(expectedResult, diffs, "Simple elimination.")
//
//   // Backpass elimination.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"ab"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"cd"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"e"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"f"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"g")]
//   [dmp diff_cleanupSemantic:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"abcdef"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"cdfg")]
//   XCTAssertEqual(expectedResult, diffs, "Backpass elimination.")
//
//   // Multiple eliminations.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffInsert andText:"1"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"A"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"B"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"2"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"_"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"1"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"A"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"B"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"2")]
//   [dmp diff_cleanupSemantic:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"AB_AB"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"1A2_1A2")]
//   XCTAssertEqual(expectedResult, diffs, "Multiple eliminations.")
//
//   // Word boundaries.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"The c"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"ow and the c"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"at.")]
//   [dmp diff_cleanupSemantic:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"The "),
//       [Diff diffWithOperation:OperationDiffDelete andText:"cow and the "),
//       [Diff diffWithOperation:OperationDiffEqual andText:"cat.")]
//   XCTAssertEqual(expectedResult, diffs, "Word boundaries.")
//
//   // No overlap elimination.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"abcxx"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"xxdef")]
//   [dmp diff_cleanupSemantic:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"abcxx"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"xxdef")]
//   XCTAssertEqual(expectedResult, diffs, "No overlap elimination.")
//
//   // Overlap elimination.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"abcxxx"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"xxxdef")]
//   [dmp diff_cleanupSemantic:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"abc"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"xxx"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"def")]
//   XCTAssertEqual(expectedResult, diffs, "Overlap elimination.")
//
//   // Reverse overlap elimination.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"xxxabc"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"defxxx")]
//   [dmp diff_cleanupSemantic:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffInsert andText:"def"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"xxx"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"abc")]
//   XCTAssertEqual(expectedResult, diffs, "Reverse overlap elimination.")
//
//   // Two overlap eliminations.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"abcd1212"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"1212efghi"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"----"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"A3"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"3BC")]
//   [dmp diff_cleanupSemantic:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"abcd"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"1212"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"efghi"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"----"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"A"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"3"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"BC")]
//   XCTAssertEqual(expectedResult, diffs, "Two overlap eliminations.")
//
//   [dmp release];
// }
//
// func test_diff_cleanupEfficiency() {
//   let dmp = DiffMatchPatch()
//   NSMutableArray *expectedResult = nil;
//
//   // Cleanup operationally trivial equalities.
//   dmp.Diff_EditCost = 4;
//   // Null case.
//   NSMutableArray *diffs = [NSMutableArray array];
//   [dmp diff_cleanupEfficiency:diffs];
//   XCTAssertEqual([NSMutableArray array], diffs, "Null case.")
//
//   // No elimination.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"ab"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"12"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"wxyz"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"cd"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"34")]
//   [dmp diff_cleanupEfficiency:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"ab"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"12"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"wxyz"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"cd"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"34")]
//   XCTAssertEqual(expectedResult, diffs, "No elimination.")
//
//   // Four-edit elimination.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"ab"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"12"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"xyz"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"cd"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"34")]
//   [dmp diff_cleanupEfficiency:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"abxyzcd"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"12xyz34")]
//   XCTAssertEqual(expectedResult, diffs, "Four-edit elimination.")
//
//   // Three-edit elimination.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffInsert andText:"12"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"x"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"cd"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"34")]
//   [dmp diff_cleanupEfficiency:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"xcd"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"12x34")]
//   XCTAssertEqual(expectedResult, diffs, "Three-edit elimination.")
//
//   // Backpass elimination.
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"ab"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"12"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"xy"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"34"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"z"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"cd"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"56")]
//   [dmp diff_cleanupEfficiency:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"abxyzcd"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"12xy34z56")]
//   XCTAssertEqual(expectedResult, diffs, "Backpass elimination.")
//
//   // High cost elimination.
//   dmp.Diff_EditCost = 5;
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"ab"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"12"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"wxyz"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"cd"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"34")]
//   [dmp diff_cleanupEfficiency:diffs];
//   expectedResult = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"abwxyzcd"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"12wxyz34")]
//   XCTAssertEqual(expectedResult, diffs, "High cost elimination.")
//   dmp.Diff_EditCost = 4;
//
//   [dmp release];
// }
//
// func test_diff_prettyHtml() {
//   let dmp = DiffMatchPatch()
//
//   // Pretty print.
//   NSMutableArray *diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"a\n"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"<B>b</B>"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"c&d")]
//   NSString *expectedResult = "<span>a&para;<br></span><del style=\"background:#ffe6e6;\">&lt;B&gt;b&lt;/B&gt;</del><ins style=\"background:#e6ffe6;\">c&amp;d</ins>";
//   XCTAssertEqual(expectedResult, [dmp diff_prettyHtml:diffs], "Pretty print.")
//
//   [dmp release];
// }
//
// func test_diff_text() {
//   let dmp = DiffMatchPatch()
//
//   // Compute the source and destination texts.
//   NSMutableArray *diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"jump"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"s"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"ed"),
//       [Diff diffWithOperation:OperationDiffEqual andText:" over "),
//       [Diff diffWithOperation:OperationDiffDelete andText:"the"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"a"),
//       [Diff diffWithOperation:OperationDiffEqual andText:" lazy")]
//   XCTAssertEqual("jumps over the lazy", [dmp diff_text1:diffs], "Compute the source and destination texts #1")
//
//   XCTAssertEqual("jumped over a lazy", [dmp diff_text2:diffs], "Compute the source and destination texts #2")
//
//   [dmp release];
// }
//
// func test_diff_delta() {
//   let dmp = DiffMatchPatch()
//   NSMutableArray *expectedResult = nil;
//   NSError *error = nil;
//
//   // Convert a diff into delta string.
//   NSMutableArray *diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"jump"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"s"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"ed"),
//       [Diff diffWithOperation:OperationDiffEqual andText:" over "),
//       [Diff diffWithOperation:OperationDiffDelete andText:"the"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"a"),
//       [Diff diffWithOperation:OperationDiffEqual andText:" lazy"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"old dog")]
//   NSString *text1 = [dmp diff_text1:diffs];
//   XCTAssertEqual("jumps over the lazy", text1, "Convert a diff into delta string 1.")
//
//   NSString *delta = [dmp diff_toDelta:diffs];
//   XCTAssertEqual("=4\t-1\t+ed\t=6\t-3\t+a\t=5\t+old dog", delta, "Convert a diff into delta string 2.")
//
//   // Convert delta string into a diff.
//   XCTAssertEqual(diffs, [dmp diff_fromDeltaWithText:text1 andDelta:delta error:NULL], "Convert delta string into a diff.")
//
//   // Generates error (19 < 20).
//   diffs = [dmp diff_fromDeltaWithText:[text1 stringByAppendingString:"x"] andDelta:delta error:&error];
//   if (diffs != nil || error == nil) {
//     XCTFail("diff_fromDelta: Too long.")
//   }
//   error = nil;
//
//   // Generates error (19 > 18).
//   diffs = [dmp diff_fromDeltaWithText:[text1 substringFromIndex:1] andDelta:delta error:&error];
//   if (diffs != nil || error == nil) {
//     XCTFail("diff_fromDelta: Too short.")
//   }
//   error = nil;
//
//   // Generates error (%c3%xy invalid Unicode).
//   diffs = [dmp diff_fromDeltaWithText:"", andDelta:"+%c3%xy" error:&error];
//   if (diffs != nil || error == nil) {
//     XCTFail("diff_fromDelta: Invalid character.")
//   }
//   error = nil;
//
//   // Test deltas with special characters.
//   unichar zero = (unichar)0;
//   unichar one = (unichar)1;
//   unichar two = (unichar)2;
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:[NSString stringWithFormat:"\U00000680 %C \t %%", zero]],
//       [Diff diffWithOperation:OperationDiffDelete andText:[NSString stringWithFormat:"\U00000681 %C \n ^", one]],
//       [Diff diffWithOperation:OperationDiffInsert andText:[NSString stringWithFormat:"\U00000682 %C \\ |", two]]]
//   text1 = [dmp diff_text1:diffs];
//   NSString *expectedString = [NSString stringWithFormat:"\U00000680 %C \t %%\U00000681 %C \n ^", zero, one];
//   XCTAssertEqual(expectedString, text1, "Test deltas with special characters.")
//
//   delta = [dmp diff_toDelta:diffs];
//   // Upper case, because to CFURLCreateStringByAddingPercentEscapes() uses upper.
//   XCTAssertEqual("=7\t-7\t+%DA%82 %02 %5C %7C", delta, "diff_toDelta: Unicode 1.")
//
//   XCTAssertEqual(diffs, [dmp diff_fromDeltaWithText:text1 andDelta:delta error:NULL], "diff_fromDelta: Unicode 2.")
//
//   // Verify pool of unchanged characters.
//   diffs = [NSMutableArray arrayWithObject:
//        [Diff diffWithOperation:OperationDiffInsert andText:"A-Z a-z 0-9 - _ . ! ~ * ' ( ) ; / ? : @ & = + $ , # "]];
//   NSString *text2 = [dmp diff_text2:diffs];
//   XCTAssertEqual("A-Z a-z 0-9 - _ . ! ~ * ' ( ) ; / ? : @ & = + $ , # ", text2, "diff_text2: Unchanged characters 1.")
//
//   delta = [dmp diff_toDelta:diffs];
//   XCTAssertEqual("+A-Z a-z 0-9 - _ . ! ~ * ' ( ) ; / ? : @ & = + $ , # ", delta, "diff_toDelta: Unchanged characters 2.")
//
//   // Convert delta string into a diff.
//   expectedResult = [dmp diff_fromDeltaWithText:"", andDelta:delta error:NULL];
//   XCTAssertEqual(diffs, expectedResult, "diff_fromDelta: Unchanged characters. Convert delta string into a diff.")
//
//   [dmp release];
// }
//
// func test_diff_xIndex() {
//   let dmp = DiffMatchPatch()
//
//   // Translate a location in text1 to text2.
//   NSMutableArray *diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"a"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"1234"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"xyz"), nil] /* Diff */;
//   XCTAssertEqual(5, [dmp diff_xIndexIn:diffs location:2], "diff_xIndex: Translation on equality. Translate a location in text1 to text2.")
//
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"a"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"1234"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"xyz"), nil] /* Diff */;
//   XCTAssertEqual(1, [dmp diff_xIndexIn:diffs location:3], "diff_xIndex: Translation on deletion.")
//
//   [dmp release];
// }
//
// func test_diff_levenshtein() {
//   let dmp = DiffMatchPatch()
//
//   NSMutableArray *diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"abc"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"1234"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"xyz"), nil] /* Diff */;
//   XCTAssertEqual(4, [dmp diff_levenshtein:diffs], "diff_levenshtein: Levenshtein with trailing equality.")
//
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"xyz"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"abc"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"1234"), nil] /* Diff */;
//   XCTAssertEqual(4, [dmp diff_levenshtein:diffs], "diff_levenshtein: Levenshtein with leading equality.")
//
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"abc"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"xyz"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"1234"), nil] /* Diff */;
//   XCTAssertEqual(7, [dmp diff_levenshtein:diffs], "diff_levenshtein: Levenshtein with middle equality.")
//
//   [dmp release];
// }
//
// func diff_bisectTest;
// {
//   let dmp = DiffMatchPatch()
//
//   // Normal.
//   NSString *a = "cat";
//   NSString *b = "map";
//   // Since the resulting diff hasn't been normalized, it would be ok if
//   // the insertion and deletion pairs are swapped.
//   // If the order changes, tweak this test as required.
//   NSMutableArray *diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffDelete andText:"c"), [Diff diffWithOperation:OperationDiffInsert andText:"m"), [Diff diffWithOperation:OperationDiffEqual andText:"a"), [Diff diffWithOperation:OperationDiffDelete andText:"t"), [Diff diffWithOperation:OperationDiffInsert andText:"p")]
//   XCTAssertEqual(diffs, [dmp diff_bisectOfOldString:a andNewString:b deadline:[[NSDate distantFuture] timeIntervalSinceReferenceDate]], "Bisect test.")
//
//   // Timeout.
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffDelete andText:"cat"), [Diff diffWithOperation:OperationDiffInsert andText:"map")]
//   XCTAssertEqual(diffs, [dmp diff_bisectOfOldString:a andNewString:b deadline:[[NSDate distantPast] timeIntervalSinceReferenceDate]], "Bisect timeout.")
//
//   [dmp release];
// }
//
// func test_diff_main() {
//   let dmp = DiffMatchPatch()
//
//   // Perform a trivial diff.
//   NSMutableArray *diffs = [NSMutableArray array];
//   XCTAssertEqual(diffs, [dmp diff_mainOfOldString:"", andNewString:"" checkLines:NO], "diff_main: Null case.")
//
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"abc")]
//   XCTAssertEqual(diffs, [dmp diff_mainOfOldString:"abc", andNewString:"abc" checkLines:NO], "diff_main: Equality.")
//
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"ab"), [Diff diffWithOperation:OperationDiffInsert andText:"123"), [Diff diffWithOperation:OperationDiffEqual andText:"c")]
//   XCTAssertEqual(diffs, [dmp diff_mainOfOldString:"abc", andNewString:"ab123c" checkLines:NO], "diff_main: Simple insertion.")
//
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"a"), [Diff diffWithOperation:OperationDiffDelete andText:"123"), [Diff diffWithOperation:OperationDiffEqual andText:"bc")]
//   XCTAssertEqual(diffs, [dmp diff_mainOfOldString:"a123bc", andNewString:"abc" checkLines:NO], "diff_main: Simple deletion.")
//
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"a"), [Diff diffWithOperation:OperationDiffInsert andText:"123"), [Diff diffWithOperation:OperationDiffEqual andText:"b"), [Diff diffWithOperation:OperationDiffInsert andText:"456"), [Diff diffWithOperation:OperationDiffEqual andText:"c")]
//   XCTAssertEqual(diffs, [dmp diff_mainOfOldString:"abc", andNewString:"a123b456c" checkLines:NO], "diff_main: Two insertions.")
//
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffEqual andText:"a"), [Diff diffWithOperation:OperationDiffDelete andText:"123"), [Diff diffWithOperation:OperationDiffEqual andText:"b"), [Diff diffWithOperation:OperationDiffDelete andText:"456"), [Diff diffWithOperation:OperationDiffEqual andText:"c")]
//   XCTAssertEqual(diffs, [dmp diff_mainOfOldString:"a123b456c", andNewString:"abc" checkLines:NO], "diff_main: Two deletions.")
//
//   // Perform a real diff.
//   // Switch off the timeout.
//   dmp.Diff_Timeout = 0;
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffDelete andText:"a"), [Diff diffWithOperation:OperationDiffInsert andText:"b")]
//   XCTAssertEqual(diffs, [dmp diff_mainOfOldString:"a", andNewString:"b" checkLines:NO], "diff_main: Simple case #1.")
//
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffDelete andText:"Apple"), [Diff diffWithOperation:OperationDiffInsert andText:"Banana"), [Diff diffWithOperation:OperationDiffEqual andText:"s are a"), [Diff diffWithOperation:OperationDiffInsert andText:"lso"), [Diff diffWithOperation:OperationDiffEqual andText:" fruit.")]
//   XCTAssertEqual(diffs, [dmp diff_mainOfOldString:"Apples are a fruit.", andNewString:"Bananas are also fruit." checkLines:NO], "diff_main: Simple case #2.")
//
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffDelete andText:"a"), [Diff diffWithOperation:OperationDiffInsert andText:"\U00000680"), [Diff diffWithOperation:OperationDiffEqual andText:"x"), [Diff diffWithOperation:OperationDiffDelete andText:"\t"), [Diff diffWithOperation:OperationDiffInsert andText:[NSString stringWithFormat:"%C", 0]]]
//   NSString *aString = [NSString stringWithFormat:"\U00000680x%C", 0];
//   XCTAssertEqual(diffs, [dmp diff_mainOfOldString:"ax\t", andNewString:aString checkLines:NO], "diff_main: Simple case #3.")
//
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffDelete andText:"1"), [Diff diffWithOperation:OperationDiffEqual andText:"a"), [Diff diffWithOperation:OperationDiffDelete andText:"y"), [Diff diffWithOperation:OperationDiffEqual andText:"b"), [Diff diffWithOperation:OperationDiffDelete andText:"2"), [Diff diffWithOperation:OperationDiffInsert andText:"xab")]
//   XCTAssertEqual(diffs, [dmp diff_mainOfOldString:"1ayb2", andNewString:"abxab" checkLines:NO], "diff_main: Overlap #1.")
//
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffInsert andText:"xaxcx"), [Diff diffWithOperation:OperationDiffEqual andText:"abc"), [Diff diffWithOperation:OperationDiffDelete andText:"y")]
//   XCTAssertEqual(diffs, [dmp diff_mainOfOldString:"abcy", andNewString:"xaxcxabc" checkLines:NO], "diff_main: Overlap #2.")
//
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffDelete andText:"ABCD"), [Diff diffWithOperation:OperationDiffEqual andText:"a"), [Diff diffWithOperation:OperationDiffDelete andText:"="), [Diff diffWithOperation:OperationDiffInsert andText:"-"), [Diff diffWithOperation:OperationDiffEqual andText:"bcd"), [Diff diffWithOperation:OperationDiffDelete andText:"="), [Diff diffWithOperation:OperationDiffInsert andText:"-"), [Diff diffWithOperation:OperationDiffEqual andText:"efghijklmnopqrs"), [Diff diffWithOperation:OperationDiffDelete andText:"EFGHIJKLMNOefg")]
//   XCTAssertEqual(diffs, [dmp diff_mainOfOldString:"ABCDa=bcd=efghijklmnopqrsEFGHIJKLMNOefg", andNewString:"a-bcd-efghijklmnopqrs" checkLines:NO], "diff_main: Overlap #3.")
//
//   diffs = [NSMutableArray arrayWithObjects:[Diff diffWithOperation:OperationDiffInsert andText:" "), [Diff diffWithOperation:OperationDiffEqual andText:"a"), [Diff diffWithOperation:OperationDiffInsert andText:"nd"), [Diff diffWithOperation:OperationDiffEqual andText:" [[Pennsylvania]]"), [Diff diffWithOperation:OperationDiffDelete andText:", and [[New")]
//   XCTAssertEqual(diffs, [dmp diff_mainOfOldString:"a [[Pennsylvania]] and [[New", andNewString:", and [[Pennsylvania]]" checkLines:NO], "diff_main: Large equality.")
//
//   dmp.Diff_Timeout = 0.1f;  // 100ms
//   NSString *a = "`Twas brillig, and the slithy toves\nDid gyre and gimble in the wabe:\nAll mimsy were the borogoves,\nAnd the mome raths outgrabe.\n";
//   NSString *b = "I am the very model of a modern major general,\nI've information vegetable, animal, and mineral,\nI know the kings of England, and I quote the fights historical,\nFrom Marathon to Waterloo, in order categorical.\n";
//   NSMutableString *aMutable = [NSMutableString stringWithString:a];
//   NSMutableString *bMutable = [NSMutableString stringWithString:b];
//   // Increase the text lengths by 1024 times to ensure a timeout.
//   for (int x = 0; x < 10; x++) {
//     [aMutable appendString:aMutable];
//     [bMutable appendString:bMutable];
//   }
//   a = aMutable;
//   b = bMutable;
//   NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
//   [dmp diff_mainOfOldString:a andNewString:b];
//   NSTimeInterval endTime = [NSDate timeIntervalSinceReferenceDate];
//   // Test that we took at least the timeout period.
//   XCTAssertTrue((dmp.Diff_Timeout <= (endTime - startTime)), "Test that we took at least the timeout period.")
//    // Test that we didn't take forever (be forgiving).
//    // Theoretically this test could fail very occasionally if the
//    // OS task swaps or locks up for a second at the wrong moment.
//    // This will fail when running this as PPC code thru Rosetta on Intel.
//   XCTAssertTrue(((dmp.Diff_Timeout * 2) > (endTime - startTime)), "Test that we didn't take forever (be forgiving).")
//   dmp.Diff_Timeout = 0;
//
//   // Test the linemode speedup.
//   // Must be long to pass the 200 character cutoff.
//   a = "1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n";
//   b = "abcdefghij\nabcdefghij\nabcdefghij\nabcdefghij\nabcdefghij\nabcdefghij\nabcdefghij\nabcdefghij\nabcdefghij\nabcdefghij\nabcdefghij\nabcdefghij\nabcdefghij\n";
//   XCTAssertEqual([dmp diff_mainOfOldString:a andNewString:b checkLines:YES], [dmp diff_mainOfOldString:a andNewString:b checkLines:NO], "diff_main: Simple line-mode.")
//
//   a = "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890";
//   b = "abcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghij";
//   XCTAssertEqual([dmp diff_mainOfOldString:a andNewString:b checkLines:YES], [dmp diff_mainOfOldString:a andNewString:b checkLines:NO], "diff_main: Single line-mode.")
//
//   a = "1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n1234567890\n";
//   b = "abcdefghij\n1234567890\n1234567890\n1234567890\nabcdefghij\n1234567890\n1234567890\n1234567890\nabcdefghij\n1234567890\n1234567890\n1234567890\nabcdefghij\n";
//   NSArray *texts_linemode = [self diff_rebuildtexts:[dmp diff_mainOfOldString:a andNewString:b checkLines:YES]];
//   NSArray *texts_textmode = [self diff_rebuildtexts:[dmp diff_mainOfOldString:a andNewString:b checkLines:NO]];
//   XCTAssertEqual(texts_textmode, texts_linemode, "diff_main: Overlap line-mode.")
//
//   // CHANGEME: Test null inputs
//
//   [dmp release];
// }
//
//
// #pragma mark Match Test Functions
// //  MATCH TEST FUNCTIONS
//
//
// func test_match_alphabet() {
//   let dmp = DiffMatchPatch()
//
//   // Initialise the bitmasks for Bitap.
//   NSMutableDictionary *bitmask = [NSMutableDictionary dictionary];
//
//   [bitmask diff_setUnsignedIntegerValue:4 forUnicharKey:'a'];
//   [bitmask diff_setUnsignedIntegerValue:2 forUnicharKey:'b'];
//   [bitmask diff_setUnsignedIntegerValue:1 forUnicharKey:'c'];
//   XCTAssertEqual(bitmask, [dmp match_alphabet:"abc"), "match_alphabet: Unique.")
//
//   [bitmask removeAllObjects];
//   [bitmask diff_setUnsignedIntegerValue:37 forUnicharKey:'a'];
//   [bitmask diff_setUnsignedIntegerValue:18 forUnicharKey:'b'];
//   [bitmask diff_setUnsignedIntegerValue:8 forUnicharKey:'c'];
//   XCTAssertEqual(bitmask, [dmp match_alphabet:"abcaba"), "match_alphabet: Duplicates.")
//
//   [dmp release];
// }
//
// func test_match_bitap() {
//   let dmp = DiffMatchPatch()
//
//   // Bitap algorithm.
//   dmp.Match_Distance = 100;
//   dmp.Match_Threshold = 0.5f;
//   XCTAssertEqual(5, [dmp match_bitapOfText:"abcdefghijk", andPattern:"fgh" near:5], "match_bitap: Exact match #1.")
//
//   XCTAssertEqual(5, [dmp match_bitapOfText:"abcdefghijk", andPattern:"fgh" near:0], "match_bitap: Exact match #2.")
//
//   XCTAssertEqual(4, [dmp match_bitapOfText:"abcdefghijk", andPattern:"efxhi" near:0], "match_bitap: Fuzzy match #1.")
//
//   XCTAssertEqual(2, [dmp match_bitapOfText:"abcdefghijk", andPattern:"cdefxyhijk" near:5], "match_bitap: Fuzzy match #2.")
//
//   XCTAssertEqual(NSNotFound, [dmp match_bitapOfText:"abcdefghijk", andPattern:"bxy" near:1], "match_bitap: Fuzzy match #3.")
//
//   XCTAssertEqual(2, [dmp match_bitapOfText:"123456789xx0", andPattern:"3456789x0" near:2], "match_bitap: Overflow.")
//
//   XCTAssertEqual(0, [dmp match_bitapOfText:"abcdef", andPattern:"xxabc" near:4], "match_bitap: Before start match.")
//
//   XCTAssertEqual(3, [dmp match_bitapOfText:"abcdef", andPattern:"defyy" near:4], "match_bitap: Beyond end match.")
//
//   XCTAssertEqual(0, [dmp match_bitapOfText:"abcdef", andPattern:"xabcdefy" near:0], "match_bitap: Oversized pattern.")
//
//   dmp.Match_Threshold = 0.4f;
//   XCTAssertEqual(4, [dmp match_bitapOfText:"abcdefghijk", andPattern:"efxyhi" near:1], "match_bitap: Threshold #1.")
//
//   dmp.Match_Threshold = 0.3f;
//   XCTAssertEqual(NSNotFound, [dmp match_bitapOfText:"abcdefghijk", andPattern:"efxyhi" near:1], "match_bitap: Threshold #2.")
//
//   dmp.Match_Threshold = 0.0f;
//   XCTAssertEqual(1, [dmp match_bitapOfText:"abcdefghijk", andPattern:"bcdef" near:1], "match_bitap: Threshold #3.")
//
//   dmp.Match_Threshold = 0.5f;
//   XCTAssertEqual(0, [dmp match_bitapOfText:"abcdexyzabcde", andPattern:"abccde" near:3], "match_bitap: Multiple select #1.")
//
//   XCTAssertEqual(8, [dmp match_bitapOfText:"abcdexyzabcde", andPattern:"abccde" near:5], "match_bitap: Multiple select #2.")
//
//   dmp.Match_Distance = 10;  // Strict location.
//   XCTAssertEqual(NSNotFound, [dmp match_bitapOfText:"abcdefghijklmnopqrstuvwxyz", andPattern:"abcdefg" near:24], "match_bitap: Distance test #1.")
//
//   XCTAssertEqual(0, [dmp match_bitapOfText:"abcdefghijklmnopqrstuvwxyz", andPattern:"abcdxxefg" near:1], "match_bitap: Distance test #2.")
//
//   dmp.Match_Distance = 1000;  // Loose location.
//   XCTAssertEqual(0, [dmp match_bitapOfText:"abcdefghijklmnopqrstuvwxyz", andPattern:"abcdefg" near:24], "match_bitap: Distance test #3.")
//
//   [dmp release];
// }
//
// func test_match_main() {
//   let dmp = DiffMatchPatch()
//
//   // Full match.
//   XCTAssertEqual(0, [dmp match_mainForText:"abcdef" pattern:"abcdef" near:1000], "match_main: Equality.")
//
//   XCTAssertEqual(NSNotFound, [dmp match_mainForText:"" pattern:"abcdef" near:1], "match_main: Null text.")
//
//   XCTAssertEqual(3, [dmp match_mainForText:"abcdef" pattern:"" near:3], "match_main: Null pattern.")
//
//   XCTAssertEqual(3, [dmp match_mainForText:"abcdef" pattern:"de" near:3], "match_main: Exact match.")
//
//   XCTAssertEqual(3, [dmp match_mainForText:"abcdef" pattern:"defy" near:4], "match_main: Beyond end match.")
//
//   XCTAssertEqual(0, [dmp match_mainForText:"abcdef" pattern:"abcdefy" near:0], "match_main: Oversized pattern.")
//
//   dmp.Match_Threshold = 0.7f;
//   XCTAssertEqual(4, [dmp match_mainForText:"I am the very model of a modern major general." pattern:" that berry " near:5], "match_main: Complex match.")
//   dmp.Match_Threshold = 0.5f;
//
//   // CHANGEME: Test null inputs
//
//   [dmp release];
// }
//
//
// #pragma mark Patch Test Functions
// //  PATCH TEST FUNCTIONS
//
//
// func test_patch_patchObj() {
//   // Patch Object.
//   Patch *p = [[Patch new] autorelease];
//   p.start1 = 20;
//   p.start2 = 21;
//   p.length1 = 18;
//   p.length2 = 17;
//   p.diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffEqual andText:"jump"),
//       [Diff diffWithOperation:OperationDiffDelete andText:"s"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"ed"),
//       [Diff diffWithOperation:OperationDiffEqual andText:" over "),
//       [Diff diffWithOperation:OperationDiffDelete andText:"the"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"a"),
//       [Diff diffWithOperation:OperationDiffEqual andText:"\nlaz")]
//   NSString *strp = "@@ -21,18 +22,17 @@\n jump\n-s\n+ed\n  over \n-the\n+a\n %0Alaz\n";
//   XCTAssertEqual(strp, [p description], "Patch: description.")
// }
//
// func test_patch_fromText() {
//   let dmp = DiffMatchPatch()
//
//   XCTAssertTrue(((NSMutableArray *)[dmp patch_fromText:"" error:NULL]).count == 0, "patch_fromText: #0.")
//
//   NSString *strp = "@@ -21,18 +22,17 @@\n jump\n-s\n+ed\n  over \n-the\n+a\n %0Alaz\n";
//   XCTAssertEqual(strp, [[[dmp patch_fromText:strp error:NULL] objectAtIndex:0] description], "patch_fromText: #1.")
//
//   XCTAssertEqual("@@ -1 +1 @@\n-a\n+b\n", [[[dmp patch_fromText:"@@ -1 +1 @@\n-a\n+b\n" error:NULL] objectAtIndex:0] description], "patch_fromText: #2.")
//
//   XCTAssertEqual("@@ -1,3 +0,0 @@\n-abc\n", [[[dmp patch_fromText:"@@ -1,3 +0,0 @@\n-abc\n" error:NULL] objectAtIndex:0] description], "patch_fromText: #3.")
//
//   XCTAssertEqual("@@ -0,0 +1,3 @@\n+abc\n", [[[dmp patch_fromText:"@@ -0,0 +1,3 @@\n+abc\n" error:NULL] objectAtIndex:0] description], "patch_fromText: #4.")
//
//   // Generates error.
//   NSError *error = nil;
//   NSMutableArray *patches = [dmp patch_fromText:"Bad\nPatch\n" error:&error];
//   if (patches != nil || error == nil) {
//     // Error expected.
//     XCTFail("patch_fromText: #5.")
//   }
//   error = nil;
//
//   [dmp release];
// }
//
// func test_patch_toText() {
//   let dmp = DiffMatchPatch()
//
//   NSString *strp = "@@ -21,18 +22,17 @@\n jump\n-s\n+ed\n  over \n-the\n+a\n  laz\n";
//   NSMutableArray *patches;
//   patches = [dmp patch_fromText:strp error:NULL];
//   XCTAssertEqual(strp, [dmp patch_toText:patches], "toText Test #1")
//
//   strp = "@@ -1,9 +1,9 @@\n-f\n+F\n oo+fooba\n@@ -7,9 +7,9 @@\n obar\n-,\n+.\n  tes\n";
//   patches = [dmp patch_fromText:strp error:NULL];
//   XCTAssertEqual(strp, [dmp patch_toText:patches], "toText Test #2")
//
//   [dmp release];
// }
//
// func test_patch_addContext() {
//   let dmp = DiffMatchPatch()
//
//   dmp.Patch_Margin = 4;
//   Patch *p;
//   p = [[dmp patch_fromText:"@@ -21,4 +21,10 @@\n-jump\n+somersault\n" error:NULL] objectAtIndex:0];
//   [dmp patch_addContextToPatch:p sourceText:"The quick brown fox jumps over the lazy dog."];
//   XCTAssertEqual("@@ -17,12 +17,18 @@\n fox \n-jump\n+somersault\n s ov\n", [p description], "patch_addContext: Simple case.")
//
//   p = [[dmp patch_fromText:"@@ -21,4 +21,10 @@\n-jump\n+somersault\n" error:NULL] objectAtIndex:0];
//   [dmp patch_addContextToPatch:p sourceText:"The quick brown fox jumps."];
//   XCTAssertEqual("@@ -17,10 +17,16 @@\n fox \n-jump\n+somersault\n s.\n", [p description], "patch_addContext: Not enough trailing context.")
//
//   p = [[dmp patch_fromText:"@@ -3 +3,2 @@\n-e\n+at\n" error:NULL] objectAtIndex:0];
//   [dmp patch_addContextToPatch:p sourceText:"The quick brown fox jumps."];
//   XCTAssertEqual("@@ -1,7 +1,8 @@\n Th\n-e\n+at\n  qui\n", [p description], "patch_addContext: Not enough leading context.")
//
//   p = [[dmp patch_fromText:"@@ -3 +3,2 @@\n-e\n+at\n" error:NULL] objectAtIndex:0];
//   [dmp patch_addContextToPatch:p sourceText:"The quick brown fox jumps.  The quick brown fox crashes."];
//   XCTAssertEqual("@@ -1,27 +1,28 @@\n Th\n-e\n+at\n  quick brown fox jumps. \n", [p description], "patch_addContext: Ambiguity.")
//
//   [dmp release];
// }
//
// func test_patch_make() {
//   let dmp = DiffMatchPatch()
//
//   NSMutableArray *patches;
//   patches = [dmp patch_makeFromOldString:"", andNewString:""];
//   XCTAssertEqual("", [dmp patch_toText:patches], "patch_make: Null case.")
//
//   NSString *text1 = "The quick brown fox jumps over the lazy dog.";
//   NSString *text2 = "That quick brown fox jumped over a lazy dog.";
//   NSString *expectedPatch = "@@ -1,8 +1,7 @@\n Th\n-at\n+e\n  qui\n@@ -21,17 +21,18 @@\n jump\n-ed\n+s\n  over \n-a\n+the\n  laz\n";
//   // The second patch must be "-21,17 +21,18", not "-22,17 +21,18" due to rolling context.
//   patches = [dmp patch_makeFromOldString:text2 andNewString:text1];
//   XCTAssertEqual(expectedPatch, [dmp patch_toText:patches], "patch_make: Text2+Text1 inputs.")
//
//   expectedPatch = "@@ -1,11 +1,12 @@\n Th\n-e\n+at\n  quick b\n@@ -22,18 +22,17 @@\n jump\n-s\n+ed\n  over \n-the\n+a\n  laz\n";
//   patches = [dmp patch_makeFromOldString:text1 andNewString:text2];
//   XCTAssertEqual(expectedPatch, [dmp patch_toText:patches], "patch_make: Text1+Text2 inputs.")
//
//   NSMutableArray *diffs = [dmp diff_mainOfOldString:text1 andNewString:text2 checkLines:NO];
//   patches = [dmp patch_makeFromDiffs:diffs];
//   XCTAssertEqual(expectedPatch, [dmp patch_toText:patches], "patch_make: Diff input.")
//
//   patches = [dmp patch_makeFromOldString:text1 andDiffs:diffs];
//   XCTAssertEqual(expectedPatch, [dmp patch_toText:patches], "patch_make: Text1+Diff inputs.")
//
//   patches = [dmp patch_makeFromOldString:text1 newString:text2 diffs:diffs];
//   XCTAssertEqual(expectedPatch, [dmp patch_toText:patches], "patch_make: Text1+Text2+Diff inputs (deprecated).")
//
//   patches = [dmp patch_makeFromOldString:"`1234567890-=[]\\;',./", andNewString:"~!@#$%^&*()_+{}|:\"<>?"];
//   XCTAssertEqual("@@ -1,21 +1,21 @@\n-%601234567890-=%5B%5D%5C;',./\n+~!@#$%25%5E&*()_+%7B%7D%7C:%22%3C%3E?\n",
//       [dmp patch_toText:patches],
//       "patch_toText: Character encoding.")
//
//   diffs = [NSMutableArray arrayWithObjects:
//       [Diff diffWithOperation:OperationDiffDelete andText:"`1234567890-=[]\\;',./"),
//       [Diff diffWithOperation:OperationDiffInsert andText:"~!@#$%^&*()_+{}|:\"<>?")]
//   XCTAssertEqual(diffs,
//       ((Patch *)[[dmp patch_fromText:"@@ -1,21 +1,21 @@\n-%601234567890-=%5B%5D%5C;',./\n+~!@#$%25%5E&*()_+%7B%7D%7C:%22%3C%3E?\n" error:NULL] objectAtIndex:0]).diffs,
//       "patch_fromText: Character decoding.")
//
//   NSMutableString *text1Mutable = [NSMutableString string];
//   for (int x = 0; x < 100; x++) {
//     [text1Mutable appendString:"abcdef"];
//   }
//   text1 = text1Mutable;
//   text2 = [text1 stringByAppendingString:"123"];
//   // CHANGEME: Why does this implementation produce a different, more brief patch?
//   //expectedPatch = "@@ -573,28 +573,31 @@\n cdefabcdefabcdefabcdefabcdef\n+123\n";
//   expectedPatch = "@@ -597,4 +597,7 @@\n cdef\n+123\n";
//   patches = [dmp patch_makeFromOldString:text1 andNewString:text2];
//   XCTAssertEqual(expectedPatch, [dmp patch_toText:patches], "patch_make: Long string with repeats.")
//
//   // CHANGEME: Test null inputs
//
//   [dmp release];
// }
//
//
// func test_patch_splitMax() {
//   // Assumes that Match_MaxBits is 32.
//   let dmp = DiffMatchPatch()
//   NSMutableArray *patches;
//
//   patches = [dmp patch_makeFromOldString:"abcdefghijklmnopqrstuvwxyz01234567890", andNewString:"XabXcdXefXghXijXklXmnXopXqrXstXuvXwxXyzX01X23X45X67X89X0"];
//   [dmp patch_splitMax:patches];
//   XCTAssertEqual("@@ -1,32 +1,46 @@\n+X\n ab\n+X\n cd\n+X\n ef\n+X\n gh\n+X\n ij\n+X\n kl\n+X\n mn\n+X\n op\n+X\n qr\n+X\n st\n+X\n uv\n+X\n wx\n+X\n yz\n+X\n 012345\n@@ -25,13 +39,18 @@\n zX01\n+X\n 23\n+X\n 45\n+X\n 67\n+X\n 89\n+X\n 0\n", [dmp patch_toText:patches], "Assumes that Match_MaxBits is 32 #1")
//
//   patches = [dmp patch_makeFromOldString:"abcdef1234567890123456789012345678901234567890123456789012345678901234567890uvwxyz", andNewString:"abcdefuvwxyz"];
//   NSString *oldToText = [dmp patch_toText:patches];
//   [dmp patch_splitMax:patches];
//   XCTAssertEqual(oldToText, [dmp patch_toText:patches], "Assumes that Match_MaxBits is 32 #2")
//
//   patches = [dmp patch_makeFromOldString:"1234567890123456789012345678901234567890123456789012345678901234567890", andNewString:"abc"];
//   [dmp patch_splitMax:patches];
//   XCTAssertEqual("@@ -1,32 +1,4 @@\n-1234567890123456789012345678\n 9012\n@@ -29,32 +1,4 @@\n-9012345678901234567890123456\n 7890\n@@ -57,14 +1,3 @@\n-78901234567890\n+abc\n", [dmp patch_toText:patches], "Assumes that Match_MaxBits is 32 #3")
//
//   patches = [dmp patch_makeFromOldString:"abcdefghij , h : 0 , t : 1 abcdefghij , h : 0 , t : 1 abcdefghij , h : 0 , t : 1", andNewString:"abcdefghij , h : 1 , t : 1 abcdefghij , h : 1 , t : 1 abcdefghij , h : 0 , t : 1"];
//   [dmp patch_splitMax:patches];
//   XCTAssertEqual("@@ -2,32 +2,32 @@\n bcdefghij , h : \n-0\n+1\n  , t : 1 abcdef\n@@ -29,32 +29,32 @@\n bcdefghij , h : \n-0\n+1\n  , t : 1 abcdef\n", [dmp patch_toText:patches], "Assumes that Match_MaxBits is 32 #4")
//
//   [dmp release];
// }
//
// func test_patch_addPadding() {
//   let dmp = DiffMatchPatch()
//
//   NSMutableArray *patches;
//   patches = [dmp patch_makeFromOldString:"", andNewString:"test"];
//   XCTAssertEqual("@@ -0,0 +1,4 @@\n+test\n",
//       [dmp patch_toText:patches],
//       "patch_addPadding: Both edges full.")
//   [dmp patch_addPadding:patches];
//   XCTAssertEqual("@@ -1,8 +1,12 @@\n %01%02%03%04\n+test\n %01%02%03%04\n",
//       [dmp patch_toText:patches],
//       "patch_addPadding: Both edges full.")
//
//   patches = [dmp patch_makeFromOldString:"XY", andNewString:"XtestY"];
//   XCTAssertEqual("@@ -1,2 +1,6 @@\n X\n+test\n Y\n",
//       [dmp patch_toText:patches],
//       "patch_addPadding: Both edges partial.")
//   [dmp patch_addPadding:patches];
//   XCTAssertEqual("@@ -2,8 +2,12 @@\n %02%03%04X\n+test\n Y%01%02%03\n",
//       [dmp patch_toText:patches],
//       "patch_addPadding: Both edges partial.")
//
//   patches = [dmp patch_makeFromOldString:"XXXXYYYY", andNewString:"XXXXtestYYYY"];
//   XCTAssertEqual("@@ -1,8 +1,12 @@\n XXXX\n+test\n YYYY\n",
//       [dmp patch_toText:patches],
//       "patch_addPadding: Both edges none.")
//   [dmp patch_addPadding:patches];
//   XCTAssertEqual("@@ -5,8 +5,12 @@\n XXXX\n+test\n YYYY\n",
//       [dmp patch_toText:patches],
//       "patch_addPadding: Both edges none.")
//
//   [dmp release];
// }
//
// func test_patch_apply() {
//   let dmp = DiffMatchPatch()
//
//   dmp.Match_Distance = 1000;
//   dmp.Match_Threshold = 0.5f;
//   dmp.Patch_DeleteThreshold = 0.5f;
//   NSMutableArray *patches;
//   patches = [dmp patch_makeFromOldString:"", andNewString:""];
//   NSArray *results = [dmp patch_apply:patches toString:"Hello world."];
//   NSMutableArray *boolArray = [results objectAtIndex:1];
//   NSString *resultStr = [NSString stringWithFormat:"%@\t%lu", [results objectAtIndex:0], (unsigned long)boolArray.count];
//   XCTAssertEqual("Hello world.\t0", resultStr, "patch_apply: Null case.")
//
//   patches = [dmp patch_makeFromOldString:"The quick brown fox jumps over the lazy dog.", andNewString:"That quick brown fox jumped over a lazy dog."];
//   results = [dmp patch_apply:patches toString:"The quick brown fox jumps over the lazy dog."];
//   boolArray = [results objectAtIndex:1];
//   resultStr = [NSString stringWithFormat:"%@\t%@\t%", [results objectAtIndex:0], stringForBOOL([boolArray objectAtIndex:0]), stringForBOOL([boolArray objectAtIndex:1])];
//   XCTAssertEqual("That quick brown fox jumped over a lazy dog.\ttrue\ttrue", resultStr, "patch_apply: Exact match.")
//
//   results = [dmp patch_apply:patches toString:"The quick red rabbit jumps over the tired tiger."];
//   boolArray = [results objectAtIndex:1];
//   resultStr = [NSString stringWithFormat:"%@\t%@\t%", [results objectAtIndex:0], stringForBOOL([boolArray objectAtIndex:0]), stringForBOOL([boolArray objectAtIndex:1])];
//   XCTAssertEqual("That quick red rabbit jumped over a tired tiger.\ttrue\ttrue", resultStr, "patch_apply: Partial match.")
//
//   results = [dmp patch_apply:patches toString:"I am the very model of a modern major general."];
//   boolArray = [results objectAtIndex:1];
//   resultStr = [NSString stringWithFormat:"%@\t%@\t%", [results objectAtIndex:0], stringForBOOL([boolArray objectAtIndex:0]), stringForBOOL([boolArray objectAtIndex:1])];
//   XCTAssertEqual("I am the very model of a modern major general.\tfalse\tfalse", resultStr, "patch_apply: Failed match.")
//
//   patches = [dmp patch_makeFromOldString:"x1234567890123456789012345678901234567890123456789012345678901234567890y", andNewString:"xabcy"];
//   results = [dmp patch_apply:patches toString:"x123456789012345678901234567890-----++++++++++-----123456789012345678901234567890y"];
//   boolArray = [results objectAtIndex:1];
//   resultStr = [NSString stringWithFormat:"%@\t%@\t%", [results objectAtIndex:0], stringForBOOL([boolArray objectAtIndex:0]), stringForBOOL([boolArray objectAtIndex:1])];
//   XCTAssertEqual("xabcy\ttrue\ttrue", resultStr, "patch_apply: Big delete, small change.")
//
//   patches = [dmp patch_makeFromOldString:"x1234567890123456789012345678901234567890123456789012345678901234567890y", andNewString:"xabcy"];
//   results = [dmp patch_apply:patches toString:"x12345678901234567890---------------++++++++++---------------12345678901234567890y"];
//   boolArray = [results objectAtIndex:1];
//   resultStr = [NSString stringWithFormat:"%@\t%@\t%", [results objectAtIndex:0], stringForBOOL([boolArray objectAtIndex:0]), stringForBOOL([boolArray objectAtIndex:1])];
//   XCTAssertEqual("xabc12345678901234567890---------------++++++++++---------------12345678901234567890y\tfalse\ttrue", resultStr, "patch_apply: Big delete, big change 1.")
//
//   dmp.Patch_DeleteThreshold = 0.6f;
//   patches = [dmp patch_makeFromOldString:"x1234567890123456789012345678901234567890123456789012345678901234567890y", andNewString:"xabcy"];
//   results = [dmp patch_apply:patches toString:"x12345678901234567890---------------++++++++++---------------12345678901234567890y"];
//   boolArray = [results objectAtIndex:1];
//   resultStr = [NSString stringWithFormat:"%@\t%@\t%", [results objectAtIndex:0], stringForBOOL([boolArray objectAtIndex:0]), stringForBOOL([boolArray objectAtIndex:1])];
//   XCTAssertEqual("xabcy\ttrue\ttrue", resultStr, "patch_apply: Big delete, big change 2.")
//   dmp.Patch_DeleteThreshold = 0.5f;
//
//   dmp.Match_Threshold = 0.0f;
//   dmp.Match_Distance = 0;
//   patches = [dmp patch_makeFromOldString:"abcdefghijklmnopqrstuvwxyz--------------------1234567890", andNewString:"abcXXXXXXXXXXdefghijklmnopqrstuvwxyz--------------------1234567YYYYYYYYYY890"];
//   results = [dmp patch_apply:patches toString:"ABCDEFGHIJKLMNOPQRSTUVWXYZ--------------------1234567890"];
//   boolArray = [results objectAtIndex:1];
//   resultStr = [NSString stringWithFormat:"%@\t%@\t%", [results objectAtIndex:0], stringForBOOL([boolArray objectAtIndex:0]), stringForBOOL([boolArray objectAtIndex:1])];
//   XCTAssertEqual("ABCDEFGHIJKLMNOPQRSTUVWXYZ--------------------1234567YYYYYYYYYY890\tfalse\ttrue", resultStr, "patch_apply: Compensate for failed patch.")
//   dmp.Match_Threshold = 0.5f;
//   dmp.Match_Distance = 1000;
//
//   patches = [dmp patch_makeFromOldString:"", andNewString:"test"];
//   NSString *patchStr = [dmp patch_toText:patches];
//   [dmp patch_apply:patches toString:""];
//   XCTAssertEqual(patchStr, [dmp patch_toText:patches], "patch_apply: No side effects.")
//
//   patches = [dmp patch_makeFromOldString:"The quick brown fox jumps over the lazy dog.", andNewString:"Woof"];
//   patchStr = [dmp patch_toText:patches];
//   [dmp patch_apply:patches toString:"The quick brown fox jumps over the lazy dog."];
//   XCTAssertEqual(patchStr, [dmp patch_toText:patches], "patch_apply: No side effects with major delete.")
//
//   patches = [dmp patch_makeFromOldString:"", andNewString:"test"];
//   results = [dmp patch_apply:patches toString:""];
//   boolArray = [results objectAtIndex:1];
//   resultStr = [NSString stringWithFormat:"%@\t%", [results objectAtIndex:0], stringForBOOL([boolArray objectAtIndex:0])];
//   XCTAssertEqual("test\ttrue", resultStr, "patch_apply: Edge exact match.")
//
//   patches = [dmp patch_makeFromOldString:"XY", andNewString:"XtestY"];
//   results = [dmp patch_apply:patches toString:"XY"];
//   boolArray = [results objectAtIndex:1];
//   resultStr = [NSString stringWithFormat:"%@\t%", [results objectAtIndex:0], stringForBOOL([boolArray objectAtIndex:0])];
//   XCTAssertEqual("XtestY\ttrue", resultStr, "patch_apply: Near edge exact match.")
//
//   patches = [dmp patch_makeFromOldString:"y", andNewString:"y123"];
//   results = [dmp patch_apply:patches toString:"x"];
//   boolArray = [results objectAtIndex:1];
//   resultStr = [NSString stringWithFormat:"%@\t%", [results objectAtIndex:0], stringForBOOL([boolArray objectAtIndex:0])];
//   XCTAssertEqual("x123\ttrue", resultStr, "patch_apply: Edge partial match.")
//
//   [dmp release];
// }
//
// - (void)test_diff_nscoding {
//     Diff *orig = [Diff new];
//     orig.operation = OperationDiffEqual;
//     orig.text = @"foo";
//     NSData *data = [NSKeyedArchiver archivedDataWithRootObject:orig];
//     XCTAssertNotNil(data);
//     Diff *res = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//     XCTAssertNotNil(res);
//     XCTAssertEqual(res.operation, OperationDiffEqual);
//     XCTAssertEqual(res.text, @"foo");
// }
//
// - (void)test_patch_nscoding {
//     Diff *diff = [Diff new];
//     diff.operation = OperationDiffEqual;
//     diff.text = @"foo";
//
//     Patch *orig = [Patch new];
//     orig.diffs = [@[diff] mutableCopy];
//     orig.start1 = 1;
//     orig.start2 = 2;
//     orig.length1 = 3;
//     orig.length2 = 4;
//
//     NSData *data = [NSKeyedArchiver archivedDataWithRootObject:orig];
//     XCTAssertNotNil(data);
//     Patch *res = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//     XCTAssertNotNil(res);
//
//     XCTAssertEqual(res.diffs.count, 1ul);
//     XCTAssertEqual(res.diffs[0].operation, OperationDiffEqual);
//     XCTAssertEqual(res.diffs[0].text, @"foo");
//     XCTAssertEqual(res.start1, 1ul);
//     XCTAssertEqual(res.start2, 2ul);
//     XCTAssertEqual(res.length1, 3ul);
//     XCTAssertEqual(res.length2, 4ul);
// }
//
// #pragma mark Test Utility Functions
// //  TEST UTILITY FUNCTIONS
//
//
// - (NSArray *)diff_rebuildtexts:(NSMutableArray *)diffs;
// {
//   NSArray *text = [NSMutableArray arrayWithObjects:[NSMutableString string], [NSMutableString string]]
//   for (Diff *myDiff in diffs) {
//     if (myDiff.operation != OperationDiffInsert) {
//       [[text objectAtIndex:0] appendString:myDiff.text];
//     }
//     if (myDiff.operation != OperationDiffDelete) {
//       [[text objectAtIndex:1] appendString:myDiff.text];
//     }
//   }
//   return text;
// }
//
// @end
