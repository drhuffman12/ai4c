# parallel_mini_net.cr

# require "./../cmn/mini_net"
# require "./concerns/*.cr"

# Ai4cr::NeuralNetwork::Pmn::ParallelMiniNet

module Ai4cr
  module NeuralNetwork
    module Pmn
      class ParallelNode
        include JSON::Serializable

        getter locked : Bool

        getter training_config : TrainingConfig
        getter coord : NodeCoord
        getter name : String
        getter width : Int32

        getter mini_net_data_alpha # = MiniNetData.new
        getter mini_net_data_beta  # = MiniNetData.new
        getter alpha_is_current : Bool = true

        getter height_set : HeightSet
        getter height_set_indexes : HeightSetIndexes
        getter height : Int32 = 0
        getter height_with_bias : Int32 = 0

        getter errors : ValidationErrorMessages

        def mini_net_previous
          !alpha_is_current ? mini_net_data_alpha : mini_net_data_beta
        end

        def mini_net_current
          alpha_is_current ? mini_net_data_alpha : mini_net_data_beta
        end

        def initialize(
          @training_config = TrainingConfig.new,
          @coord = NodeCoord.new,
          @name = "",
          @width = 0
        )
          @locked = false

          @errors = ValidationErrorMessages.new

          @height_set = HeightSet.new
          @height_set_indexes = HeightSetIndexes.new
          upsert_height(from_coord: [0], height: 1) if bias_enabled
          reset_height_set_indexes
          validate

          @mini_net_data_alpha = MiniNetData.new(
            node: self,
            name: name + "(alpha)"
          )
          @mini_net_data_beta = MiniNetData.new(
            node: self,
            name: name + "(alpha)"
          )
        end

        def validate
          @errors = ValidationErrorMessages.new
          if height < 1
            @errors["height"] = "Must be positive"
          end
          if width < 1
            @errors["width"] = "Must be positive"
          end
        end

        def valid? : Bool
          @errors.empty?
        end

        def lock
          reset_height_set_indexes
          validate
          @locked = valid?
        end

        def upsert_height(from_coord : NodeCoord, height : Int32)
          @height_set[from_coord] = height
          # reset_height_set_indexes
        end

        def reset_height_set_indexes
          h_from = 0
          @height_set_indexes = Hash(NodeCoord, Array(Int32)).new
          @height_set.each do |key, h_size|
            h_to = h_from + h_size - 1
            @height_set_indexes[key] = (h_from..h_to).to_a
            h_from += h_size
          end
          reset_height
          @height_set_indexes
        end

        def bias_enabled
          training_config.bias_enabled
        end

        def reset_height
          @height = height_set_indexes.values.flatten.size
          @height_with_bias = @height + (bias_enabled ? 1 : 0)
        end

        def height
          @height
        end

        def height_with_bias
          @height_with_bias
        end

        def width
          @width
        end
      end
    end
  end
end
