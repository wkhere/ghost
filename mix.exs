defmodule Ghost.Mixfile do
  use Mix.Project

  def project do
    [ app: :ghost,
      version: "0.0.1",
      elixir: "~> 0.12.3",
      deps: deps,
      escript_main_module: Ghost.Server,
      escript_name: :ghostd,
      escript_emu_args: "%%! -noinput\n"
    ]
  end

  # Configuration for the OTP application
  def application do
    [ applications: [:httpotion, :jsx] ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # To specify particular versions, regardless of the tag, do:
  # { :barbat, "~> 0.1", github: "elixir-lang/barbat" }
  defp deps do
    [ { :httpotion, github: "myfreeweb/httpotion" },
      { :jsx,       github: "talentdeficit/jsx" },
    ]
  end
end
