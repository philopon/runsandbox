module Common (run) where

import Control.Monad
import System.FilePath
import System.Directory
import System.Process
import System.Environment
import Data.List

import Cabal

run :: String -> IO ()
run program = do
    cd     <- getCurrentDirectory
    let config = cd </> "cabal.sandbox.config"
    ex  <- doesFileExist config
    pkg <- if not ex
           then return []
           else do
               db   <- getPackageDBFromConfig config
               return ["-no-user-package-db", "-package-db=" ++ db]

    exts <- liftM (map (("-X" ++) . show) . concat) . mapM extensions .
            filter ((== ".cabal") . takeExtension) =<< getDirectoryContents cd

    args <- getArgs
    void $ rawSystem program $ pkg ++ exts ++ args

getPackageDBFromConfig :: FilePath -> IO FilePath
getPackageDBFromConfig filename = do
    file <- readFile filename
    case filter ("package-db:" `isPrefixOf`) $ lines file of
        pdb:_ -> return . dropWhile (`elem` " \t") . drop 11 $ pdb
        _     -> fail $ filename ++ ": package-db entry not found."
