{
  description = "CAD for DIY Display";

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
        run-luacad-script = pkgs.writeScriptBin "run-luacad" ''
          if [ $# -eq 0 ]; then
            echo "Usage: run-luacad <lua-file>"
            exit 1
          fi

          FENNEL_FILE="$1"
          BASE_NAME=''${FENNEL_FILE%.*}

          #if [ ! -d build ]; then
            #mkdir -p build
            #cp -r $\{luacad}/* build
          #fi

          # TODO: Make fennel update


          ${pkgs.luajitPackages.fennel}/bin/fennel -c simple.fnl > simple.lua
          #LUA_PATH="?.lua;build/?.lua;build/?/init.lua" ${pkgs.luajit}/bin/luajit simple.lua
          LUA_PATH="?.lua;${luacad}/?.lua;${luacad}/?/init.lua" ${pkgs.luajit}/bin/luajit simple.lua
          ls simple.scad

          #$\{pkgs.openscad}/bin/openscad -o $BASE_NAME.scad $BASE_NAME.lua
        '';
        luacad-run = run-luacad-script.overrideAttrs (old: {
          buildCommand = ''
            ${old.buildCommand}
             patchShebangs $out'';
        });
      in rec {
        defaultPackage = packages.luacad-run;
        packages.luacad-run = pkgs.symlinkJoin {
          name = "run-luacad";
          paths = [ luacad-run ] ++ my-buildInputs;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild =
            "wrapProgram $out/bin/run-luacad --prefix PATH : $out/bin";
        };
      });
}
