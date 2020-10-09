# plug.kak

plug.kak is a plugin manager for [Kakoune].

[Kakoune]: https://kakoune.org

Just a thin wrapper around the `require-module` command and `ModuleLoaded` hook
— with Git support — to structure your kakrc.

## Installation

Run the following in your terminal:

``` sh
git clone https://github.com/alexherbo2/plug.kak ~/.config/kak/autoload/plugins/plug
```

## Usage

``` kak
require-module plug

# Let plug.kak manage itself.
plug plug https://github.com/alexherbo2/plug.kak

plug-core %{
  # Tools
  set-option global makecmd 'make -j 8'
  set-option global grepcmd 'rg --column --with-filename'
}

# A module without associated repository.
# Typically, a kak script living in your autoload.
plug-autoload my-module

# A local plugin, relative to your home directory.
plug my-module projects/my-plugin.kak %{
  my-plugin-enable
}

plug prelude https://github.com/alexherbo2/prelude.kak

plug connect https://github.com/alexherbo2/connect.kak %{
  # Modules
  require-module connect-fzf
  require-module connect-broot
  require-module connect-dolphin

  # Environment variables
  set-option global connect_environment %{
    export SHELL=dash
  }
}

# A plugin without module.
plug-old state-save https://gitlab.com/Screwtapello/kakoune-state-save %{
  # Starting
  hook global KakBegin .* %{
    state-save-reg-load colon
    state-save-reg-load pipe
    state-save-reg-load slash
  }

  # Quitting
  hook global KakEnd .* %{
    state-save-reg-save colon
    state-save-reg-save pipe
    state-save-reg-save slash
  }
}
```

Run `plug-install` and define a `plug-upgrade` command:

``` kak
define-command plug-upgrade -docstring 'plug-upgrade' %{
  plug-install
  plug-execute lsp cargo build --release
}
```

## Tips and tricks

### Disable a plugin

Prefix the `plug` command with `nop`:

``` kak
nop plug my-module projects/my-plugin.kak %{
  my-plugin-enable
}
```
