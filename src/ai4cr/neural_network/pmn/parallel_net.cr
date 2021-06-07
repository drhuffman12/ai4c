# parallel_mini_net.cr

# require "./../cmn/mini_net"
# require "./concerns/*.cr"

# Ai4cr::NeuralNetwork::Pmn::ParallelMiniNet

module Ai4cr
  module NeuralNetwork
    module Pmn
      class ParallelNet
        include JSON::Serializable

        getter name : String

        getter training_config : TrainingConfig
        getter node_map : NodeMap
        getter locked : Bool

        getter node_connections_via_from : NodeConnections
        getter node_connections_via_to : NodeConnections

        getter external_input_sizes : IoSizes
        getter external_output_sizes : IoSizes

        getter external_input_set : IoSet
        getter external_output_set : IoSet

        def initialize(
          @training_config = TrainingConfig.new,
          @name : String = "",
          @external_input_sizes = IoSizes.new,
          @external_output_sizes = IoSizes.new,
          @internal_hidden_output_size_default = 10
        )
          @locked = false

          @node_map = NodeMap.new
          @node_connections_via_from = NodeConnections.new
          @node_connections_via_to = NodeConnections.new
          @external_input_set = IoSet.new
          @external_output_set = IoSet.new
        end

        def add_node(coord = NodeCoord.new, name = "", width = 0)
          raise PmnNetLockedException.new if @locked

          node = ParallelNode.new(
            training_config: training_config,
            coord: coord,
            name: name,
            width: width
          )
          @node_map[coord] = node
        end

        def add_connection!(
          from_coord : NodeCoord, to_coord : Node_coord,
          auto_add_node = true, auto_replace_connection = false,
          from_name = "", from_width = 0,
          to_name = "", to_width = 0
        )
          raise PmnNetLockedException.new if @locked

          # Check if node coord is defined in the map (and add if 'auto_add_node' is 'true')
          if !@node_map.keys.include?(from_coord)
            raise PmnNodeMissingException.new("No node at from_coord: #{from_coord}") unless auto_add_node
            add_node(coord: from_coord, name: from_name, width: from_width)
          end
          if !@node_map.keys.include?(to_coord)
            raise PmnNodeMissingException.new("No node at to_coord: #{to_coord}") unless auto_add_node
            add_node(coord: to_coord, name: to_name, width: to_width)
          end

          # Check for existing connection (and replace if 'auto_replace_connection' is 'true')
          if node_connections_via_from.keys.include?(from_coord) &&
             node_connections_via_from[from_coord].include?(to_coord) &&
             !auto_replace_connection
            raise PmnConnectionAlreadyExistsException.new(
              "Connection exists re (from_coord: #{from_coord}, to_coord: #{to_coord})"
            )
          end
          if node_connections_via_from.keys.include?(to_coord) &&
             node_connections_via_to[to_coord].include?(from_coord) &&
             !auto_replace_connection
            raise PmnConnectionAlreadyExistsException.new(
              "Connection exists re (to_coord: #{to_coord}, from_coord: #{from_coord})"
            )
          end

          # Connect the nodes
          add_connection(from_coord: from_coord, to_coord: to_coord)
        end

        def lock
          node_map.each do |coord, node|
            node.lock
          rescue err : Exception
            raise "Errored at coord: #{coord} with error (class: #{err.class}, message #{err.message})"
          end
          @locked = true
        end

        private def add_connection(from_coord : NodeCoord, to_coord : Node_coord)
          to_node = node_map[to_coord]
          from_node = node_map[from_coord]
          to_node.upsert_height(from_coord, from_node.width)
          @node_connections_via_from[from_coord] << to_coord
          @node_connections_via_to[to_coord] << from_coord
        end

        # def remove_connection(
        # end

        # def move_node_to(from_coord, to_coord)
        #   raise PmnNetLockedException.new if @locked

        #   node = node_map[coord]
        #   node.move_to(to_coord)
        # end
      end
    end
  end
end
