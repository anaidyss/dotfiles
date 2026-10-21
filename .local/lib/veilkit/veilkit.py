"""veilkit — shared popup design system (GTK4 + gtk4-layer-shell).

Colors are roles from ~/.config/theme/palette.toml for the current theme, shape comes from [tokens.<theme>].
Components: Panel ([ TITLE ] in the top border), Row (LABEL: value), Meter ([|||||.....]),
ActionButton (with confirmation for dangerous actions), ErrorLine. Popup = layer-shell window + transparent
backdrop: a click outside or Esc closes it, running it again toggles.
No external processes: the menus read data from /proc and /sys themselves.
"""
import os
import sys
import tomllib

# gtk4-layer-shell must be loaded before libwayland-client: re-exec with LD_PRELOAD
_LS_LIB = "/usr/lib64/libgtk4-layer-shell.so.0"
if os.path.exists(_LS_LIB) and "gtk4-layer-shell" not in os.environ.get("LD_PRELOAD", ""):
    os.environ["LD_PRELOAD"] = (_LS_LIB + ":" + os.environ.get("LD_PRELOAD", "")).rstrip(":")
    os.execv(sys.executable, [sys.executable] + sys.argv)

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Gdk", "4.0")
gi.require_version("Gtk4LayerShell", "1.0")
from gi.repository import Gdk, Gio, GLib, Gtk  # noqa: E402
from gi.repository import Gtk4LayerShell as LS  # noqa: E402

CFG = os.path.expanduser("~/.config")


def load_design():
    with open(f"{CFG}/theme/palette.toml", "rb") as f:
        pal = tomllib.load(f)
    themes = pal["themes"]
    try:
        cur = open(f"{CFG}/theme/current").read().strip()
    except OSError:
        cur = themes[0]
    i = themes.index(cur) if cur in themes else 0
    role = lambda n: pal["roles"][n][i]  # noqa: E731
    colors = {
        "ink": role("bg"), "panel": role("bg_panel"), "card": role("bg_card"), "sel": role("bg_sel"),
        "line": role("border"), "frame": role("muted"), "dim": role("dim"), "fg": role("fg"),
        "fg2": role("fg_3"), "accent": role("accent"), "accent2": role("yellow"), "danger": role("red"),
    }
    tok = dict(pal.get("tokens", {}).get(themes[i], {}))
    return themes[i], colors, tok


THEME, C, T = load_design()


def css() -> str:
    r, b, pad, gap = T["radius"], T["border"], T["pad"], T["gap"]
    h = T["control_h"]
    font = f'font-family: "{T["font"]}"; font-size: {T["font_size"]}pt;'
    return f"""
window.veil-backdrop, window.veil-menu {{ background: transparent; }}
* {{ {font} color: {C['fg']}; }}
.panel {{ background: {C['panel']}; border: {b}px solid {C['frame']}; border-radius: {r}px; padding: {pad + 6}px {pad}px {pad}px; }}
.panel-title {{ background: {C['panel']}; color: {C['accent']}; font-weight: 700; padding: 0 6px; margin-left: {pad - 2}px; }}
.key {{ color: {C['dim']}; }}
.val {{ color: {C['fg']}; }}
.val.accent {{ color: {C['accent2']}; }}
.val.danger, .error {{ color: {C['danger']}; }}
.sep {{ background: {C['line']}; min-height: {b}px; }}
.vbtn {{ background: transparent; border: {b}px solid {C['line']}; border-radius: {r}px; min-height: {h - 2}px;
        padding: 0 {pad - 4}px; box-shadow: none; }}
.vbtn:hover {{ background: {C['sel']}; border-color: {C['frame']}; }}
.vbtn:focus {{ background: {C['sel']}; border-color: {C['accent']}; outline: none; }}
.vbtn .hint {{ color: {C['accent']}; }}
.vbtn.danger:focus, .vbtn.danger:hover {{ border-color: {C['danger']}; }}
.vbtn.current label {{ color: {C['accent']}; }}
.vbtn.on {{ border-color: {C['accent']}; }}
.section {{ color: {C['dim']}; padding-top: 4px; }}
scale trough {{ background: {C['line']}; min-height: 6px; border-radius: {r}px; border: none; }}
scale highlight {{ background: {C['accent']}; border-radius: {r}px; border: none; }}
scale slider {{ background: {C['fg']}; min-width: 8px; min-height: 18px; border-radius: {r}px; border: none;
              box-shadow: none; margin: -6px 0; }}
scale:disabled highlight {{ background: {C['dim']}; }}
entry, passwordentry {{ background: {C['ink']}; border: {b}px solid {C['line']}; border-radius: {r}px;
                       min-height: {h - 2}px; padding: 0 8px; box-shadow: none; }}
entry:focus-within, passwordentry:focus-within {{ border-color: {C['accent']}; }}
scrolledwindow {{ background: transparent; }}
.vbtn.armed {{ border-color: {C['danger']}; background: {C['sel']}; }}
.vbtn.armed label {{ color: {C['danger']}; }}
"""


def esc(s) -> str:
    return GLib.markup_escape_text(str(s))


def span(text, color=None, bold=False) -> str:
    a = (f' foreground="{color}"' if color else "") + (' weight="bold"' if bold else "")
    return f"<span{a}>{esc(text)}</span>"


# ---------------------------------------------------------------- components
def Panel(title: str, *children: Gtk.Widget) -> Gtk.Overlay:
    """Frame with a [ TITLE ] cut into the top line."""
    box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=T["gap"])
    box.add_css_class("panel")
    box.set_margin_top(10)
    for ch in children:
        box.append(ch)
    lab = Gtk.Label(label=f"[ {title.upper()} ]")
    lab.add_css_class("panel-title")
    lab.set_halign(Gtk.Align.START)
    lab.set_valign(Gtk.Align.START)
    ov = Gtk.Overlay(child=box)
    ov.add_overlay(lab)
    return ov


def Row(key: str, value: str = "", css_class: str = "") -> tuple[Gtk.Box, Gtk.Label]:
    row = Gtk.Box(spacing=T["gap"] + 4)
    k = Gtk.Label(label=f"{key.upper()}:", xalign=0)
    k.set_width_chars(11)
    k.add_css_class("key")
    v = Gtk.Label(label=value, xalign=0, hexpand=True, use_markup=True)
    v.add_css_class("val")
    if css_class:
        v.add_css_class(css_class)
    row.append(k)
    row.append(v)
    return row, v


def meter(frac: float, width: int = 14) -> str:
    """Text meter in the Veil style: [|||||.......] — color fill, red when overloaded."""
    frac = max(0.0, min(1.0, frac))
    n = round(frac * width)
    col = C["danger"] if frac > 0.85 else C["accent"]
    return (span("[", C["frame"]) + span("|" * n, col) + span("." * (width - n), C["line"]) + span("]", C["frame"]))


def Separator() -> Gtk.Box:
    s = Gtk.Box()
    s.add_css_class("sep")
    return s


def ErrorLine() -> Gtk.Label:
    lab = Gtk.Label(label="", xalign=0, wrap=True, visible=False)
    lab.add_css_class("error")
    return lab


def show_error(lab: Gtk.Label, text: str):
    lab.set_label(f"!! {text}")
    lab.set_visible(bool(text))


def ActionButton(hint: str, name: str, on_activate, danger: bool = False) -> Gtk.Button:
    """Button [ L ] LOCK. danger=True — two-step confirmation (like ConfirmButton in AGS)."""
    btn = Gtk.Button()
    btn.add_css_class("vbtn")
    if danger:
        btn.add_css_class("danger")
    label = Gtk.Label(xalign=0, use_markup=True)
    idle = f"{span('[ ' + hint.upper() + ' ]', C['accent'])}  {esc(name.upper())}"
    armed = f"{span('!! CONFIRM ' + name.upper() + '? [ENTER]', C['danger'], True)}"
    label.set_markup(idle)
    btn.set_child(label)
    state = {"armed": False, "timer": 0}

    def disarm():
        state["armed"], state["timer"] = False, 0
        btn.remove_css_class("armed")
        label.set_markup(idle)
        return False

    def clicked(_b):
        if danger and not state["armed"]:
            state["armed"] = True
            btn.add_css_class("armed")
            label.set_markup(armed)
            state["timer"] = GLib.timeout_add_seconds(3, disarm)
            return
        if state["timer"]:
            GLib.source_remove(state["timer"])
        on_activate()

    btn.connect("clicked", clicked)
    btn.hint = hint.lower()
    return btn


def Section(text: str) -> Gtk.Label:
    lab = Gtk.Label(label=text.upper(), xalign=0)
    lab.add_css_class("section")
    return lab


def Toggle(name: str, on: bool, on_toggle) -> Gtk.Button:
    """[ NAME: ON ] / [ NAME: OFF ]; on_toggle(new_value)."""
    btn = Gtk.Button()
    btn.add_css_class("vbtn")
    lab = Gtk.Label(xalign=0, use_markup=True)
    btn.set_child(lab)
    st = {"on": on}

    def paint():
        lab.set_markup(f"{span('[ ' + name.upper() + ' ]', C['accent'] if st['on'] else C['dim'])}  "
                       f"{span('ON' if st['on'] else 'OFF', C['fg'] if st['on'] else C['dim'], st['on'])}")
        (btn.add_css_class if st["on"] else btn.remove_css_class)("on")

    btn.set_state = lambda v: (st.update(on=bool(v)), paint())  # noqa: E731
    btn.connect("clicked", lambda _b: on_toggle(not st["on"]))
    paint()
    return btn


def ListButton(markup: str, on_click, current: bool = False, ellipsize: int = 3) -> Gtk.Button:
    btn = Gtk.Button()
    btn.add_css_class("vbtn")
    if current:
        btn.add_css_class("current")
    lab = Gtk.Label(xalign=0, use_markup=True, ellipsize=ellipsize, hexpand=True)
    lab.set_markup(markup)
    btn.set_child(lab)
    btn.connect("clicked", lambda _b: on_click())
    return btn


def Scroll(child: Gtk.Widget, max_h: int = 260) -> Gtk.ScrolledWindow:
    sw = Gtk.ScrolledWindow(propagate_natural_height=True, max_content_height=max_h, hscrollbar_policy=Gtk.PolicyType.NEVER,
                            vscrollbar_policy=Gtk.PolicyType.EXTERNAL)
    sw.set_child(child)
    return sw


def clear(box: Gtk.Box):
    ch = box.get_first_child()
    while ch:
        nxt = ch.get_next_sibling()
        box.remove(ch)
        ch = nxt


def debounce(ms: int, fn):
    st = {"id": 0}

    def call(*a):
        if st["id"]:
            GLib.source_remove(st["id"])

        def fire():
            st["id"] = 0
            fn()
            return False
        st["id"] = GLib.timeout_add(ms, fire)
    return call


def run_async(argv: list[str], cb=None):
    """Fixed argv, stdout -> cb(str|None)."""
    try:
        p = Gio.Subprocess.new(argv, Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_SILENCE)
    except GLib.Error:
        if cb:
            cb(None)
        return

    def done(proc, res):
        try:
            _ok, out, _err = proc.communicate_utf8_finish(res)
        except GLib.Error:
            out = None
        if cb:
            cb(out)
    p.communicate_utf8_async(None, None, done)


def refit(win):
    """GTK4 doesn't shrink the window when the content gets smaller: force a size recompute."""
    w = getattr(win, "veil_width", 380)
    win.set_default_size(w, 1)
    GLib.idle_add(lambda: (win.set_default_size(w, -1), False)[1])


def spawn(argv: list[str]):
    """Fixed argv, no shell."""
    try:
        Gio.Subprocess.new(argv, Gio.SubprocessFlags.STDOUT_SILENCE | Gio.SubprocessFlags.STDERR_SILENCE)
    except GLib.Error as e:
        print("spawn failed:", argv, e)


# ---------------------------------------------------------------- popup window
def run_menu(app_id: str, build, *, width: int = 380, anchor: str = "top-right", keys=None):
    """build(win) -> Gtk.Widget. anchor: 'top-right' | 'center'. Running it again closes the menu."""
    app = Gtk.Application(application_id=app_id)
    st = {"win": None, "back": None}

    def close_all(*_):
        for w in (st["win"], st["back"]):
            if w:
                w.destroy()
        st["win"] = st["back"] = None

    def activate(a):
        if st["win"]:
            close_all()
            return
        prov = Gtk.CssProvider()
        prov.load_from_string(css())
        Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(), prov, Gtk.STYLE_PROVIDER_PRIORITY_USER)

        back = Gtk.Window(application=a)
        back.add_css_class("veil-backdrop")
        LS.init_for_window(back)
        LS.set_layer(back, LS.Layer.TOP)
        LS.set_namespace(back, "veil-backdrop")
        for edge in (LS.Edge.TOP, LS.Edge.BOTTOM, LS.Edge.LEFT, LS.Edge.RIGHT):
            LS.set_anchor(back, edge, True)
        LS.set_exclusive_zone(back, -1)
        LS.set_keyboard_mode(back, LS.KeyboardMode.NONE)
        click = Gtk.GestureClick()
        click.connect("pressed", close_all)
        back.add_controller(click)
        back.set_child(Gtk.Box())

        win = Gtk.Window(application=a)
        win.add_css_class("veil-menu")
        win.set_default_size(width, -1)
        LS.init_for_window(win)
        LS.set_layer(win, LS.Layer.OVERLAY)
        LS.set_namespace(win, "veil-menu")
        LS.set_exclusive_zone(win, -1)
        LS.set_keyboard_mode(win, LS.KeyboardMode.EXCLUSIVE)
        if anchor == "top-right":
            LS.set_anchor(win, LS.Edge.TOP, True)
            LS.set_anchor(win, LS.Edge.RIGHT, True)
            LS.set_margin(win, LS.Edge.TOP, T["bar_offset"])
            LS.set_margin(win, LS.Edge.RIGHT, T["margin"])
        win.close_menu = close_all
        win.veil_width = width
        win.set_child(build(win))

        kc = Gtk.EventControllerKey()

        def on_key(_c, keyval, _code, _state):
            if keyval == Gdk.KEY_Escape:
                close_all()
                return True
            if keys:
                name = Gdk.keyval_name(keyval) or ""
                fn = keys.get(name.lower())
                if fn:
                    fn()
                    return True
            return False

        kc.connect("key-pressed", on_key)
        win.add_controller(kc)
        st["win"], st["back"] = win, back
        back.present()
        win.present()

    app.connect("activate", activate)
    app.run(None)
