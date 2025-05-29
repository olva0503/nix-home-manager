{
  config,
  pkgs,
  ...
}: let
  nixvim = builtins.getFlake "/home/olva/projects/olva-nixvim";
in {
  home.stateVersion = "25.05";
  home.enableNixpkgsReleaseCheck = false;
  home.packages = with pkgs; [
    (writeShellScriptBin "shell scripting" ''

      echo "done!"
    '')
    vscode-extensions.vadimcn.vscode-lldb
    rustlings
    eza
    lazygit
    (nixvim.lib.makeNixvimWithExtra builtins.currentSystem {})
  ];
  programs = {
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
        alias cat='bat'
        alias vi='nvim'
        alias ls='exa'
        # sudo chown olva:users /mnt/wsl/rancher-desktop/run/docker.sock
        eval "$(atuin init bash)"
      '';
    };
    tmux = {
      enable = true;
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
        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        # set vi-mode
        set-window-option -g mode-keys vi
        # keybindings
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      '';
    };
  };
}
