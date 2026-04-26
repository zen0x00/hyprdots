# Copilot Instructions

## Build, test, and validation commands

This repository does not have a package manifest, test suite, or lint target. The useful validation and workflow entrypoints are the theme scripts:

- `python3 bin/zen0x-generate-theme <theme> --dry-run` prints the generated target files without writing them.
- `python3 bin/zen0x-generate-theme <theme>` renders theme-backed outputs into `hypr/modules/40-look-and-feel.conf`, `quickshell/shell.qml`, and `kitty/kitty.conf`.
- `bin/zen0x-apply-theme <theme>` is the end-to-end theme command; it renders files and then runs `bin/zen0x-theme-reload`.
- `bash -n bin/zen0x-theme-reload` is the fastest syntax check for the reload hook after editing it.

There is no single-test command because there is no test runner in this repo.

## High-level architecture

The repository is a dotfiles layout organized around stowable app directories: `hypr/`, `quickshell/`, `kitty/`, and `zsh/` each contain the files that should land inside that app's config directory.

Themes are centralized in `themes/<slug>/colors.toml`. `bin/zen0x-generate-theme` is the only renderer: it loads one TOML theme, substitutes placeholders in `templates/**`, and writes the generated runtime files back into the app directories. `bin/zen0x-apply-theme` is the user-facing entrypoint, and `bin/zen0x-theme-reload` is responsible for applying the results to the live session by reloading Hyprland, restarting Quickshell, and signaling Kitty.

Hyprland is intentionally split into numbered modules under `hypr/modules/`, while `hypr/hyprland.conf` is just the entrypoint that sources those files in order. When a change affects startup, bindings, or programs, edit the appropriate numbered module instead of expanding the top-level file.

Quickshell is centered on `quickshell/shell.qml`, which owns global overlay state and instantiates widgets per screen through `Variants`. Most UI pieces under `quickshell/widgets/` are presentational components. Dynamic system text is fetched by `quickshell/services/PollingCommand.qml`, which wraps shell commands on timers and exposes their latest output to widgets like the status bar and control center.

The theme switcher UI in `quickshell/widgets/ThemeMenu.qml` shells out to `zen0x-apply-theme` in the background. The visible theme list is hard-coded there, so adding a new theme is a two-part change: add `themes/<slug>/colors.toml` and add the matching entry in `ThemeMenu.qml`.

## Key conventions

- Treat `templates/` plus `themes/` as the source of truth for themed surfaces. Do not hand-edit generated color values in `quickshell/shell.qml`, `hypr/modules/40-look-and-feel.conf`, or `kitty/kitty.conf` unless you are also updating the matching template.
- Template placeholders use dotted lookups into the TOML data (for example `{{ semantic.accent }}`), and the renderer only supports one custom filter today: `strip_hash`.
- Keep Hyprland module filenames numbered (`00-`, `01-`, `10-`, etc.). The numeric prefix is meaningful because `hypr/hyprland.conf` sources modules in that order.
- Quickshell state changes are coordinated in `shell.qml` via `toggle*`, `open*`, `close*`, and `closeOverlays()` helpers. New overlays should follow that pattern instead of managing visibility independently inside individual widgets.
- When changing theme application behavior, preserve the current script chain: `ThemeMenu.qml` -> `bin/zen0x-apply-theme` -> `bin/zen0x-generate-theme` + `bin/zen0x-theme-reload`.
