#!/usr/bin/env python3
"""Generate the Veil VS Code / VSCodium theme extension from palette.toml and install it.

Usage: python3 vscode-theme.py [--no-install]
Builds ~/.config/theme/vscode/veil-theme-<ver>.vsix with two color themes (Veil Graphite, Veil Forest)
whose colors are the palette roles of the matching theme, then installs it with `codium --install-extension`.
"""
import json
import os
import subprocess
import sys
import tomllib
import zipfile

HOME = os.path.expanduser("~")
VERSION = "0.1.0"
OUT = f"{HOME}/.config/theme/vscode"
CODIUM = f"{HOME}/.local/bin/codium"

pal = tomllib.load(open(f"{HOME}/.config/theme/palette.toml", "rb"))


def roles(theme):
    i = pal["themes"].index(theme)
    return lambda n: pal["roles"][n][i]


def build(theme, label):
    R = roles(theme)
    bg, deep, side, panel = R("bg"), R("bg_deep"), R("bg_side"), R("bg_panel")
    soft, alt, card, sel, sel2 = R("bg_soft"), R("bg_alt"), R("bg_card"), R("bg_sel"), R("bg_sel2")
    line, frame, dim, sub = R("border"), R("muted"), R("dim"), R("subtext")
    fg, fgb, fg2 = R("fg"), R("fg_bright"), R("fg_2")
    acc, acc_hi = R("accent"), R("accent_4")
    amb, gold = R("yellow"), R("gold")
    red, red_hi = R("red"), R("red_hi")
    blue, blue_hi, cyan = R("steel"), R("steel_hi"), R("cyan")
    green, green_hi = R("green"), R("green_hi")
    purple, purple_hi = R("purple"), R("purple_hi")
    colors = {
        "foreground": fg, "descriptionForeground": sub, "disabledForeground": dim, "errorForeground": red,
        "focusBorder": acc, "widget.shadow": "#00000066", "selection.background": acc + "66",
        "icon.foreground": sub, "textLink.foreground": gold, "textLink.activeForeground": acc,
        "editor.background": bg, "editor.foreground": fg,
        "editorLineNumber.foreground": dim, "editorLineNumber.activeForeground": fg,
        "editor.lineHighlightBackground": soft, "editor.lineHighlightBorder": soft,
        "editor.selectionBackground": sel2, "editor.inactiveSelectionBackground": sel,
        "editor.findMatchBackground": acc + "66", "editor.findMatchHighlightBackground": amb + "44",
        "editor.wordHighlightBackground": sel, "editorCursor.foreground": acc,
        "editorIndentGuide.background1": line, "editorIndentGuide.activeBackground1": frame,
        "editorWhitespace.foreground": line, "editorBracketMatch.background": sel2, "editorBracketMatch.border": acc,
        "editorGutter.background": bg, "editorRuler.foreground": line, "editorCodeLens.foreground": dim,
        "editorWidget.background": alt, "editorWidget.border": line,
        "editorSuggestWidget.background": alt, "editorSuggestWidget.border": line,
        "editorSuggestWidget.selectedBackground": sel, "editorHoverWidget.background": alt, "editorHoverWidget.border": line,
        "editorError.foreground": red, "editorWarning.foreground": amb, "editorInfo.foreground": blue,
        "editorOverviewRuler.border": bg,
        "activityBar.background": side, "activityBar.foreground": fg, "activityBar.inactiveForeground": dim,
        "activityBar.border": line, "activityBar.activeBorder": acc,
        "activityBarBadge.background": acc, "activityBarBadge.foreground": bg,
        "sideBar.background": side, "sideBar.foreground": fg, "sideBar.border": line,
        "sideBarTitle.foreground": acc, "sideBarSectionHeader.background": side,
        "sideBarSectionHeader.foreground": sub, "sideBarSectionHeader.border": line,
        "list.activeSelectionBackground": sel, "list.activeSelectionForeground": fgb,
        "list.inactiveSelectionBackground": alt, "list.hoverBackground": alt, "list.highlightForeground": acc,
        "list.focusBackground": sel,
        "editorGroupHeader.tabsBackground": deep, "editorGroup.border": line,
        "tab.activeBackground": bg, "tab.activeForeground": fgb, "tab.inactiveBackground": deep,
        "tab.inactiveForeground": dim, "tab.border": line, "tab.activeBorderTop": acc,
        "tab.unfocusedActiveBackground": bg, "tab.hoverBackground": alt,
        "titleBar.activeBackground": panel, "titleBar.activeForeground": fg,
        "titleBar.inactiveBackground": deep, "titleBar.inactiveForeground": dim, "titleBar.border": line,
        "statusBar.background": panel, "statusBar.foreground": sub, "statusBar.border": line,
        "statusBar.noFolderBackground": panel, "statusBar.debuggingBackground": amb, "statusBar.debuggingForeground": bg,
        "statusBarItem.hoverBackground": sel, "statusBarItem.remoteBackground": acc, "statusBarItem.remoteForeground": bg,
        "panel.background": bg, "panel.border": line, "panelTitle.activeBorder": acc,
        "panelTitle.activeForeground": fgb, "panelTitle.inactiveForeground": dim,
        "input.background": deep, "input.border": line, "input.foreground": fg, "input.placeholderForeground": dim,
        "inputOption.activeBorder": acc, "dropdown.background": alt, "dropdown.border": line, "dropdown.foreground": fg,
        "button.background": acc, "button.foreground": bg, "button.hoverBackground": acc_hi,
        "button.secondaryBackground": sel, "button.secondaryForeground": fg,
        "badge.background": acc, "badge.foreground": bg, "progressBar.background": acc,
        "scrollbarSlider.background": line + "99", "scrollbarSlider.hoverBackground": frame + "99",
        "scrollbarSlider.activeBackground": dim + "99",
        "menu.background": alt, "menu.foreground": fg, "menu.selectionBackground": sel, "menu.border": line,
        "notifications.background": alt, "notifications.border": line, "notificationCenter.border": line,
        "peekView.border": acc, "peekViewEditor.background": alt, "peekViewResult.background": side,
        "breadcrumb.foreground": dim, "breadcrumb.focusForeground": fg, "breadcrumb.activeSelectionForeground": acc,
        "gitDecoration.modifiedResourceForeground": amb, "gitDecoration.addedResourceForeground": green,
        "gitDecoration.deletedResourceForeground": red, "gitDecoration.untrackedResourceForeground": green,
        "gitDecoration.ignoredResourceForeground": dim, "gitDecoration.conflictingResourceForeground": red_hi,
        "editorGutter.modifiedBackground": amb, "editorGutter.addedBackground": green, "editorGutter.deletedBackground": red,
        "terminal.background": bg, "terminal.foreground": fg, "terminalCursor.foreground": acc,
        "terminal.selectionBackground": sel2,
        "terminal.ansiBlack": card, "terminal.ansiRed": red, "terminal.ansiGreen": green, "terminal.ansiYellow": amb,
        "terminal.ansiBlue": blue, "terminal.ansiMagenta": purple, "terminal.ansiCyan": cyan, "terminal.ansiWhite": fg2,
        "terminal.ansiBrightBlack": frame, "terminal.ansiBrightRed": red_hi, "terminal.ansiBrightGreen": green_hi,
        "terminal.ansiBrightYellow": gold, "terminal.ansiBrightBlue": blue_hi, "terminal.ansiBrightMagenta": purple_hi,
        "terminal.ansiBrightCyan": R("blue_hi"), "terminal.ansiBrightWhite": fgb,
    }
    tok = lambda scope, fg_, style=None: {  # noqa: E731
        "scope": scope, "settings": ({"foreground": fg_} | ({"fontStyle": style} if style else {}))}
    tokens = [
        tok(["comment", "punctuation.definition.comment"], dim, "italic"),
        tok(["string", "string.quoted", "punctuation.definition.string"], gold),
        tok(["string.regexp", "constant.character.escape"], amb),
        tok(["constant.numeric", "constant.language", "constant.character"], purple),
        tok(["keyword", "storage", "storage.type", "storage.modifier"], acc),
        tok(["keyword.operator", "punctuation", "meta.brace"], sub),
        tok(["entity.name.function", "support.function", "meta.function-call", "meta.method-call"], blue_hi),
        tok(["entity.name.type", "entity.name.class", "support.class", "support.type", "entity.other.inherited-class"], amb),
        tok(["variable", "variable.parameter", "variable.other.readwrite"], fg),
        tok(["variable.other.constant", "support.constant"], purple_hi),
        tok(["entity.name.tag", "meta.tag"], acc),
        tok(["entity.other.attribute-name"], amb),
        tok(["support.type.property-name", "meta.object-literal.key"], blue_hi),
        tok(["markup.heading", "entity.name.section"], acc, "bold"),
        tok(["markup.bold"], fgb, "bold"), tok(["markup.italic"], fg, "italic"),
        tok(["markup.inline.raw", "markup.fenced_code"], gold),
        tok(["markup.underline.link", "string.other.link"], blue_hi),
        tok(["invalid", "invalid.illegal"], red),
    ]
    return {"name": label, "type": "dark", "semanticHighlighting": True, "colors": colors, "tokenColors": tokens}


def main():
    themes = [("graphite", "Veil Graphite"), ("forest", "Veil Forest")]
    pkg = {
        "name": "veil-theme", "displayName": "Veil", "publisher": "veil", "version": VERSION,
        "description": "Veil color themes generated from the dotfiles palette (graphite and forest)",
        "engines": {"vscode": "^1.60.0"}, "categories": ["Themes"],
        "contributes": {"themes": [{"label": lab, "uiTheme": "vs-dark",
                                    "path": f"./themes/veil-{t}-color-theme.json"} for t, lab in themes]},
    }
    manifest = f"""<?xml version="1.0" encoding="utf-8"?>
<PackageManifest Version="2.0.0" xmlns="http://schemas.microsoft.com/developer/vsx-schema/2011">
  <Metadata>
    <Identity Language="en-US" Id="veil-theme" Version="{VERSION}" Publisher="veil"/>
    <DisplayName>Veil</DisplayName>
    <Description xml:space="preserve">Veil color themes generated from the dotfiles palette</Description>
  </Metadata>
  <Installation><InstallationTarget Id="Microsoft.VisualStudio.Code"/></Installation>
  <Dependencies/>
  <Assets><Asset Type="Microsoft.VisualStudio.Code.Manifest" Path="extension/package.json" Addressable="true"/></Assets>
</PackageManifest>
"""
    types = ('<?xml version="1.0" encoding="utf-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/Content-Types">'
             '<Default Extension=".json" ContentType="application/json"/>'
             '<Default Extension=".vsixmanifest" ContentType="text/xml"/></Types>')
    os.makedirs(OUT, exist_ok=True)
    path = f"{OUT}/veil-theme-{VERSION}.vsix"
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml", types)
        z.writestr("extension.vsixmanifest", manifest)
        z.writestr("extension/package.json", json.dumps(pkg, indent=2))
        for t, lab in themes:
            z.writestr(f"extension/themes/veil-{t}-color-theme.json", json.dumps(build(t, lab), indent=2))
    print("built", path)
    if "--no-install" not in sys.argv:
        r = subprocess.run([CODIUM, "--install-extension", path, "--force"], capture_output=True, text=True, timeout=120)
        print((r.stdout + r.stderr).strip()[-400:])


main()
