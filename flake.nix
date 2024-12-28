{
  description = "A Nix-flake-based development environment for opengl with zig and c++";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self , nixpkgs ,... }: let
    system = "x86_64-linux";
  in {
    devShells."${system}".default = let
      pkgs = import nixpkgs {
        inherit system;
      };
    in pkgs.mkShell {
      packages = with pkgs; [
        zig
        zls
        clang
        clang-tools
        glfw-wayland
        #TODO What's pkg-config?
        pkg-config
      ];

      shellHook = ''
        echo "zig `${pkgs.zig}/bin/zig version`"
        echo "clang `${pkgs.clang}/bin/clang --version`"
      '';
    };
  };
}