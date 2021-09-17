# Overview

This website is built with [Hakyll](https://jaspervdj.be/hakyll/), a Haskell library for generating static sites. Hakyll uses [Pandoc](https://pandoc.org/) to convert markdown into a complete website.

## Development (when changing Haskell .hs files)
```Haskell
cabal clean
cabal build
```

## Usage (when changing Haskell .md files)
```Haskell
# clean project if necessary
cabal exec site clean
# start dev server
cabal exec site watch
```

## Deployment
```Haskell
# output: see docs folder
cabal exec site clean
cabal exec site rebuild
```