provide-module plug %{
  # Internal variables
  declare-option -docstring 'plug list of modules' str-list plug_modules
  declare-option -docstring 'plug list of module name and repository pairs' str-list plug_module_to_repository_map

  # Hooks
  hook -group plug-kak-begin global KakBegin .* %{
    plug-require-modules
  }

  define-command plug -params 2..3 -docstring 'plug <module> <repository> [config]' %{
    set-option -add global plug_modules %arg{1}
    set-option -add global plug_module_to_repository_map %arg{1} %arg{2}
    hook -group plug-module-loaded global ModuleLoaded %arg{1} %arg{3}
  }

  define-command plug-autoload -params 1..2 -docstring 'plug-autoload <module> [config]' %{
    plug %arg{1} '' %arg{2}
  }

  define-command plug-core -params 0..1 -docstring 'plug-core [config]' %{
    evaluate-commands %sh{
      if [ "$kak_config/autoload/core" -ef "$kak_runtime/autoload" ]; then
        echo 'evaluate-commands %arg{1}'
      fi
    }
  }

  define-command plug-require-modules -docstring 'plug-require-modules' %{
    evaluate-commands %sh{
      set -- $kak_opt_plug_modules
      printf 'plug-require-module %s;' "$@"
    }
  }

  define-command -hidden plug-require-module -params 1 -docstring 'plug-require-module <module>' %{
    try %{
      require-module %arg{1}
    }
  }

  # Plugins with no module
  define-command plug-old -params 2..3 -docstring 'plug-old <module> <repository> [config]' %{
    set-option -add global plug_module_to_repository_map %arg{1} %arg{2}
    evaluate-commands %sh{
      if [ -d "$kak_config/autoload/$1" ]; then
        echo 'evaluate-commands %arg{3}'
      fi
    }
  }

  define-command plug-install -docstring 'plug-install' %{
    terminal sh -c %{
      kak_runtime=$1 kak_config=$2; shift 2
      kak_opt_plug_module_to_repository_map=$@

      # plug-core
      if ! [ "$kak_config/autoload/core" -ef "$kak_runtime/autoload" ]; then
        mkdir -p "$kak_config/autoload"
        unlink "$kak_config/autoload/core"
        ln -s "$kak_runtime/autoload" "$kak_config/autoload/core"
      fi

      # plug
      while [ $# -ge 2 ]; do
        module=$1 repository=$2; shift 2

        # plug-autoload has no repository
        if [ -z "$repository" ]; then
          continue
        fi

        module_path=$kak_config/autoload/$module

        # Install
        if ! [ -d "$module_path" ]; then
          (cd; git clone "$repository" "$module_path")

        # Update
        else
          (cd "$module_path"; git pull)

        fi
      done
    } -- %val{runtime} %val{config} %opt{plug_module_to_repository_map}
  }

  define-command plug-execute -params 2.. -shell-script-candidates 'cd "${kak_config}/autoload" && ls -1' -docstring 'plug-execute <module> <command>' %{
    terminal sh -c %{
      kak_config=$1 kak_module=$2; shift 2
      kak_command=$@

      # plug
      cd "$kak_config/autoload/$module"
      "$@"
    } -- %val{config} %arg{@}
  }

  define-command plug-upgrade-example -docstring 'plug-upgrade-example' %{
    info -title plug-upgrade-example %{
      define-command plug-upgrade -docstring 'plug-upgrade' %{
        plug-install
        plug-execute lsp cargo build --release
      }
    }
  }

  alias global plug-upgrade plug-upgrade-example
}
