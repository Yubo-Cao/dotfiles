#!/usr/bin/env python
import sys
import subprocess
from subprocess import Popen, PIPE, DEVNULL

def notify(title: str, message: str):
    subprocess.Popen(
        ["notify-send", title, message],
        stdout=DEVNULL,
        stderr=DEVNULL
    )

def main():
    window_id, class_name, instance_name, _ = sys.argv[1:]
    try:
        props = subprocess.check_output(
            ["xprop", "-id", window_id], text=True
        ).splitlines()
    except subprocess.CalledProcessError:
        return
    window_role: str | None = None
    for prop in props:
        if 'WM_WINDOW_ROLE' in prop:
            window_role = prop.split("=")[1].strip().strip('"')
            break
    rules: list[str] = []
    if window_role is None:
        return
    elif window_role in {
        "pop-up",
        "bubble",
        "dialog",
        "task_dialog",
        "menu"
    }:
        rules.append("state=floating")
    print(",".join(rules))

if __name__ == "__main__":
    main()
