module Common (run) where

import Control.Applicative
import Control.Monad
import System.FilePath
import System.Directory
import System.Exit
import System.Process
import System.Environment
import System.IO
import Data.List

run :: String -> IO ()
run program = do
    config <- (</> "cabal.sandbox.config") <$> getCurrentDirectory
    doesFileExist config >>= \ex -> unless ex $ 
        hPutStrLn stderr "not in sandbox" >> exitFailure
    db <- getPackageDBFromConfig config
    args <- getArgs
    void $ rawSystem program $ "-no-user-package-db" : ("-package-db=" ++ db) : args

getPackageDBFromConfig :: FilePath -> IO FilePath
getPackageDBFromConfig filename = do
    file <- readFile filename
    case filter ("package-db:" `isPrefixOf`) $ lines file of
        pdb:_ -> return . dropWhile (`elem` " \t") . drop 11 $ pdb
        _     -> fail $ filename ++ ": package-db entry not found."
