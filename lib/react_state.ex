defmodule ESReact.State do
    @agent_name :state

    def s() do
        Agent.get(@agent_name, fn(state)-> state end)
    end

    def sg(key) do
        Agent.get(@agent_name, fn(state)-> Map.get(state, key) end)
    end

    def sp(key, value, render \\ true) do
        {oldState, newState} = Agent.get_and_update(@agent_name, fn(state)-> 
            newState = Map.put(state, key, value); {{state, newState}, newState}
        end)
        if render do
            srender(oldState, newState)
        end
    end

    def sm(map, render \\ true) do
        {oldState, newState} = Agent.get_and_update(@agent_name, fn(state)-> 
            newState = Map.merge(state, map); {{state, newState}, newState} 
        end)
        if render do
            srender(oldState, newState)
        end
    end

    def srender(oldState, newState) when oldState == newState, do: nil
    def srender(oldState, newState) do
        root_render = Map.get(newState, :esreact_render_func)
        root_render.(oldState, newState)
    end

    def first_render() do
        state = Agent.get(@agent_name, &(&1))
        srender(%{}, state)
    end

    #@spec init(number) :: map()
    def init(root_render, initial_map) do
        Agent.start(fn-> initial_map end, [name: @agent_name])
        sm(%{esreact_render_func: root_render}, false)
    end
end