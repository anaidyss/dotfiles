"""veilkit — общая дизайн-система попапов (GTK4 + gtk4-layer-shell).

Цвета — роли из ~/.config/theme/palette.toml для текущей темы, форма — [tokens.<тема>].
Компоненты: Panel ([ ЗАГОЛОВОК ] в верхней рамке), Row (ПОДПИСЬ: значение), Meter ([|||||.....]),
ActionButton (с подтверждением для опасного), ErrorLine. Попап = layer-shell окно + прозрачная
подложка: клик мимо или Esc закрывают, повторный запуск — переключает.
Без внешних процессов: данные читают сами меню из /proc и /sys.
"""
import atexit
import os
import signal
import sys

# Повторный запуск закрывает открытое меню. Делается через pid-файл и SIGUSR1 ещё до импорта GTK:
# регистрация Gtk.Application с application_id на D-Bus стоила ~400 мс на каждое открытие.
_NAME = os.path.basename(sys.argv[0])
_PIDFILE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), f"veil-menu-{_NAME}.pid")


def _signal_running() -> bool:
    try:
        pid = int(open(_PIDFILE).read())
        if pid != os.getpid() and _NAME.encode() in open(f"/proc/{pid}/cmdline", "rb").read():
            os.kill(pid, signal.SIGUSR1)
            return True
    except (OSError, ValueError):
        pass
    return False


# gtk4-layer-shell обязан быть загружен раньше libwayland-client: перезапускаемся с LD_PRELOAD
_LS_LIB = "/usr/lib64/libgtk4-layer-shell.so.0"
if "VEIL_CHECKED" not in os.environ:
    if _signal_running():
        sys.exit(0)
    with open(_PIDFILE, "w") as _f:
        _f.write(str(os.getpid()))
    os.environ["VEIL_CHECKED"] = "1"
    if os.path.exists(_LS_LIB) and "gtk4-layer-shell" not in os.environ.get("LD_PRELOAD", ""):
        os.environ["LD_PRELOAD"] = (_LS_LIB + ":" + os.environ.get("LD_PRELOAD", "")).rstrip(":")
        os.execv(sys.executable, [sys.executable] + sys.argv)
os.environ.pop("VEIL_CHECKED", None)


def _drop_pidfile():
    try:
        if int(open(_PIDFILE).read()) == os.getpid():
            os.unlink(_PIDFILE)
    except (OSError, ValueError):
        pass


atexit.register(_drop_pidfile)

# программный рендерер: старт GL-контекста добавлял ~100 мс до первого кадра, а окна маленькие
os.environ.setdefault("GSK_RENDERER", "cairo")

import tomllib  # noqa: E402

import gi  # noqa: E402

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


# ---------------------------------------------------------------- компоненты
def Panel(title: str, *children: Gtk.Widget) -> Gtk.Overlay:
    """Рамка с заголовком [ TITLE ], врезанным в верхнюю линию."""
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
    """Текстовая шкала в духе Veil: [|||||.......] — заполнение цветом, красным при перегрузе."""
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
    """Кнопка [ L ] LOCK. danger=True — двухшаговое подтверждение (как ConfirmButton в AGS)."""
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
    """[ NAME: ON ] / [ NAME: OFF ]; on_toggle(новое_значение)."""
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
    btn.veil_click, btn.veil_sig = on_click, (markup, bool(current))
    btn.connect("clicked", lambda _b: btn.veil_click())
    return btn


def fill(box: Gtk.Box, new: list) -> bool:
    """Заменяет детей box на new; если все ListButton совпадают по виду — оставляет старые (без мигания и потери hover),
    только обновляя их обработчики клика."""
    old, ch = [], box.get_first_child()
    while ch:
        old.append(ch)
        ch = ch.get_next_sibling()
    if len(old) == len(new) and all(getattr(o, "veil_sig", None) is not None and o.veil_sig == getattr(n, "veil_sig", 0)
                                    for o, n in zip(old, new)):
        for o, n in zip(old, new):
            o.veil_click = n.veil_click
        return False
    clear(box)
    for w in new:
        box.append(w)
    return True


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
    """Фиксированный argv, stdout -> cb(str|None)."""
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


SLIDE_PX = 10


def _slide(win, off: float):
    """Смещение окна вверх от своего места в px (0 — на месте)."""
    top = getattr(win, "veil_top", None)
    if top is not None:
        win.veil_off = off
        LS.set_margin(win, LS.Edge.TOP, top - round(off))


def _fade(win, start: float, end: float, ms: int, done=None, slide=None):
    """Анимация прозрачности (и, если slide=(от, до), смещения вверх в px) с замедлением к концу."""
    if getattr(win, "veil_tick", None):
        win.remove_tick_callback(win.veil_tick)
        win.veil_tick = None
    if not Gtk.Settings.get_default().props.gtk_enable_animations:
        win.set_opacity(end)
        if slide:
            _slide(win, slide[1])
        if done:
            done()
        return
    t0 = []

    def tick(w, _clock):
        now = GLib.get_monotonic_time()
        if not t0:
            t0.append(now)
        p = min(1.0, (now - t0[0]) / (ms * 1000))
        e = 1 - (1 - p) ** 3
        w.set_opacity(start + (end - start) * e)
        if slide:
            _slide(w, slide[0] + (slide[1] - slide[0]) * e)
        if p >= 1.0:
            w.veil_tick = None
            if done:
                done()
            return GLib.SOURCE_REMOVE
        return GLib.SOURCE_CONTINUE
    win.veil_tick = win.add_tick_callback(tick)


def reveal(win):
    """Плавно показывает окно (один раз). Окно создаётся прозрачным, чтобы не было видно скачка размера при загрузке данных."""
    if not getattr(win, "veil_revealed", True):
        win.veil_revealed = True
        _fade(win, 0.0, 1.0, 140, slide=(SLIDE_PX, 0))


def refit(win):
    """GTK4 не сжимает окно, когда содержимое стало меньше: выставляем высоту явно, одним шагом и только если она изменилась."""
    if getattr(win, "veil_fit_pending", False):
        return
    win.veil_fit_pending = True

    def apply():
        win.veil_fit_pending = False
        w = getattr(win, "veil_width", 380)
        child = win.get_child()
        if child is not None:
            w = max(w, child.measure(Gtk.Orientation.HORIZONTAL, -1)[0])
            nat = child.measure(Gtk.Orientation.VERTICAL, w)[1]
            if nat != getattr(win, "veil_h", None):
                win.veil_h = nat
                win.set_default_size(w, nat)
        GLib.idle_add(lambda: (reveal(win), False)[1])
        return False
    GLib.idle_add(apply)


def spawn(argv: list[str]):
    """Фиксированный argv, без shell."""
    try:
        Gio.Subprocess.new(argv, Gio.SubprocessFlags.STDOUT_SILENCE | Gio.SubprocessFlags.STDERR_SILENCE)
    except GLib.Error as e:
        print("spawn failed:", argv, e)


# ---------------------------------------------------------------- окно-попап
def run_menu(app_id: str, build, *, width: int = 380, anchor: str = "top-right", keys=None, wait_data: bool = False):
    """build(win) -> Gtk.Widget. anchor: 'top-right' | 'center'. Повторный запуск закрывает меню (см. _signal_running).
    wait_data=True — данные приходят асинхронно: окно остаётся прозрачным до первого refit() (или 120 мс).
    app_id только для читаемости вызовов: Gtk.Application создаётся без id, чтобы не платить за регистрацию на D-Bus."""
    app = Gtk.Application()
    st = {"win": None, "back": None, "cancel": False}

    def close_all(*_):
        win, back = st["win"], st["back"]
        st["win"] = st["back"] = None
        if back:
            back.destroy()
        if win:
            _fade(win, win.get_opacity(), 0.0, 100, win.destroy, slide=(getattr(win, "veil_off", 0.0), SLIDE_PX))

    def on_toggle_signal():
        if st["win"]:
            close_all()
        else:
            st["cancel"] = True
        return GLib.SOURCE_CONTINUE
    GLib.unix_signal_add(GLib.PRIORITY_HIGH, signal.SIGUSR1, on_toggle_signal)

    def activate(a):
        if st["cancel"]:
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
        win.veil_revealed = False
        win.set_opacity(0.0)
        if anchor == "top-right":
            win.veil_top = T["bar_offset"]
            _slide(win, SLIDE_PX)
        back.present()
        win.present()
        if wait_data:
            GLib.timeout_add(120, lambda: (st["win"] is win and reveal(win), False)[1])
        else:
            GLib.idle_add(lambda: (st["win"] is win and reveal(win), False)[1])

    app.connect("activate", activate)
    app.run(None)
