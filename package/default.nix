{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, wrapGAppsHook
, flac
, gnome2
, harfbuzzFull
, nss
, snappy
, xdg-utils
, xorg
, alsa-lib
, atk
, cairo
, cups
, curl
, dbus
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk3
, libX11
, libxcb
, libXScrnSaver
, libXcomposite
, libXcursor
, libXdamage
, libXext
, libXfixes
, libXi
, libXrandr
, libXrender
, libXtst
, libdrm
, libnotify
, libopus
, libpulseaudio
, libuuid
, libxshmfence
, mesa
, nspr
, pango
, systemd
, at-spi2-atk
, at-spi2-core
, pname
, version
, sha256
, cid
, extensions ? []
}:

let
  desktopName = if pname == "yandex-browser-stable" then "yandex-browser" else pname;
  folderName = if pname == "yandex-browser-stable" then "browser" else "browser-beta";
  binName = desktopName;

  extensionJsonScript = id:
    let
      split = lib.splitString ";" id;
      id' = lib.elemAt split 0;
      updateUrl = if lib.length split > 1
                  then lib.elemAt split 1
                  else "https://clients2.google.com/service/update2/crx";
    in
      ''
        cat > $out/opt/yandex/${folderName}/Extensions/${id'}.json <<EOF
        {
          "external_update_url": "${updateUrl}"
        }
        EOF
      '';

  browser = stdenv.mkDerivation rec {
    inherit pname version;

    src = fetchurl {
      url = "https://dweb.link/ipfs/${cid}/${pname}_${version}_amd64.deb";
      # url = "http://repo.yandex.ru/yandex-browser/deb/pool/main/y/${pname}/${pname}_${version}_amd64.deb";
      sha256 = sha256;
    };

    nativeBuildInputs = [
      autoPatchelfHook
      wrapGAppsHook
    ];

    buildInputs = [
      flac
      harfbuzzFull
      nss
      snappy
      xdg-utils
      xorg.libxkbfile
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      curl
      dbus
      expat
      fontconfig.lib
      freetype
      gdk-pixbuf
      glib
      gnome2.GConf
      gtk3
      libX11
      libXScrnSaver
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libXrandr
      libXrender
      libXtst
      libdrm
      libnotify
      libopus
      libuuid
      libxcb
      libxshmfence
      mesa
      nspr
      nss
      pango
      stdenv.cc.cc.lib
    ];

    unpackPhase = ''
      mkdir $TMP/ya/ $out/bin/ -p
      ar vx $src
      tar --no-overwrite-dir -xvf data.tar.xz -C $TMP/ya/
    '';

    installPhase = ''
      set +x
      set +e
      cp $TMP/ya/{usr/share,opt} $out/ -R
      substituteInPlace $out/share/applications/${desktopName}.desktop --replace /usr/ $out/
      ln -sf $out/opt/yandex/${folderName}/yandex_browser $out/bin/${binName}
      mkdir -p $out/opt/yandex/${folderName}/Extensions
      ${lib.concatMapStringsSep "\n" extensionJsonScript extensions}
    '';

    runtimeDependencies = map lib.getLib [
      libpulseaudio
      curl
      systemd
    ] ++ buildInputs;

    meta = with lib; {
      description = "Yandex Web Browser";
      homepage = "https://browser.yandex.ru/";
      license = licenses.unfree;
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      # maintainers = with maintainers; [ dan4ik605743 ];
      platforms = [ "x86_64-linux" ];

      knownVulnerabilities = [
        ''
      Trusts a Russian government issued CA certificate for some websites.
      See https://habr.com/en/company/yandex/blog/655185/ (Russian) for details.
      ''
      ];
    };
  };
in browser
