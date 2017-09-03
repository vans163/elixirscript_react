defmodule ESReact.FFI do
    defmodule React do
        use ElixirScript.FFI, global: true, name: :React

        defexternal createElement(term)
        defexternal createElement(term, attributes)
        defexternal createElement(term, attributes, children)

        defexternal cloneElement(element)
        defexternal cloneElement(element, attributes)
        defexternal cloneElement(element, attributes, children)

        defexternal isValidElement(object)
    end

    defmodule ReactDOM do
        use ElixirScript.FFI, global: true, name: :ReactDOM

        defexternal render(element, container)
        defexternal render(element, container, callback)

        defexternal unmountComponentAtNode(container)

        defexternal findDOMNode(component)
    end

    defmodule ReactDOMServer do
        use ElixirScript.FFI, global: true, name: :ReactDOMServer

        defexternal renderToString(element)
        defexternal renderToStaticMarkup(element)
    end

    defmodule Window do
        use ElixirScript.FFI, global: true, name: :window

        defexternal addEventListener(event, func)
    end

    defmodule Location do
        use ElixirScript.FFI, global: true, name: :location

        defexternal pathname()
    end

    defmodule History do
        use ElixirScript.FFI, global: true, name: :history

        defexternal pushState(object, title, url)
        defexternal replaceState(object, title, url)
    end
end