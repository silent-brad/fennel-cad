{
  description = "FennelCAD Build Script";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    luacad = {
      url = "https://github.com/ad-si/LuaCAD/archive/refs/heads/main.zip";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, luacad }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        my-buildInputs = with pkgs; [
          luajit
          luajitPackages.fennel
          fennel-ls
          fnlfmt
          openscad
        ];
        luacad-fennel-script = pkgs.writeScriptBin "fnlcad" ''
          if [ $# -eq 0 ]; then
            echo "Usage: run-luacad <lua-file>"
            exit 1
          fi

          FENNEL_FILE="$1"
          BASE_NAME=''${FENNEL_FILE%.*}
          LUA_FILE="$BASE_NAME.lua"

          ${pkgs.luajitPackages.fennel}/bin/fennel -c $FENNEL_FILE > $LUA_FILE
          LUA_PATH="?.lua;${luacad}/?.lua;${luacad}/?/init.lua" ${pkgs.luajit}/bin/luajit $LUA_FILE

          ${pkgs.openscad}/bin/openscad -o $BASE_NAME.stl $BASE_NAME.scad
        '';
      in {
        packages.default = luacad-fennel-script;
        devShells.default = pkgs.mkShell { buildInputs = my-buildInputs; };
      });
}
