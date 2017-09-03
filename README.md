This project is very much a work in progress and things may change quickly and suddenly.
If you decide to use this, I recommend tagging a commit hash to prevent your project from 
breaking in the future.  
  
Detail:  
  
This is a utility wrapper around React for use with Elixirscript.  It takes care of the 
few moving parts required to get React working smoothly.  
  
This library assumes you use React in a certain way.  The library assumes you use stateless 
components and a monolithic global root state.  The monolithic state is a simplicty
optimization for now, which can probably be lifted in the future.  
  
To use elixirscript_react you would need a browser that supports:  
  
React 15+ (the version that seperated react into React, ReactDOM and ReactDOMServer)  
History API (If you use routing)  
You need module support for ES6 or a transcompiler since elixirscript outputs ES6.  
  
Take note! (If you use State if/and Router)  
  
ESReact.State initial state MUST be a map  
  
Using ESReact.State places a unique atom key into the state called  
```
:esreact_render_func, this key holds the render callback function
```
  

ESReact.Router depends on ESReact.State, you cannot use the router
without using ESReact.State  
  
using ESReact.Router places unique atom keys into the state called  
```
:esreact_route_func, this key holds the route callback function
```
```
:esreact_route, this key holds the the result of the route callback
```
  
  
Here is a basic getting started app for use in Chromium:  
```
Enable ES6 module support 
https://medium.com/dev-channel/es6-modules-in-chrome-canary-m60-ba588dfb8ab7
```

```html
<!DOCTYPE html>
<html>
  <head>
    <link rel="icon" href="data:;base64,iVBORw0KGgo=">
    <meta charset="UTF-8" />
    <title>My First Functional React App!</title>
  </head>
  <body>
    <div id="app"></div>

    <script src="http://cdn.jsdelivr.net/react/15.5.4/react.js"></script>
    <script src="http://cdn.jsdelivr.net/react/15.5.4/react-dom.js"></script>
    <script src="http://cdn.jsdelivr.net/react/15.5.4/react-dom-server.js"></script>

    <script type="module">
        import Elixir from './app.js'
        Elixir.start(Elixir.MyFunctionalReactApp);
    </script>
  </body>
</html>
```



```elixir
defmodule MyFunctionalReactApp
    import ESReact, only: [react: 1]
    import ESReact.State, only: [sg: 1, sp: 2, sm: 1]
    import ESReact.Router, only: [nav_href!: 1]
    alias ESReact.FFI.ReactDOM, as: ReactDOM

    def menuView(_,n) do
        [:div,
            [:a, nav_href!("/"), "Home"],
            if n.logged_in do [:a, nav_href!("/user"), "User"] end,
        ]
    end

    def userView(_,_) do
        [:div,
            [:p, "The User View"],
            [:p, ">> Insert Usable Sortable Filterable Table Here"],
        ]
    end

    def loginView(_,n) do
        loginAction = fn(user, pass)->
            :ajax!
        end)
        [:div,
            [:p, "Login"],
            [:span, "user"],
            [:input, %{onBlur: fn(e,_)-> sp(:username, e.target.value) end}],
            [:br],

            [:span, "pass"],
            [:input, %{onBlur: fn(e,_)-> sp(:password, e.target.value) end}],
            [:br],

            [:button, %{onClick: fn(_,_)-> loginAction.(n[:username], n[:password]) end}, "Login"]
        ]
    end

    def homeView(_,_) do
        #DOM Injection example

        options = [
            [:option, "Pear"],
            [:option, "Banana"],
            [:option, "Dog"],
        ]

        [:div,
            [:p, "The Home View"],
            [:select, 
                [:option, "Apple"],
                ]++ options ++[
            ]
        ]
    end

    def appView(o,n) do
        route = d.esreact_route
        page = case route do
            "/user" -> userView(o,n)
            "/login" -> loginView(o,n)
            _ -> homeView(o,n)
        end

        [:div,
            menuView(o,n),
            page
        ]
    end

    def root_route("/user"=p, %{logged_in: true}), do: p
    def root_route(_, %{logged_in: true}), do: "/"
    def root_route(_, _), do: "/login"

    def root_render(o, n) do
        rootEle = react(appView(o,n))
        ReactDOM.render(rootEle, Document.getElementById("app"))
    end

    def start(_, _) do
        :window.console.log("MyFunctionalReactApp Started!")

        initial_state = %{logged_in: true}

        ESReact.State.init(&root_render/2, initial_state)
        ESReact.Router.init(&root_route/2)
        ESReact.State.first_render()
    end
end
```



```elixir
defmodule MyFunctionalReactApp.Mixfile do
    use Mix.Project

    def project, do: [
        app: :my_functional_react_app,
        version: "0.0.1",
        elixir: "~> 1.5",
        build_embedded: Mix.env == :prod,
        start_permanent: Mix.env == :prod,
        deps: deps(),

        compilers: Mix.compilers ++ [:elixir_script],
        elixir_script: elixir_script()
    ]

    def elixir_script, do: [
        input: MyFunctionalReactApp,
        output: "priv/app.js"
    ]

    def application, do: [
    ]

    def deps, do: [
        {:elixir_script, path: "../elixirscript"},
        {:elixirscript_react, path: "../elixirscript_react"}
    ]
end
```