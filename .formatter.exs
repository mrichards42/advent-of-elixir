# Used by "mix format"
[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  import_deps: [:nimble_parsec],
  locals_without_parens: [defparser: 2, defmemo: 2]
]
