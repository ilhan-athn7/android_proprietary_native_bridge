## What is this?
- A solution for running arm/arm64 android applications on open source Android on PC projects such as `BlissOS`, `Waydroid` and `Redroid (Remote-Android)`

## How to use?
- Download from [releases](https://github.com/ilhan-athn7/android_proprietary_native_bridge/releases) and install with `Magisk Manager` or `KernelSU`.
  - Android version must match.
  - `libhoudini` is recommended for Intel processor.
  - `libndk` is recommended for Intel and AMD processor.
 
## Building module locally 
<details>
  <summary>For ChromeOS</summary>

- Retrieve recoveries from [chromiumdash](https://chromiumdash.appspot.com/serving-builds) or [cros.tech](https://cros.tech/) website.
- `zork`, `guybrush` or `skyrim` is recommended for AMD processors.
- `brya` is recommended for recent generation Intel processors.
- Use [cros_nb_extract.sh](https://github.com/ilhan-athn7/android_proprietary_native_bridge/blob/main/Scripts/cros_nb_extract.sh) script to build the module.
</details>


<details>
  <summary>For AVD (Android Studio) (Not planned)</summary>

- Similar Projects:
 - [sickcodes/Droid-NDK-Extractor](https://github.com/sickcodes/Droid-NDK-Extractor)
 - [RawPikachu/libndk_translation_Module](https://github.com/RawPikachu/libndk_translation_Module)
</details>


<details>
  <summary>For Windows Subsystem for Android (Outdated - Postponed - Incomplete)</summary>

- Go to [store.rg-adguard](https://store.rg-adguard.net/) website.
- Chose ProductID, paste `9P3395VX91NR` to the textbox and hit the button.
- Download `.msixbundle` from the bottom of results table.
- Use [wsa_nb_extract.sh](https://github.com/ilhan-athn7/android_proprietary_native_bridge/blob/main/Scripts/wsa_nb_extract.sh) script to build the module.
</details>


<details>
  <summary>For Google Play Games for PC (Not planned)</summary>
</details>

## Notes
- If you tried to run Genshin Impact but is stuck on loading, review [this](https://github.com/ilhan-athn7/android_proprietary_native_bridge/blob/main/GI_affinity_workaround) workaround.

### [References](https://github.com/ilhan-athn7/android_proprietary_native_bridge/blob/main/REFERENCES.md)
