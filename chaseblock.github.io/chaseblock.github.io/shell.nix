{ pkgs ? import <nixpkgs> {} }:
with pkgs;
with stdenv;
let
  gems = bundlerEnv {
    name = "chaseblock.com-bundler-env";
    inherit ruby;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
    gemConfig = {

      /* mini_racer and libv8 don't install right, so we sort of override that */

      mini_racer = attrs: {
        buildInputs = [ pkgs.icu ];
        dontBuild = false;
        NIX_LDFLAGS = "-licui18n";
      };
     
      libv8-node =
        let
          noopScript = pkgs.writeShellScript "noop" "exit 0";
          linkFiles = pkgs.writeShellScript "link-files" ''
            cd ../..

            mkdir -p vendor/v8/${system}/libv8/obj/
            ln -s "${pkgs.nodejs_22.libv8}/lib/libv8.a" "vendor/v8/${system}/libv8/obj/libv8_monolith.a"

            ln -s ${pkgs.nodejs_22.libv8}/include vendor/v8/include

            mkdir -p ext/libv8-node
            echo '--- !ruby/object:Libv8::Node::Location::Vendor {}' >ext/libv8-node/.location.yml
          '';
        in
        attrs: {
          dontBuild = false;
          postPatch = ''
            cp ${noopScript} libexec/build-libv8
            cp ${noopScript} libexec/build-monolith
            cp ${noopScript} libexec/download-node
            cp ${noopScript} libexec/extract-node
            cp ${linkFiles} libexec/inject-libv8
          '';
        };
    };
  };
in pkgs.mkShell {
  nativeBuildInputs = [
    bundix
    ruby
  ];
  buildInputs = [
    gems
  ];
}
