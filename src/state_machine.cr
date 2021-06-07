# TODO: extract to a separate shard
module SimpleStateMachine
  class StateException < Exception
  end

  class StateFromException < StateException
  end

  class StateToException < StateException
  end

  class StateNextMissingException < StateException
  end

  class StateMachine
    include JSON::Serializable

    alias State = Symbol
    alias StateList = Array(State)
    alias AllowedPaths = Hash(State, StateList)

    STATE_NEW       = :new
    STATE_INIT      = :init
    STATE_READY     = :ready
    STATE_START     = :start
    STATE_RUNNING   = :running
    STATE_ERROR     = :error
    STATE_STOPPED   = :stopped
    STATE_RESET     = :reset
    STATE_RESETTING = :resetting

    STATE_SUCCESS = :success
    STATE_DONE    = :done

    # Use a typical new/run/success/error/reset state-flow by default
    DEFAULT_STATES = [
      STATE_NEW,

      STATE_INIT,
      STATE_READY,

      STATE_START,
      STATE_RUNNING,

      STATE_ERROR,
      STATE_STOPPED,

      STATE_RESET,
      STATE_RESETTING,

      STATE_SUCCESS,
      STATE_DONE,
    ]

    # alias StateChangedLatest = { state_changed: true, state_from: :some_state, state_to: :other_state }.class
    alias StateChangedAttempt = NamedTuple(forced: Bool, state_changed: Bool, state_from: Symbol, state_to: Symbol)

    getter states : Array(Symbol)
    getter state_current : Symbol
    getter history_size : Int32
    # getter history : Array(Symbol)
    getter allowed_paths : AllowedPaths
    getter state_change_attempts : Array(StateChangedAttempt)

    def initialize(@states : StateList = DEFAULT_STATES, @history_size = 10)
      @state_current = @states.first
      # @history = [@state_current]
      @allowed_paths = AllowedPaths.new
      @state_change_attempts = Array(StateChangedAttempt).new
      init_paths
    end

    def init_paths
      # Feel free to modify in Sub-classes
      @states = DEFAULT_STATES if (@states.empty?)

      if (@states.sort == DEFAULT_STATES.sort)
        # Use a typical new/run/success/error/reset state-flow:

        # 'Happy StateList (w/ first next state as a 'Happy State'):
        add_path(state_from: STATE_NEW, states_to: [STATE_INIT, STATE_ERROR, STATE_RESET], restriced_states: true)
        add_path(state_from: STATE_INIT, states_to: [STATE_READY, STATE_ERROR, STATE_RESET], restriced_states: true)
        add_path(state_from: STATE_READY, states_to: [STATE_START, STATE_ERROR, STATE_RESET], restriced_states: true)
        add_path(state_from: STATE_START, states_to: [STATE_RUNNING, STATE_ERROR, STATE_RESET], restriced_states: true)
        add_path(state_from: STATE_RUNNING, states_to: [STATE_SUCCESS, STATE_ERROR, STATE_RESET], restriced_states: true)

        add_path(state_from: STATE_SUCCESS, states_to: [STATE_DONE, STATE_ERROR, STATE_RESET], restriced_states: true)
        add_path(state_from: STATE_DONE, states_to: [STATE_READY, STATE_ERROR, STATE_RESET], restriced_states: true)

        # Un-Happy Paths (STATE_ERROR)
        add_path(state_from: STATE_ERROR, states_to: [STATE_STOPPED, STATE_ERROR, STATE_RESET], restriced_states: true)
        add_path(state_from: STATE_STOPPED, states_to: [STATE_RESET, STATE_ERROR, STATE_RESET], restriced_states: true)

        # Un-Happy Paths (STATE_RESET)
        add_path(state_from: STATE_RESET, states_to: [STATE_RESETTING, STATE_ERROR, STATE_RESET], restriced_states: true)
        add_path(state_from: STATE_RESETTING, states_to: [STATE_READY, STATE_ERROR, STATE_RESET], restriced_states: true)
      else
        # Use a any-to-any (except self) state-flow:
        @states.map do |state_from|
          states_to = @states - [state_from]

          # @allowed_paths.merge!({state_from => states_to})
          add_path(state_from: state_from, states_to: states_to, restriced_states: false)
        end
      end

      goto(next_state: @allowed_paths.keys.first, forced: true) unless @allowed_paths.keys.empty?
    end

    def add_path(state_from : State, states_to : StateList, restriced_states = false)
      if restriced_states
        raise StateFromException.new("Unexpected state(s) for given 'state_from': #{state_from}; allowed states: #{states}") unless @states.includes?(state_from)
        raise StateToException.new("Unexpected state(s) for given 'states_to': #{states_to}; allowed states: #{states}") unless (states_to - @states).empty?

        @allowed_paths.merge!({state_from => states_to})
      else
        @states << state_from
        states_to.each { |k| @states << k }
        @states.uniq!

        @allowed_paths.merge!({state_from => states_to})
      end
    end

    def allowed_next_states
      allowed_paths[@state_current]
    end

    def any_allowed_next_states
      !allowed_next_states.empty?
    end

    def allowed_paths_undefined?(at_state : State)
      @allowed_paths.keys.includes?(at_state)
    end

    def allowed_paths_empty?(at_state : State)
      allowed_paths_undefined?(at_state) || @allowed_paths[at_state].empty?
    end

    def next
      # raise StateNextMissingException.new("Paths not defined.") if allowed_paths_undefined?(@state_current)
      # raise StateNextMissingException.new("Paths missing.") if allowed_paths_empty?(@state_current)
      if allowed_paths_undefined?(@state_current) || allowed_paths_empty?(@state_current)
        @state_change_attempts << {forced: false, state_changed: false, state_from: @state_current, state_to: @state_current}
      else
        goto(@allowed_paths[@state_current].first)
      end
    end

    def append_state_change_attempts(attempted)
      @state_change_attempts << attempted
      @state_change_attempts = @state_change_attempts[0..history_size - 1] if @state_change_attempts.size > history_size
    end

    def goto(next_state : Symbol, forced = false)
      if forced
        state_from = @state_current.clone
        state_to = next_state
        @state_current = state_to
        callbacks_for(@state_current)
        append_state_change_attempts({forced: true, state_changed: true, state_from: state_from, state_to: state_to})
      else
        state_from = @state_current.clone
        state_to = next_state
        @state_current = state_to
        succeded = callbacks_for(@state_current)
        @state_current = state_from unless succeded
        append_state_change_attempts({forced: false, state_changed: succeded, state_from: state_from, state_to: state_to})
      end

      # state_changed = false
      # state_before = @state_current

      # @state_current = if allowed_next_states.includes?(next_state)
      #                    @history << @state_current
      #                    @history.pop if @history.size > @history_size
      #                    next_state
      #                  else
      #                    @state_current
      #                  end
      # state_changed = callbacks_for(@state_current)
      # state_after = @state_current
      # @state_change_attempts = { forced: false, state_changed: state_changed, state_from: state_before, state_to: state_after }
    end

    def callbacks_for(when_state)
      # Sub-class and replace below with your per-state call-backs
      puts "callbacks_for(:#{when_state}) @ #{Time.utc}"
      true # if callbacks succeeded
    end
  end
end
