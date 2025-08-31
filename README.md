# honklet

Desktop goose for wayland!

## Installation

### NixOS via Flakes
Add the input to your flake.nix:
```nix
honklet = {
      url = "github:hannahfluch/honklet";
      inputs.nixpkgs.follows = "nixpkgs"; # optional
      inputs.systems.follows = "systems"; # optional
};
```

The package can then be accessed using:
```nix
honklet.packages.${system}.default
```

## Status
This project is under active development. Currently only the default wander state is supported.
