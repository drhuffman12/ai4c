module Ai4cr
  module NeuralNetwork
    module Cmn
      module MiniNetConcerns
        module PropsAndInits
          LEARNING_STYLES_DEFAULT = LS_RELU

          def config
            {
              height:          @height,
              width:           @width,
              learning_styles: @learning_styles,

              deriv_scale: @deriv_scale,

              bias_disabled: @bias_disabled,
              bias_default:  @bias_default,

              learning_rate: @learning_rate,
              momentum:      @momentum,
              history_size:  history_size,

              name:              name,
              weight_init_scale: @weight_init_scale,
            }
          end

          def initialize(
            @height = 2, @width = 2,
            @learning_styles : LearningStyle = LEARNING_STYLES_DEFAULT,

            @deriv_scale = Ai4cr::Utils::Rand.rand_excluding(scale: 0.5),

            bias_disabled = false, @bias_default = 1.0,

            learning_rate : Float64? = nil, momentum : Float64? = nil,
            history_size : Int32 = 10,

            name : String? = "",

            @weight_init_scale = 1.0
          )
            # TODO: switch 'bias_disabled' to 'bias_enabled' and adjust defaulting accordingly
            @bias_disabled = bias_disabled

            @learning_rate = learning_rate.nil? || learning_rate.as(Float64) <= 0.0 ? Ai4cr::Utils::Rand.rand_excluding : learning_rate.as(Float64)
            @momentum = momentum && momentum.as(Float64) > 0.0 ? momentum.as(Float64) : Ai4cr::Utils::Rand.rand_excluding

            @name = name.nil? ? "" : name

            init_network

            @error_stats = Ai4cr::ErrorStats.new(history_size)
          end

          def structure
            [height, width]
          end

          def init_network
            init_net_re_structure
            init_net_re_guess
            init_net_re_train
          end
        end
      end
    end
  end
end
