# Catppuccin Mocha — matches Ghostty mantle; cell opacity applies via Ghostty.

from dooit.api.theme import DooitThemeBase
from dooit.ui.api import DooitAPI, subscribe
from dooit.ui.api.events import Startup

MANTLE = "#181825"
CRUST = "#11111b"
SURFACE0 = "#313244"
SURFACE1 = "#45475a"


class GhosttyTheme(DooitThemeBase):
    _name = "ghostty"

    background1 = CRUST
    background2 = MANTLE
    background3 = SURFACE1

    foreground1 = "#a6adc8"
    foreground2 = "#bac2de"
    foreground3 = "#cdd6f4"

    red = "#f38ba8"
    orange = "#fab387"
    yellow = "#f9e2af"
    green = "#a6e3a1"
    blue = "#89b4fa"
    purple = "#b4befe"
    magenta = "#cba6f7"
    cyan = "#89dceb"

    primary = "#89b4fa"
    secondary = "#94e2d5"


GHOSTTY_CSS = """
Screen, Dashboard {
    background: #181825;
}

ModelTree {
    background: #181825;
    border: heavy #45475a;
    border-title-background: #313244;
    border-title-color: #cdd6f4;
}

ModelTree:focus {
    border: heavy #89b4fa;
    border-title-background: #89b4fa;
    border-title-color: #11111b;
}

ModelTree .option-list--option-highlighted,
ModelTree .option-list--option-hover-highlighted {
    background: #313244;
}

ModelTree:focus .option-list--option-highlighted,
ModelTree:focus .option-list--option-hover-highlighted {
    background: #45475a;
}

ModelTree .option-list--option-hover {
    background: #181825;
}

Header {
    background: #181825;
    border: tall #45475a;
}

BarBase {
    background: #181825;
    color: #cdd6f4;
}

SortBar {
    background: #181825;
}
"""


@subscribe(Startup)
def setup(api: DooitAPI, _):
    api.css.set_theme(GhosttyTheme)
    api.css.inject_css(GHOSTTY_CSS)
