{- |
Module : Project.Maven
Copyright : Copyright (C) 2014 Krzysztof Langner
License : BSD3

Maintainer : Krzysztof Langner <klangner@gmail.com>
Stability : alpha
Portability : portable

Get information about project from Maven POM file.
-}
module Project.Maven ( loadProject
                     )where

import Text.XML.HXT.Core
import Data.Tree.NTree.TypeDefs
import Text.XML.HXT.XPath.XPathEval
import System.FilePath (normalise)
import System.Directory (doesFileExist)
import Project.Model


-- | Load project information from POM file.
loadProject :: FilePath -> IO (Maybe Project) 
loadProject src = do 
    let pomPath = normalise (src ++ "/pom.xml")
    fileExists <- doesFileExist pomPath
    xs <- if fileExists then runX (readDocument [] pomPath) else return []
    return $ if not (null xs) then Just (createFromPom src (head xs)) else Nothing


-- | Create Project data from POM file
createFromPom :: FilePath -> XmlTree -> Project
createFromPom src xt = Project src (metadataFromPom xt)


-- | Read metadata from pom
metadataFromPom :: XmlTree -> Metadata
metadataFromPom xt = Metadata (projectGroup xt) 
                              (projectArtifact xt) 
                              (projectName xt) 
                              (projectDesc xt)


-- | Get project group from POM. 
projectGroup :: XmlTree -> String
projectGroup = getNodeText "/project/groupId/text()"

-- | Get project artifact from POM. 
projectArtifact :: XmlTree -> String
projectArtifact = getNodeText "/project/artifactId/text()"

-- | Get project name from POM. 
projectName :: XmlTree -> String
projectName = getNodeText "/project/name/text()"

-- | Get project description from POM. 
projectDesc :: XmlTree -> String
projectDesc = getNodeText "/project/description/text()"

-- | Get text from given node 
getNodeText :: String -> XmlTree -> String
getNodeText xpath dom = case getXPath xpath dom of
                         [NTree (XText a) _] -> a
                         _ -> ""