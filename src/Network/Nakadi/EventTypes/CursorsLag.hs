{-|
Module      : Network.Nakadi.EventTypes.CursorsLag
Description : Implementation of Nakadi CursorsLag API
Copyright   : (c) Moritz Schulte 2017
License     : BSD3
Maintainer  : mtesseract@silverratio.net
Stability   : experimental
Portability : POSIX

This module implements the
@\/event-types\/EVENT-TYPE\/cursors-lag@ API.
-}

{-# LANGUAGE TupleSections #-}
{-# LANGUAGE FlexibleContexts #-}

module Network.Nakadi.EventTypes.CursorsLag
  ( eventTypeCursorsLag'
  , eventTypeCursorsLagR'
  , eventTypeCursorsLag
  , eventTypeCursorsLagR
  ) where

import           Network.Nakadi.Internal.Prelude

import           Control.Arrow
import           Control.Lens
import qualified Data.Map.Strict                 as Map
import           Network.Nakadi.Internal.Http
import qualified Network.Nakadi.Internal.Lenses  as L

path :: EventTypeName -> ByteString
path eventTypeName =
  "/event-types/"
  <> encodeUtf8 (unEventTypeName eventTypeName)
  <> "/cursors-lag"

-- | @POST@ to @\/event-types\/EVENT-TYPE\/cursors-lag@. Low level
-- interface.
eventTypeCursorsLag' ::
  MonadNakadi m
  => Config        -- ^ Configuration
  -> EventTypeName -- ^ Event Type
  -> [Cursor]      -- ^ Cursors for which to compute the lag for
  -> m [Partition] -- ^ Resulting partition information containing
                   -- information about unconsumed events.
eventTypeCursorsLag' config eventTypeName cursors =
  httpJsonBody config ok200 []
  (setRequestMethod "POST"
   . setRequestPath (path eventTypeName)
   . setRequestBodyJSON cursors)

-- | @POST@ to @\/event-types\/EVENT-TYPE\/cursors-lag@. Low level
-- interface, retrieving configuration from environment.
eventTypeCursorsLagR' ::
  MonadNakadiEnv r m
  => EventTypeName -- ^ Event Type
  -> [Cursor]      -- ^ Cursors for which to compute the lag for
  -> m [Partition] -- ^ Resulting partition information containing
                   -- information about unconsumed events.
eventTypeCursorsLagR' eventTypeName cursors = do
  config <- asks (view L.nakadiConfig)
  eventTypeCursorsLag' config eventTypeName cursors

-- | @POST@ to @\/event-types\/EVENT-TYPE\/cursors-lag@. High level
-- interface.
eventTypeCursorsLag ::
  MonadNakadi m
  => Config                         -- ^ Configuration
  -> EventTypeName                  -- ^ Event Type
  -> Map PartitionName CursorOffset -- ^ Cursor offsets associated to
                                    -- partitions.
  -> m (Map PartitionName Int64)    -- ^ Cursor lags associated to partitions.
eventTypeCursorsLag config eventTypeName cursorsMap = do
  partitionStats <- eventTypeCursorsLag' config eventTypeName cursors
  return $ partitionStats & map ((view L.partition &&& view L.unconsumedEvents) >>> sequenceSnd)
                          & catMaybes
                          & Map.fromList
  where cursors = map (uncurry Cursor) (Map.toList cursorsMap)

-- | @POST@ to @\/event-types\/EVENT-TYPE\/cursors-lag@. High level
-- interface, retrieving configuration from environment.
eventTypeCursorsLagR ::
  MonadNakadiEnv r m
  => EventTypeName                  -- ^ Event Type
  -> Map PartitionName CursorOffset -- ^ Cursor offsets associated to
                                    -- partitions.
  -> m (Map PartitionName Int64)    -- ^ Cursor lags associated to partitions.
eventTypeCursorsLagR eventTypeName cursorsMap = do
  config <- asks (view L.nakadiConfig)
  eventTypeCursorsLag config eventTypeName cursorsMap

sequenceSnd :: Functor f => (a, f b) -> f (a, b)
sequenceSnd (a, fb) = (a,) <$> fb