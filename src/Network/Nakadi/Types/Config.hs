{-|
Module      : Network.Nakadi.Types.Config
Description : Nakadi Config Types
Copyright   : (c) Moritz Clasmeier 2017, 2018
License     : BSD3
Maintainer  : mtesseract@silverratio.net
Stability   : experimental
Portability : POSIX

This module provides the Nakadi Config Types.
-}

module Network.Nakadi.Types.Config
  ( Config
  , ConfigIO
  , StreamConnectCallback
  , HttpBackend(..)
  ) where

import           Network.Nakadi.Internal.Types.Config
