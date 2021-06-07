module Ai4cr
  module NeuralNetwork
    module Pmn
      # # Aliases

      # # alias Offset = Array(Int32)
      # # alias NodeCoord = NamedTuple(from_channel: String, from_offset: Offset)
      # # alias HeightSet = Hash(NodeCoord, Int32)
      # # alias HeightSetIndexes = Hash(NodeCoord, Array(Int32))

      # alias Offset = Array(Int32)
      # alias NodeGrid = Hash(Offset, Int32)
      # # alias NodeConnectionProps = NamedTuple(
      # #   from_channel: String,
      # #   from_offset: Offset
      # # )
      # # alias NodeConnection = Hash(
      # #   String,
      # #   NodeConnectionProps
      # # )

      # ParallelNet
      alias NodeCoord = Array(Int32)
      alias NodeMap = Hash(NodeCoord, ParallelNode)
      alias IoSizes = Hash(NodeCoord, Int32)
      alias IoSet = Hash(NodeCoord, Array(Float64))
      alias NodeConnections = Hash(NodeCoord, Array(NodeCoord))

      # MiniNetData
      alias HeightSet = Hash(NodeCoord, Int32)
      alias HeightSetIndexes = Hash(NodeCoord, Array(Int32))

      # general
      alias ValidationErrorMessages = Hash(String, String)
    end
  end
end
