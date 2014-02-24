import Control.Applicative
import Control.Monad
import Control.Monad.Trans.Maybe
import System.FilePath
import System.Directory
import System.Exit
import Data.List
import Data.Maybe
import System.Process
import System.Environment
import System.IO

main :: IO ()
main = do
    config <- (</> "cabal.sandbox.config") <$> getCurrentDirectory
    doesFileExist config >>= \ex -> unless ex $ 
        hPutStrLn stderr "not in sandbox" >> exitFailure
    mbfile <- getPackageDBFromConfig config
    case mbfile of
        Nothing -> putStrLn "cannot find package-db field" >> exitFailure
        Just db -> do 
            args <- getArgs
            void $ rawSystem "runhaskell" $ "-no-user-package-db" : ("-package-db=" ++ db) : args

getPackageDBFromConfig :: FilePath -> IO (Maybe FilePath)
getPackageDBFromConfig filename = runMaybeT $ 
    dropWhile (`elem` " \t") . drop 11 <$>
    MaybeT (listToMaybe . filter ("package-db:" `isPrefixOf`) . lines <$> readFile filename)

