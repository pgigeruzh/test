{-# LANGUAGE OverloadedStrings #-}

import Hakyll
import System.FilePath
import System.Directory
import Data.List
import Hakyll.Core.Compiler.Internal
import Control.Applicative (empty)
import Data.Monoid (mappend)
import qualified Data.Text as Text
import qualified Text.Pandoc as Pandoc

config :: Configuration
config = defaultConfiguration 
    { destinationDirectory = "docs"
    }

main :: IO ()
main = hakyllWith config $ do
    -- compile templates
    match "templates/*" $ compile templateBodyCompiler

    -- copy assets folder
    match "assets/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "assets/css/*" $ do
        route   idRoute
        compile compressCssCompiler

    -- compile unterricht (slides)
    match "unterricht/*/slides.md" $ do
        route $ setExtension "html"
        compile $ customSlidesPandocCompiler defaultHakyllReaderOptions defaultHakyllWriterOptions
            >>= loadAndApplyTemplate "templates/revealjs.html" customContext
            >>= relativizeUrls

    match "unterricht/*/*/slides.md" $ do
        route $ setExtension "html"
        compile $ customSlidesPandocCompiler defaultHakyllReaderOptions defaultHakyllWriterOptions
            >>= loadAndApplyTemplate "templates/revealjs.html" customContext
            >>= relativizeUrls

    -- compile unterricht (articles)
    match "unterricht/*/index.md" $ do
        route $ setExtension "html"
        compile $ customBiblioPandocCompiler
            >>= loadAndApplyTemplate "templates/unterricht.html" customContext
            >>= loadAndApplyTemplate "templates/default.html" customContext
            >>= relativizeUrls

    match "unterricht/*/*/index.md" $ do
        route $ setExtension "html"
        compile $ customBiblioPandocCompiler
            >>= loadAndApplyTemplate "templates/unterricht.html" customContext
            >>= loadAndApplyTemplate "templates/default.html" customContext
            >>= relativizeUrls

    match "unterricht/*/references/*.csl" $ compile cslCompiler
    match "unterricht/*/references/*.bib" $ compile biblioCompiler
    
    match "unterricht/*/*/references/*.csl" $ compile cslCompiler
    match "unterricht/*/*/references/*.bib" $ compile biblioCompiler

    match "unterricht/*/images/*" $ do
        route idRoute
        compile copyFileCompiler

    match "unterricht/*/*/images/*" $ do
        route idRoute
        compile copyFileCompiler

    match "unterricht/*/files/*" $ do
        route idRoute
        compile copyFileCompiler

    match "unterricht/*/*/files/*" $ do
        route idRoute
        compile copyFileCompiler

    -- compile index
    create ["index.html"] $ do
        route $ setExtension "html"
        compile $ do
            unterrichtsliste <- loadAll "unterricht/*/index.md"
            let ctx =
                    listField "unterrichtsliste" customContext (return unterrichtsliste) `mappend`
                    customContext

            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    -- compile unterricht uebersicht
    create ["unterricht.html"] $ do
        route cleanRoute
        compile $ do
            unterrichtsliste <- loadAll "unterricht/*/index.md"
            let ctx =
                    listField "unterrichtsliste" customContext (return unterrichtsliste) `mappend`
                    constField "title" "Unterrichtsmaterialien" `mappend`
                    customContext

            getResourceBody
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    -- compile kontakt
    match "kontakt/index.md" $ do
        route $ setExtension "html"
        compile $ customBiblioPandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" customContext
            >>= relativizeUrls
    
    match "kontakt/images/*" $ do
        route idRoute
        compile copyFileCompiler

-- custom pandoc compiler with support for .bib files
customBiblioPandocCompiler :: Compiler (Item String)
customBiblioPandocCompiler = do
    identifier <- getUnderlying
    bibliography <- compilerUnsafeIO $ doesFileExist $ takeDirectory (toFilePath identifier) ++ "/references/references.bib"
    if bibliography then
        do
            csl <- load $ fromFilePath $ takeDirectory (toFilePath identifier) ++ "/references/references.csl"
            bib <- load $ fromFilePath $ takeDirectory (toFilePath identifier) ++ "/references/references.bib"
            getResourceBody >>= readPandocBiblio defaultHakyllReaderOptions csl bib >>= return . writePandoc
    else
        pandocCompiler

-- custom pandoc compiler for slides (reveal.js)
customSlidesPandocCompiler :: Pandoc.ReaderOptions -> Pandoc.WriterOptions -> Compiler (Item String)
customSlidesPandocCompiler ropt wopt =
    cached "customSlidesPandocCompiler" $
        writePandocSlideWith wopt <$>
        (traverse (return.id) =<< readPandocWith ropt =<< getResourceBody)
    where
        writePandocSlideWith :: Pandoc.WriterOptions -> Item Pandoc.Pandoc -> Item String
        writePandocSlideWith wopt (Item itemi doc) =
            case Pandoc.runPure $ Pandoc.writeRevealJs wopt doc of
                Left err    -> error $ "writePandocSlidesWith: " ++ show err
                Right item' -> Item itemi $ Text.unpack item'

-- clean routing e.g. /unterricht.html -> /unterricht or /slides.html -> /slides
-- only needed for names other than index.html because
-- e.g. /programming/index.html is automatically redirected to /programming (by the browser)
cleanRoute :: Routes
cleanRoute = customRoute createIndexRoute
    where
        createIndexRoute ident = takeDirectory p </> takeBaseName p </> "index.html"
            where
                p = toFilePath ident

removeIndexHtml :: Item String -> Compiler (Item String)
removeIndexHtml item = return $ fmap (withUrls removeIndexStr) item

removeIndexStr :: String -> String
removeIndexStr url = case splitFileName url of
    (dir, "index.html") | isLocal dir -> dir
                        | otherwise -> url
    _ -> url
    where
        isLocal :: String -> Bool
        isLocal uri = not ("://" `isInfixOf` uri)

-- context
urlWithoutIndexHtml :: Context a
urlWithoutIndexHtml = field "urlWithoutIndexHtml" $ fmap (maybe empty $ removeIndexStr . toUrl) . getRoute . itemIdentifier

customContext :: Context String
customContext =
    urlWithoutIndexHtml `mappend`
    defaultContext