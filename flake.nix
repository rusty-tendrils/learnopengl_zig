{
  description = "A Nix-flake-based development environment for opengl with zig and c++";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell.override
          {
            # Override stdenv in order to change compiler:
            # stdenv = pkgs.clangStdenv;
          }
          {
            packages = with pkgs; [
              clang-tools
              cmake
              codespell
              conan
              cppcheck
              doxygen
              gtest
              lcov
              vcpkg
              vcpkg-tool
              zig
              zls
              clang
              glfw-wayland
              #TODO What's pkg-config?
              pkg-config
            ] ++ (if system == "aarch64-darwin" then [ ] else [ gdb ]);

            shellHook = ''
              echo "zig `${pkgs.zig}/bin/zig version`"
              echo "clang `${pkgs.clang}/bin/clang --version`"
            '';
          };
      });
    };
}
