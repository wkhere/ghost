defmodule Ghost.Mixfile do
  use Mix.Project

  def project do
    [ app: :ghost,
      version: "0.0.3",
      elixir: "~> 1.0.2",
      deps: deps,
      escript:
        [main_module: Ghost.Server,
         name: :ghostd,
         #embed_elixir: true,
         escript_emu_args: "%%! -noinput\n"
        ]
    ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:httpoison, :jsx] ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [ { :httpoison, "~> 0.5.0" },
      { :jsx, "~> 2.0.0" },
    ]
  end
end
