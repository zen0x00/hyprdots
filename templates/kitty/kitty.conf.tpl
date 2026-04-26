# BEGIN_KITTY_FONTS
font_family      family="JetBrainsMono Nerd Font Mono"
bold_font        auto
italic_font      auto
bold_italic_font auto
# END_KITTY_FONTS

font_size 13.0

foreground {{ semantic.fg }}
background {{ semantic.bg }}
selection_foreground {{ semantic.bg }}
selection_background {{ semantic.accent }}
url_color {{ semantic.link }}

color0 {{ palette.black }}
color1 {{ palette.red_dark }}
color2 {{ palette.green_dark }}
color3 {{ palette.yellow_dark }}
color4 {{ palette.blue_dark }}
color5 {{ palette.purple_dark }}
color6 {{ palette.teal_dark }}
color7 {{ palette.grey_150 }}
color8 {{ palette.grey_350 }}
color9 {{ palette.red_light }}
color10 {{ palette.green_light }}
color11 {{ palette.yellow_light }}
color12 {{ palette.blue_light }}
color13 {{ palette.purple_light }}
color14 {{ palette.teal_light }}
color15 {{ palette.white }}

cursor {{ semantic.fg }}
cursor_text_color {{ semantic.bg }}
cursor_shape block
cursor_shape_unfocused hollow
cursor_trail 1

detect_urls yes
show_hyperlink_targets no
underline_hyperlinks hover

hide_window_decorations yes

window_padding_width 8 14
single_window_margin_width 0

shell /bin/zsh
