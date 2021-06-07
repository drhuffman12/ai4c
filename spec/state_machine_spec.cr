require "./spectator_helper"

# TODO: extract to a separate shard

Spectator.describe SimpleStateMachine::StateMachine do
  context "with all defaults used (i.e.: no params specified)" do
    let(state_machine) { SimpleStateMachine::StateMachine.new }

    let(states_expected) { SimpleStateMachine::StateMachine::DEFAULT_STATES }
    let(state_current_expected) { SimpleStateMachine::StateMachine::STATE_NEW }
    let(state_change_attempts_expected) {
      [{forced: true, state_changed: true, state_from: :new, state_to: :new}]
    }
    let(allowed_paths_expected) {
      {
        :new       => [:init, :error, :reset],
        :init      => [:ready, :error, :reset],
        :ready     => [:start, :error, :reset],
        :start     => [:running, :error, :reset],
        :running   => [:success, :error, :reset],
        :success   => [:done, :error, :reset],
        :done      => [:ready, :error, :reset],
        :error     => [:stopped, :error, :reset],
        :stopped   => [:reset, :error, :reset],
        :reset     => [:resetting, :error, :reset],
        :resetting => [:ready, :error, :reset],
      }
    }

    describe "#initialize" do
      it "does not crash" do
        expect {
          SimpleStateMachine::StateMachine.new
        }.not_to raise_error
      end

      it "starts with expected states" do
        expect(state_machine.states).to eq(states_expected)
      end

      it "starts with expected state_current" do
        expect(state_machine.state_current).to eq(state_current_expected)
      end

      it "starts with expected state_change_attempts" do
        expect(state_machine.state_change_attempts).to eq(state_change_attempts_expected)
      end

      it "starts with expected allowed_paths" do
        expect(state_machine.allowed_paths).to eq(allowed_paths_expected)
      end
    end

    describe "#init_paths" do
      it "DEBUG" do
        p! "#init_paths"
        p! state_machine
        expect(state_machine).not_to be_nil
      end

      it "does not crash" do
        state_machine = SimpleStateMachine::StateMachine.new
        expect {
          state_machine.init_paths
        }.not_to raise_error
      end
    end

    # describe "#next" do
    #   it "DEBUG" do
    #     p! "#next"
    #     p! state_machine
    #     expect(state_machine).not_to be_nil
    #   end

    #   it "does not crash" do
    #     state_machine = SimpleStateMachine::StateMachine.new
    #     state_machine.init_paths
    #     expect {
    #       state_machine.next
    #     }.not_to raise_error # (SimpleStateMachine::StateFromException)
    #   end
    #   it "By default, it returns the time and current_state" do
    #     state_before = state_machine.state_current.clone
    #     p! state_before
    #     state_machine.next
    #     state_after = state_machine.state_current.clone
    #     p! state_after

    #     puts
    #     p! "#next .. By default, it returns the time and current_state"
    #     puts
    #     p! state_machine
    #     puts
    #     p! state_machine.state_change_attempts
    #     puts

    #     expect(state_before).to eq(SimpleStateMachine::StateMachine::STATE_NEW)
    #     expect(state_after).to eq(SimpleStateMachine::StateMachine::STATE_INIT)
    #   end

    #   it "twice" do
    #     state_before = state_machine.state_current
    #     p! state_before
    #     state_machine.next
    #     state_mid = state_machine.state_current
    #     state_machine.next
    #     state_after = state_machine.state_current
    #     p! state_after
    #     expect(state_before).to eq(SimpleStateMachine::StateMachine::STATE_NEW)
    #     expect(state_mid).to eq(SimpleStateMachine::StateMachine::STATE_INIT)
    #     expect(state_after).to eq(SimpleStateMachine::StateMachine::STATE_READY)
    #   end
    # end

    describe "#to_json" do
      # let(obj_to_json_expected) {
      #   {
      #     "states": [
      #       "new",
      #       "init",
      #       "ready",
      #       "start",
      #       "running",
      #       "error",
      #       "stopped",
      #       "reset",
      #       "resetting",
      #       "success",
      #       "done",
      #     ],
      #     "state_current": "new",
      #     "history_size":  10,
      #     "history":       [
      #       "new",
      #     ],
      #     "allowed_paths": {
      #       "new": [
      #         "init",
      #         "error",
      #         "reset",
      #       ],
      #       "init": [
      #         "ready",
      #         "error",
      #         "reset",
      #       ],
      #       "ready": [
      #         "start",
      #         "error",
      #         "reset",
      #       ],
      #       "start": [
      #         "running",
      #         "error",
      #         "reset",
      #       ],
      #       "running": [
      #         "success",
      #         "error",
      #         "reset",
      #       ],
      #       "success": [
      #         "done",
      #         "error",
      #         "reset",
      #       ],
      #       "done": [
      #         "ready",
      #         "error",
      #         "reset",
      #       ],
      #       "error": [
      #         "stopped",
      #         "error",
      #         "reset",
      #       ],
      #       "stopped": [
      #         "reset",
      #         "error",
      #         "reset",
      #       ],
      #       "reset": [
      #         "resetting",
      #         "error",
      #         "reset",
      #       ],
      #       "resetting": [
      #         "ready",
      #         "error",
      #         "reset",
      #       ],
      #     },
      #   }.to_json
      # }
      context "returns json with expected keys" do
        let(json_expected) {
          # TODO: Remove this
          <<-JSON
          {"states":["new","init","ready","start","running","error","stopped","reset","resetting","success","done"],"state_current":"new","history_size":10,"allowed_paths":{"new":["init","error","reset"],"init":["ready","error","reset"],"ready":["start","error","reset"],"start":["running","error","reset"],"running":["success","error","reset"],"success":["done","error","reset"],"done":["ready","error","reset"],"error":["stopped","error","reset"],"stopped":["reset","error","reset"],"reset":["resetting","error","reset"],"resetting":["ready","error","reset"]},"state_change_attempts":[{"forced":true,"state_changed":true,"state_from":"new","state_to":"new"}]}
          JSON
        }
        it "returns expected json" do
          puts "state_machine.to_json:"
          puts state_machine.to_json

          expect(state_machine.to_json).to eq(json_expected)
        end

        let(json_data) { JSON.parse(state_machine.to_json) }

        let(json_expected_states) {
          ["new", "init", "ready", "start", "running", "error", "stopped", "reset", "resetting", "success", "done"]
        }
        it "states" do
          expect(json_data["states"]).to eq(json_expected_states)
        end

        let(json_expected_state_current) { "new" }
        it "state_current" do
          expect(json_data["state_current"]).to eq(json_expected_state_current)
        end

        let(json_expected_history_size) { 10 }
        it "history_size" do
          expect(json_data["history_size"]).to eq(json_expected_history_size)
        end

        let(json_expected_allowed_paths) {
          {"new" => ["init", "error", "reset"], "init" => ["ready", "error", "reset"], "ready" => ["start", "error", "reset"], "start" => ["running", "error", "reset"], "running" => ["success", "error", "reset"], "success" => ["done", "error", "reset"], "done" => ["ready", "error", "reset"], "error" => ["stopped", "error", "reset"], "stopped" => ["reset", "error", "reset"], "reset" => ["resetting", "error", "reset"], "resetting" => ["ready", "error", "reset"]}
        }
        it "allowed_paths" do
          expect(json_data["allowed_paths"]).to eq(json_expected_allowed_paths)
        end

        let(json_expected_state_change_attempts) {
          [{"forced" => true, "state_changed" => true, "state_from" => "new", "state_to" => "new"}]
        }
        it "state_change_attempts" do
          expect(json_data["state_change_attempts"]).to eq(json_expected_state_change_attempts)
        end
      end
      # context "returns json with expected value(s) for key" do
      #   it ":foo" do
      #     expect(state_machine.to_json).to eq(obj_to_json_expected)
      #   end
      # end
    end
  end

  context "with custom states specified" do
    let(state0) { :off }
    let(state1) { :red }
    let(state2) { :green }
    let(state3) { :blue }
    let(states) {
      [state0, state1, state2, state3]
    }

    let(state_machine) { SimpleStateMachine::StateMachine.new(states: states) }

    describe "#initialize" do
      it "does not crash" do
        expect {
          SimpleStateMachine::StateMachine.new
        }.not_to raise_error
      end
    end

    describe "#next" do
      context "when no paths set" do
        it "raises" do
          expect {
            state_machine.next
          }.not_to raise_error # (SimpleStateMachine::StateNextMissingException, "Paths not defined.")
        end
      end
      # it "does not crash" do
      #   expect {
      #     state_machine.next
      #   }.not_to raise_error
      # end
      # it "By default, it returns the time and current_state" do
      #   # expect(Time).to receive(:utc)
      #   # expect(state_machine).to receive(:goto)
      #   state_before = state_machine.state_current
      #   p! state_before
      #   state_machine.next
      #   state_after = state_machine.state_current
      #   p! state_after
      #   expect(state_before).to eq(state0)
      #   expect(state_after).to eq(state1)
      # end
    end

    # describe "#to_json" do
    #   let(obj_to_json_expected) {
    #     {
    #       "states": [
    #         state0,
    #         state1,
    #         state2,
    #         state3,
    #       ],
    #       "state_current": state0,
    #       "history_size":  10,
    #       "history":       [
    #         state0,
    #       ],
    #       "allowed_paths": {
    #         state0 => [
    #           state1,
    #           state2,
    #           state3,
    #         ],
    #         state1 => [
    #           state0,
    #           state2,
    #           state3,
    #         ],
    #         state2 => [
    #           state0,
    #           state1,
    #           state3,
    #         ],
    #         state3 => [
    #           state0,
    #           state1,
    #           state2,
    #         ],
    #       },
    #     }.to_json
    #   }
    #   it "returns expected json" do
    #     expect(state_machine.to_json).to eq(obj_to_json_expected)
    #   end
    # end
  end
end
