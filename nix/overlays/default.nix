_:

{
  modifications = _: prev: {
    # oelint-adv 9.11 requires a newer parser than the pinned Nixpkgs provides.
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (_: pythonPrev: {
        oelint-parser = pythonPrev.oelint-parser.overridePythonAttrs {
          version = "8.12.3";
          src = prev.fetchFromGitHub {
            owner = "priv-kweihmann";
            repo = "oelint-parser";
            tag = "8.12.3";
            hash = "sha256-8GnbfMX9RedPgvDHkzejkPVSEfhdKAryPRJIT+hNCxk=";
          };
        };
      })
    ];

    oelint-adv = prev.oelint-adv.overridePythonAttrs {
      version = "9.11.2";
      src = prev.fetchFromGitHub {
        owner = "priv-kweihmann";
        repo = "oelint-adv";
        tag = "9.11.2";
        hash = "sha256-iV/AOn8qy9e5z5PLbeZeeMfipKJ3ezOv61SXBT0iLeI=";
      };
    };

    fzf = prev.fzf.overrideAttrs (oa: {
      # https://github.com/NixOS/nixpkgs/pull/226847
      postInstall = oa.postInstall + ''
        substituteInPlace $out/share/fzf/completion.* $out/share/fzf/key-bindings.* \
          --replace "\"fzf\"" "\"$out/bin/fzf\"" \
          --replace "fzf-tmux " "$out/bin/fzf-tmux " \
          --replace "fzf " "$out/bin/fzf "
      '';
    });
  };
}
