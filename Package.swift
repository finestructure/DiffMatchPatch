import PackageDescription

let package = Package(
    name: "DiffMatchPatch",
    targets: [Target(name: "DiffMatchPatch", dependencies:["diff_match_patch"])]
)
