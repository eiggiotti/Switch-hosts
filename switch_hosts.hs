{-# LANGUAGE OverloadedStrings #-}

import System.Environment (getArgs)
import System.Console.GetOpt
import Data.Char (toUpper)
import qualified Data.Text as T
import qualified Data.Text.IO as I

data Host = Recette
          | Local
          | Dev
          | Integ
          | Preprod
          | Prod
          deriving (Enum)

instance Show Host where
    show Recette = "# RECETTE"
    show Local   = "# LOCAL"
    show Dev     = "# DEV"
    show Integ   = "# INTEG"
    show Preprod = "# PREPROD"
    show Prod    = "# PROD"

options :: [OptDescr Host]
options = [Option ['r'] ["recette"] (NoArg Recette) "switch to recette"
          ,Option ['l'] ["local"] (NoArg Local) "switch to localhost"
          ,Option ['d'] ["dev"] (NoArg Dev) "switch to dev"
          ,Option ['i'] ["integ"] (NoArg Integ) "switch to integ"
          ,Option ['p'] ["preprod"] (NoArg Preprod) "switch to preprod"
          ,Option ['n'] ["none"] (NoArg Prod) "switch to prod"]

usage = "Usage: change_hosts [-r | -l | -d | -i | -p | -n]"

toggleLines :: Host -> [T.Text] -> [T.Text]
toggleLines _ [] = []
toggleLines host lines = let hostsNames = map (T.pack . show) [Recette .. Preprod]
                             (beginning, rest) = span (flip notElem hostsNames) lines
                             (hostLines, rest') = case rest of
                                                    [] -> ([],[])
                                                    r@(x:_)  -> if x == T.pack (show host)
                                                                  then removeSharps r
                                                                  else addSharps r
                         in beginning ++ hostLines ++ (toggleLines host rest')

removeSharps :: [T.Text] -> ([T.Text], [T.Text])
removeSharps = modifySharps (\x -> if T.head x == '#' then T.tail x else x)

addSharps :: [T.Text] -> ([T.Text], [T.Text])
addSharps = modifySharps (\x -> if T.head x == '#' then x else T.cons '#' x)

modifySharps :: (T.Text -> T.Text) -> [T.Text] -> ([T.Text], [T.Text])
modifySharps f lines = let ((hostName : hostRules), rest) = span (\l -> l /= "") lines
                       in (hostName : map f hostRules, rest)

main = do args <- getArgs
          case getOpt Permute options args of
            ((host: _), [], [])  -> do content <- I.readFile "/etc/hosts"
                                       I.writeFile "/etc/hosts" $ T.unlines $ toggleLines host (T.lines content)
            (_, nonOpts, []) -> error $ "unrecognized arguments: " ++ unwords nonOpts
            (_, _, msgs)     -> error $ concat msgs ++ usageInfo usage options
