{ pkgs, ... }:
let
  statuslineScript = pkgs.writeShellApplication {
    name = "statusline-command";
    runtimeInputs = with pkgs; [
      coreutils
      git
      jq
    ];
    text = builtins.readFile ./statusline-command.sh;
  };
in
{
  # Installed at a stable path rather than wired through
  # programs.claude-code.settings, because settings.json is hand-managed here
  # (it carries the API token) and home-manager would replace it with a
  # read-only store symlink. The stable path also keeps the command in
  # settings.json from going stale as the store path changes.
  home.file.".local/bin/statusline-command".source = pkgs.lib.getExe statuslineScript;
}
