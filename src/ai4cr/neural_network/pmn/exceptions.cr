module Ai4cr
  module NeuralNetwork
    module Pmn
      class PmnException < Exception
      end

      class PmnNetLockedException < PmnException
      end

      class PmnNetNotLockedException < PmnException
      end

      class PmnNodeMissingException < PmnException
      end

      class PmnConnectionAlreadyExistsException < PmnException
      end
    end
  end
end
