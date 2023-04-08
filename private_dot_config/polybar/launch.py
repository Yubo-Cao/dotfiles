#!/usr/bin/env python
import subprocess
import signal
from pathlib import Path
from logging import getLogger, StreamHandler, FileHandler
from tempfile import NamedTemporaryFile

import jinja2

logger = getLogger("Polybar Launcher")
logger.setLevel("INFO")
logger.addHandler(StreamHandler())
logger.addHandler(FileHandler("/tmp/polybar-launch.log"))


def kill_polybar():
    try:
        pids = subprocess.check_output(
            ["pidof", "polybar"], encoding="utf-8", text=True
        ).split()
    except subprocess.CalledProcessError:
        logger.debug("No polybar processes found")
        return
    killers = [subprocess.Popen(["kill", str(pid)]) for pid in pids]
    for killer in killers:
        try:
            logger.debug("Waiting for polybar process %s to die", killer.pid)
            killer.wait(5)
            if killer.returncode:
                logger.warning(
                    "Killing polybar process %s failed with code %s",
                    killer.pid,
                    killer.returncode,
                )
        except subprocess.TimeoutExpired:
            logger.warning("Killing polybar process %s timed out", killer.pid)
            killer.kill()
            killer.wait()


def launch_polybar():
    template = jinja2.Template(
        (Path(__file__).resolve().parent / "config.ini.jinja").read_text(
            encoding="utf-8"
        )
    )
    displays = subprocess.check_output(
        ["polybar", "-m"], encoding="utf-8", text=True
    ).splitlines()
    processes = []
    for display in displays:
        display_name = display.split(":")[0]
        logger.debug("Launching polybar on display %s", display_name)
        config = template.render(display=display_name)
        with NamedTemporaryFile(mode="w", delete=False) as f:
            f.write(config)
            f.flush()
            processes.append(
                subprocess.Popen(
                    ["polybar", "-c", f.name, "main"],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
            )
            logger.debug("Launched polybar on display %s", display_name)
    return processes


def main():
    kill_polybar()
    processes = launch_polybar()
    try:
        for process in processes:
            process.wait()
    except KeyboardInterrupt:
        logger.debug("Received keyboard interrupt")
        kill_polybar()
        for process in processes:
            process.send_signal(signal.SIGINT)
            process.wait()


if __name__ == "__main__":
    main()
