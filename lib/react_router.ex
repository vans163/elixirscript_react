defmodule ESReact.Router do

    #Utility function
    def nav_href(path), do: navigate_href(path)
    def nav_href!(path), do: navigate_href(path)
    def navigate_href(path) do
        onClick = fn(o,_)-> o.preventDefault(); nav(path) end
        %{href: path, onClick: onClick}
    end


    def nav(path), do: navigate(path)
    def nav!(path), do: navigate(path)
    def navigate(path) do
        newPath = navigate_1(path)
        ESReact.FFI.History.pushState(nil, nil, newPath)
    end

    def navigate_1(path, render \\ true) do        
        state = ESReact.State.s()
        route_func = Map.get(state, :esreact_route_func)

        newPath = route_func.(path, state)
        ESReact.State.sp(:esreact_route, newPath, render)
        newPath
    end

    def first_load() do
        ESReact.FFI.Window.addEventListener("popstate", fn(_)->
            path = ESReact.FFI.Location.pathname()
            path = navigate_1(path)
            ESReact.FFI.History.replaceState(nil, nil, path)
        end)
        newPath = navigate_1(ESReact.FFI.Location.pathname(), false)
        ESReact.FFI.History.replaceState(nil, nil, newPath)
    end

    def init(router_func) do
        ESReact.State.sp(:esreact_route_func, router_func, false)
        first_load()
    end
end