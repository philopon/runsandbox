module Cabal (extensions) where

import Language.Haskell.Extension

import Control.Applicative

import System.IO

import Distribution.PackageDescription
import Distribution.PackageDescription.Parse
import Distribution.PackageDescription.Configuration

extensions :: FilePath -> IO [KnownExtension]
extensions cabal =
    parsePackageDescription <$> readFile cabal >>= \r -> case r of
        ParseFailed e  -> fail $ show e
        ParseOk w pdsc -> do 
            mapM_ (hPrint stderr) w
            return . concatMap enables . concatMap usedExtensions . allBuildInfo $ flattenPackageDescription pdsc

enables :: Extension -> [KnownExtension]
enables (EnableExtension e) = [e]
enables _                   = []


