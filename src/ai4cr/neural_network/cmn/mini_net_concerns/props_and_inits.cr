module Ai4cr
  module NeuralNetwork
    module Cmn
      module MiniNetConcerns
        module PropsAndInits
          getter width : Int32, height : Int32
          getter height_considering_bias : Int32
          getter width_indexes : Array(Int32), height_indexes : Array(Int32)

          property inputs_given : Array(Float64), outputs_guessed : Array(Float64)
          property weights : Array(Array(Float64))
          property last_changes : Array(Array(Float64)) # aka previous weights
          property output_errors : Array(Float64)

          property outputs_expected : Array(Float64)

          property input_deltas : Array(Float64), output_deltas : Array(Float64)

          property learning_style : LearningStyle
          property deriv_scale : Float64
          property bias_default : Float64
          property disable_bias : Bool
          property learning_rate : Float64
          property momentum : Float64

          # getter error_stats.distance : Float64
          # getter history_size : Int32
          # getter error_stats.history : Array(Float64)
          # getter error_stats.score : Float64
          getter error_stats : Ai4cr::ErrorStats

          include Ai4cr::BreedParent(self.class)

          # RENAME: error_stats.distance => error_stats.distance
          # RENAME: error_stats.history_size => error_stats.history_size
          # RENAME: error_stats.history => error_stats.history
          # RENAME: error_stats.score => error_stats.score

          def initialize(
            @height, @width,
            @learning_style : LearningStyle = LS_RELU,

            # for Prelu
            # TODO: set deriv_scale based on ?
            # @deriv_scale = 0.1,
            # @deriv_scale = 0.01,
            # @deriv_scale = 0.001,
            @deriv_scale = rand / 2.0,

            disable_bias : Bool? = nil, @bias_default = 1.0,

            learning_rate : Float64? = nil, momentum : Float64? = nil,
            history_size : Int32 = 10,

            name_suffix = ""
          )
            @name = init_name(name_suffix)

            # TODO: switch 'disabled_bias' to 'enabled_bias' and adjust defaulting accordingly
            @disable_bias = disable_bias.nil? ? false : !!disable_bias

            @learning_rate = learning_rate.nil? || learning_rate.as(Float64) <= 0.0 ? rand : learning_rate.as(Float64)
            @momentum = momentum && momentum.as(Float64) > 0.0 ? momentum.as(Float64) : rand

            # init_network:
            @height_considering_bias = @height + (@disable_bias ? 0 : 1)
            @height_indexes = Array.new(@height_considering_bias) { |i| i }

            @inputs_given = Array.new(@height_considering_bias, 0.0)
            @inputs_given[-1] = bias_default unless @disable_bias

            @input_deltas = Array.new(@height_considering_bias, 0.0)

            @width_indexes = Array.new(width) { |i| i }

            @outputs_guessed = Array.new(width, 0.0)
            @outputs_expected = Array.new(width, 0.0)
            @output_deltas = Array.new(width, 0.0)

            # TODO: set weights based on learning_type
            @weights = @height_indexes.map { @width_indexes.map { rand*2 - 1 } }
            # @weights = @height_indexes.map { @width_indexes.map { (rand*2 - 1)*(Math.sqrt(2.0/(height_considering_bias + width))) } }
            # @weights = @height_indexes.map { @width_indexes.map { (rand*2 - 1)*(Math.sqrt(height_considering_bias/2.0)) } }

            @last_changes = Array.new(@height_considering_bias, Array.new(width, 0.0))
            @output_errors = @width_indexes.map { 0.0 }

            # @error_stats.distance = 0.0
            # @error_stats.history_size = (error_stats.history_size < 0 ? 0 : error_stats.history_size)
            # @error_stats.history = Array.new(0, 0.0)
            # @error_stats.score = 0.0
            @error_stats = Ai4cr::ErrorStats.new(history_size)
          end

          def init_network(history_size : Int32 = 10)
            # init_network:
            @height_considering_bias = @height + (@disable_bias ? 0 : 1)
            @height_indexes = Array.new(@height_considering_bias) { |i| i }

            @inputs_given = Array.new(@height_considering_bias, 0.0)
            @inputs_given[-1] = bias_default unless @disable_bias
            @input_deltas = Array.new(@height_considering_bias, 0.0)

            @width_indexes = Array.new(width) { |i| i }

            @outputs_guessed = Array.new(width, 0.0)
            @outputs_expected = Array.new(width, 0.0)
            @output_deltas = Array.new(width, 0.0)

            # Weight initialization (https://medium.com/datadriveninvestor/deep-learning-best-practices-activation-functions-weight-initialization-methods-part-1-c235ff976ed)
            # * Xavier initialization mostly used with tanh and logistic activation function
            # * He-initialization mostly used with ReLU or it’s variants — Leaky ReLU.
            @weights = @height_indexes.map { @width_indexes.map { rand*2 - 1 } }
            # @weights = Array.new(height_considering_bias) { Array.new(width) { (rand*2 - 1) } }
            # @weights = @height_indexes.map { @width_indexes.map { (rand*2 - 1)*(Math.sqrt(2.0/(height_considering_bias + width))) } }
            # @weights = @height_indexes.map { @width_indexes.map { (rand*2 - 1)*(Math.sqrt(height_considering_bias/2.0)) } }

            @last_changes = Array.new(@height_considering_bias, Array.new(width, 0.0))
            @output_errors = @width_indexes.map { 0.0 }

            # @error_stats.distance = 0.0
            # @error_stats.history_size = (error_stats.history_size < 0 ? 0 : error_stats.history_size)
            # @error_stats.history = Array.new(0, 0.0)
            # @error_stats.score = 0.0
            @error_stats = Ai4cr::ErrorStats.new(history_size)
          end

          def structure
            [height, width]
          end
        end
      end
    end
  end
end
