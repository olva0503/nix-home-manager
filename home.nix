{
  config,
  pkgs,
  lib,
  ...
}: let
  ngram = pkgs.fetchurl {
    url = "https://languagetool.org/download/ngram-data/ngrams-en-20150817.zip";
    sha256 = "sha256-EOVIcx2fWBifw2pVP39oVwO+MNoNm7QtH3tb9fi7Iyw="; # Replace with correct hash!
  };
  nixvim = builtins.getFlake "/home/olva/projects/olva-nixvim";

  targetDir = "${config.home.homeDirectory}/data/ngrams/eng";
in {
  # home.file."data/ngrams/1gram-a.gz".source = ngram;
  # home.activation.unpackNgrams = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #   mkdir -p "${targetDir}"
  #   echo "Extracting N-gram archive..."
  #
  #   # Extract only if not already extracted
  #   if [ ! -d "${targetDir}" ]; then
  #       ${pkgs.unzip}/bin/unzip ${ngram} -d "${targetDir}"
  #   else
  #     echo "Archive already extracted."
  #   fi
  # '';
  home.stateVersion = "25.05";
  home.enableNixpkgsReleaseCheck = false;
  home.packages = with pkgs; [
    (writeShellScriptBin "shell scripting" ''
      '')
    vscode-extensions.vadimcn.vscode-lldb
    eza
    lazygit
    gzip
    unzip
    harper
    golangci-lint
    vale
    pkgs.nodePackages.cspell
    write-good
    nixd
    lazysql
    tree-sitter
    (nixvim.lib.makeNixvimWithExtra builtins.currentSystem {})
  ];
  programs = {
    alacritty.enable = true;
    zoxide.enable = true;
    yazi.enable = true;
    bat = {
      enable = true;
      config = {
        theme = "catppuccin";
      };
      themes = {
        catppuccin = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
            sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
          };
          file = "Catppuccin-mocha.tmTheme";
        };
      };
    };
    git = {
      enable = true;
      userEmail = "alkitav@gmail.com";
      userName = "Oleksii";
    };
    bash = {
      enable = true;
      initExtra = ''
        [[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
        export PKG_CONFIG_PATH="/run/current-system/sw/lib/pkgconfig";
        alias vi='nvim'
        alias ls='exa'
        # sudo chown olva:users /mnt/wsl/rancher-desktop/run/docker.sock
        eval "$(atuin init bash)"
      '';
    };
    tmux = {
      enable = true;
      baseIndex = 1;
      plugins = with pkgs; [
        tmuxPlugins.cpu
        tmuxPlugins.resurrect
        tmuxPlugins.catppuccin
        tmuxPlugins.yank
        tmuxPlugins.vim-tmux-navigator
      ];
      extraConfig = ''

        unbind C-b
        set -g prefix C-Space
        bind C-Space send-prefix

        # Vim style pane selection
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        set-option -sa terminal-overrides ",xterm*:Tc"
        set -g mouse on
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows off

        # set vi-mode
        set-window-option -g mode-keys vi
        # keybindings
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        # Use Lavender for inactive windows
        set -g window-status-format " #[fg=#b4befe]#I:#W#[default] "

        # Use Mauve for the active window
        set -g window-status-current-format " #[fg=#cba6f7,bold]#I:#W#[default] "
      '';
    };
  };
}
