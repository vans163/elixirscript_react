defmodule ESReact.Mixfile do
    use Mix.Project

    def project, do: [
        app: :elixirscript_react,
        version: "0.0.1",
        elixir: "~> 1.5",
        build_embedded: Mix.env == :prod,
        start_permanent: Mix.env == :prod,
        deps: deps()
    ]

    def application, do: [
    ]

    def deps, do: [
        {:elixir_script, git: "https://github.com/elixirscript/elixirscript.git"}
    ]
end
