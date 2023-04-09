#!/usr/bin/env python
import subprocess
import time
from collections.abc import Callable
from logging import FileHandler, getLogger
from pathlib import Path
from typing import NamedTuple

import pyudev
from i3ipc import Connection
from i3ipc.events import Event
from rich.logging import RichHandler
from tomlkit import loads
from Xlib.display import Display
from Xlib.ext import randr

log = getLogger(__name__)
log.setLevel("DEBUG")
log.addHandler(RichHandler())
log.addHandler(FileHandler("/tmp/workscreen.log"))


class XOutput(NamedTuple):
    x: int
    y: int
    name: str
    connected: bool
    disabled: bool
    is_primary: bool


def get_outputs(display: Display) -> list[XOutput]:
    root = display.screen().root
    resources = root.xrandr_get_screen_resources()._data
    primary_output = root.xrandr_get_output_primary().output
    outputs: list[XOutput] = []

    for output in resources["outputs"]:
        _data = display.xrandr_get_output_info(
            output, resources["config_timestamp"]
        )._data
        x = y = 0

        if _data["crtc"]:
            crtcInfo = display.xrandr_get_crtc_info(
                _data["crtc"], resources["config_timestamp"]
            )
            x = crtcInfo.x
            y = crtcInfo.y

        outputs.append(
            XOutput(
                x=x,
                y=y,
                name=_data["name"],
                connected=_data["connection"] == randr.Connected,
                disabled=not _data["crtc"],
                is_primary=output == primary_output,
            )
        )

    return list(filter(lambda output: output.connected, outputs))


def robustify(fn: Callable) -> Callable:
    def wrapper(*args, **kwargs):
        try:
            fn(*args, **kwargs)
        except Exception as e:
            log.exception(e)

    return wrapper


old_outputs: set[XOutput] = set()
hook_workers: list[subprocess.Popen] = []


@robustify
def update(
    display: Display,
    i3: Connection,
    general_cfg: dict,
    output_cfgs: dict[str, dict],
) -> None:
    global old_outputs
    x_outputs = get_outputs(display)
    log.debug("x_outputs: %s", x_outputs)
    if old_outputs == set(x_outputs):
        log.info("No change in outputs, skipping")
        return
    else:
        log.info("Outputs changed, updating")
    i3_outputs = list(filter(lambda output: output.active, i3.get_outputs()))
    log.debug("i3_outputs: %s", [o.name for o in i3_outputs])
    outputs = set(map(lambda output: output.name, x_outputs))
    if general_cfg.get("auto_disable", True):
        log.info("auto_disable is True, disabling outputs")
        i = len(i3_outputs) - 1
        while i >= 0:
            if (i3_output := i3_outputs[i]).name not in outputs:
                i3_outputs.pop(i)
                i3.command(f"output {i3_output.name} disable")
                log.info(f"Disabled output {i3_output.name}")
            i -= 1
    else:
        log.info("auto_disable is False, skipping disabling outputs")

    configure_outputs(output_cfgs, x_outputs)
    time.sleep(general_cfg.get("delay", 1.0))
    configure_workspace(i3, output_cfgs, outputs)
    run_hooks(general_cfg)
    old_outputs = set(x_outputs)


def run_hooks(general_cfg):
    for worker in hook_workers:
        try:
            worker.kill()
            _, stderr = worker.communicate(timeout=5.0)
        except subprocess.TimeoutExpired:
            log.error("Hook failed to terminate in time")
        if "stderr" in locals() and stderr:
            log.error(stderr)
        if worker.returncode != 0:
            log.error(f"Hook %s failed doesn't terminate gracefully", worker.args)
    hook_workers.clear()
    hooks = general_cfg.get("hooks", [])
    for hook in hooks:
        log.debug(f"Running hook: {hook}")
        try:
            hook_workers.append(
                subprocess.Popen(
                    hook,
                    shell=True,
                    encoding="utf-8",
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.PIPE,
                )
            )
            log.debug(f"Hook ran successfully: {hook}")
        except subprocess.CalledProcessError as e:
            log.error(f"Failed to run hook: {hook}")


@robustify
def configure_outputs(
    output_cfgs: dict[str, dict[str, list[str]]],
    x_outputs: list[XOutput],
) -> None:
    def call(cmd: list[str]):
        log.debug(f"Running command: {' '.join(cmd)}")

        try:
            subprocess.run(
                cmd,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.PIPE,
                text=True,
                encoding="utf-8",
                check=True,
            )
            log.debug("Command ran successfully")
        except subprocess.CalledProcessError as e:
            log.error("Failed to run command: %s", " ".join(cmd))
            log.error(e.stderr)

    old_output_names = set([o.name for o in old_outputs])
    if added := set([o.name for o in x_outputs]) - old_output_names:
        log.info("Adding outputs: %s", added)
        for output, cfg in output_cfgs.items():
            call(
                [
                    "xrandr",
                    "--output",
                    output,
                    "--auto",
                ]
            )
            if args := cfg.get("xrandr"):
                call(
                    [
                        "xrandr",
                        "--output",
                        output,
                        *args,
                    ]
                )
            log.info(f"Configured output {output}")
    if removed := old_output_names - set([o.name for o in x_outputs]):
        log.info("Removing outputs: %s", removed)
        for output in removed:
            call(
                [
                    "xrandr",
                    "--output",
                    output,
                    "--off",
                ]
            )
            log.info(f"Disabled output {output}")


@robustify
def configure_workspace(
    i3: Connection,
    output_cfgs: dict[str, dict[str, list[str]]],
    outputs: set[str],
) -> None:
    workspaces: dict[str, list[str]] = {}
    for workspace in i3.get_workspaces():
        if workspace.output not in outputs:
            continue
        workspaces.setdefault(workspace.output, []).append(workspace.name)
    log.debug("workspaces: %s", workspaces)
    reverse_workspaces: dict[str, str] = {}
    for output, cfg in output_cfgs.items():
        for w in cfg.get("workspaces", []):
            reverse_workspaces[w] = output
    log.debug("reverse_workspaces: %s", reverse_workspaces)
    focused_workspace = i3.get_tree().find_focused().workspace().name
    for output, cfg in output_cfgs.items():
        if not (expected_ws := cfg.get("workspaces", [])):
            continue
        for w in workspaces.get(output, []):
            if w not in expected_ws and w in reverse_workspaces:
                i3.command(
                    f"workspace {w};"
                    f"move workspace to output {reverse_workspaces[w]};"
                )
                log.info(f"Moved workspace {w} to output {reverse_workspaces[w]}")
    i3.command(f"workspace {focused_workspace}")
    log.info(f'Switch back to original focused workspace "{focused_workspace}"')


def load_config() -> dict[str, dict]:
    try:
        cfg: dict = loads(
            (cfg_path := Path(__file__).resolve().parent / "workscreen.toml").read_text(
                encoding="utf-8"
            )
        )
    except FileNotFoundError:
        log.error(f"Config file not found: {cfg_path}")
        exit(1)
    except Exception as e:
        log.error(f"Error while loading config: {e}")
        exit(1)
    log.debug(f"Loaded config from {cfg_path}")
    return cfg


def main() -> None:
    display = Display()
    log.debug("Connected to X server")
    if not display.has_extension("RANDR"):
        log.error("No XRandR extension found")
        exit(1)
    cfg = load_config()
    log.debug("cfg: %s", cfg)
    i3 = Connection(auto_reconnect=True)
    log.debug("Connected to i3")
    handler = lambda *_: update(
        display,
        i3,
        cfg.get("general", {}),
        {output: c for output, c in cfg.items() if output != "general"},
    )
    if cfg.get("general", {}).get("init", False):
        handler()
        log.debug("Initialized outputs")
    else:
        global old_outputs
        old_outputs = set(get_outputs(display))
        log.debug("old_outputs: %s", old_outputs)
    context = pyudev.Context()
    monitor = pyudev.Monitor.from_netlink(context)
    monitor.filter_by(subsystem='drm')
    monitor.start()
    log.info("Listening for output events")
    for device in iter(monitor.poll, None):
        if device.action == 'change':
            log.info(f"Detected change in device {device}")
            handler()

    log.info("Exiting")




if __name__ == "__main__":
    main()
