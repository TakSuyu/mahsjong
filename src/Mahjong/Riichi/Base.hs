module Mahjong.Riichi.Base ( makeLenses
                           , RawTile ()
                           , Pile
                           , Hand (..)
                           , Player (..)
                           , defaultPlayer
                           , playerDrawTurn
                           , playerDiscardTurn
                           , Round (..)
                           , Turn (..)
                           ) where

import           Control.Lens
import           Data.List

import           Mahjong.Riichi.Player
import           Mahjong.Tile


-- | We want to look through the list and remove the elem from that list; using
-- Right signifies that the operation was successful and that we can continue on
-- with the process.
takeFrom :: (Eq a) => a -> [a] -> String -> Either String [a]
takeFrom t ts message = let tz = delete t ts
                         in if tz == ts
                            then Right tz
                            else Left message

-- | Because the structure that a player draws from is pure, we don't have to
-- worry about side effects within the function. However, we do have to make
-- sure that at the end of the player's turn if there is no more tiles that the
-- game ends. Usually this means that the the hand (the current instance of the
-- game being played) will end in a draw unless the current player wins, or a
-- player wins off this player's discard.
playerDrawTurn :: Tile -> Player -> Player
playerDrawTurn t = hand . unHand %~ cons t

-- | Discarding has a few side effects that we have to watch out for like if a
-- player gives an invalid tile from the outside. To handle this we will return
-- an Either that will throw an error that will be returned to the client so
-- that they can pick a valid discard.
playerDiscardTurn :: Tile -> Player -> Either String Player
playerDiscardTurn t p = takeFrom t (_unHand . _hand $ p) "Tile wasn't in the Hand"
                        & _Right -- If the tile existed it's now gone
                        %~ (\ newHand ->
                              p { _discardPile = t : _discardPile p
                                , _hand = Hand newHand
                                }
                           )

data Round
  = EastRound
  | SouthRound
  | WestRound
  | NorthRound
  deriving (Eq, Ord, Enum, Bounded, Show)

data Turn
  = EastTurn
  | SouthTurn
  | WestTurn
  | NorthTurn
  deriving (Eq, Ord, Enum, Bounded, Show)
