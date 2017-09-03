defmodule ESReact do
    alias ESReact.FFI.React, as: React

    def fix_binary(atom) when is_atom(atom), do: Atom.to_string(atom)
    def fix_binary(list) when is_list(list), do: :unicode.characters_to_binary(list)
    #def fix_binary(int) when is_integer(int), do: :erlang.integer_to_binary(int)
    def fix_binary(int) when is_integer(int), do: int
    def fix_binary(binary) when is_binary(binary), do: binary
    def fix_binary(func) when is_function(func), do: func

    def fix_attributes(proplist) when is_list(proplist), do:
        :lists.map(fn({k,v})-> {fix_binary(k), fix_binary(v)} end, proplist)
    def fix_attributes(map), do:
        :maps.fold(fn(k,v,a)-> :maps.put(fix_binary(k), fix_binary(v),a) end, %{}, map)

    def react_ast({tag, attributes, child}) when not is_list(child) do
        React.createElement(
            tag,
            ElixirScript.JS.map_to_object(attributes, symbols: false),
            child)
    end
    def react_ast({tag, attributes, []}) do
        React.createElement(
            tag,
            ElixirScript.JS.map_to_object(attributes, symbols: false))
    end
    def react_ast({tag, attributes, children}) do
        child_ast = :lists.map(&(react_ast(&1)), children)
        React.createElement(
            tag,
            ElixirScript.JS.map_to_object(attributes, symbols: false),
            child_ast
        )
    end

    def react_dom([]), do: []
    def react_dom([nil|t]), do: react_dom(t)
    def react_dom(dom) do
        [tag|dom] = dom
        tag = fix_binary(tag)

        {attributes, dom} = case dom do
            [] -> {%{},[]}
            [map|rdom] when is_map(map) -> {fix_attributes(map),rdom}
            _ -> {%{},dom}
        end

        case dom do
            [v] when v != nil and (is_atom(v) or is_binary(v) or is_integer(v))->
                v = fix_binary(v)
                {tag,attributes,v}

            children when is_list(children) ->
                children = Enum.filter(children, &(&1!=nil))
                children = :lists.map(&(react_dom(&1)), children)
                {tag,attributes,children}
        end
    end

    def r(dom), do: react(dom)
    def react(dom) do
        dom2 = react_dom(dom)
        react_ast(dom2)
    end
end