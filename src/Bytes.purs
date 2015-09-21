module Bytes
  ( Bytes
  , fromBigInt
  , toBigInt
  , fromBytes
  , clamp
  ) where

import Prelude
import Data.Int (floor)
import qualified Data.BigInt as BigInt
import UnsignedInts (UInt8(), intToByte, byteToInt)
import LargeKey (LargeKey(..))

class (BoundedOrd a) <= Bytes a where
  toBigInt :: a -> BigInt.BigInt
  fromBigInt :: BigInt.BigInt -> a

fromBytes :: forall a b. (Bytes a, Bytes b) => a -> b
fromBytes = fromBigInt <<< toBigInt

clamp :: forall b. (Bytes b) => BigInt.BigInt -> b
clamp x = fromBigInt (if x > limit then limit else x) where
  limit = toBigInt (top :: b)

instance bytesUInt8 :: Bytes UInt8 where
  toBigInt = BigInt.fromInt <<< byteToInt
  fromBigInt x = intToByte <<< floor <<< BigInt.toNumber $ x `mod` (BigInt.fromInt 256)

instance bytesLargeKey :: (Bytes a, Bytes b) => Bytes (LargeKey a b) where
  toBigInt (LargeKey a b) = hi + lo where
    shiftAmount = toBigInt (top :: b) + (one :: BigInt.BigInt)
    hi = shiftAmount * (toBigInt a)
    lo = toBigInt b
  fromBigInt x = (LargeKey hi lo) where
    shiftAmount = toBigInt (top :: b) + (one:: BigInt.BigInt)
    hi = fromBigInt $ x `div` shiftAmount
    lo = fromBigInt $ x `mod` shiftAmount
