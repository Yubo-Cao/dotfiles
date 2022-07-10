#!/usr/bin/python
import argparse
import sys
from collections.abc import Mapping, Sequence
from functools import partial
from logging import DEBUG, Logger, StreamHandler
from subprocess import DEVNULL, CalledProcessError, Popen

from yaml import YAMLError, load

try:
    from yaml import CLoader as loader
except ImportError:
    from yaml import Loader as loader

logger = Logger("package manager")
logger.addHandler(StreamHandler(sys.stdout))
logger.setLevel(DEBUG)


class Package:
    def __init__(self, name, exe="pacman"):
        self.name = name
        self.exe = exe

    @property
    def installed(self):
        return self.run(["-Qi", self.name], "get info").returncode == 0

    @installed.setter
    def installed(self, val):
        if val:
            self.run(["-S", self.name], "install")
        else:
            self.run(["-R", self.name], "uninstall")

    @property
    def exists(self):
        return self.run(["-Ssq", "^" + self.name + "$"], "get info").returncode == 0

    def run(self, cmd, msg, noconfirm=True, *args, **kwargs):
        if noconfirm:
            cmd[1:1] = ["--noconfirm"]
        cmd = [self.exe] + cmd

        try:
            process = Popen(cmd, stdout=DEVNULL, stderr=DEVNULL, *args, **kwargs)
            process.communicate()
            return process
        except CalledProcessError as e:
            logger.error(f"Failed to {msg} for {self.name!r} [{e.returncode}]")
            raise

    def __repr__(self):
        return f"<{self.exe}:{self.name}>"

    def __str__(self) -> str:
        return self.name


def main():
    parser = argparse.ArgumentParser("package manager")
    parser.add_argument("yaml", help="yaml file position")
    parser.add_argument(
        "--backend",
        help="backend to detect",
        choices=["yay", "pacman"],
        default="yay",
    )
    parser.add_argument(
        "--batch",
        help="install a bunch",
        action="store_true",
        default=True,
    )
    args = parser.parse_args()

    try:
        with open(args.yaml) as yaml:
            config = load(yaml, loader)
    except (YAMLError, IOError) as e:
        logger.error(f"Failed to read config file {args.yaml}")
        sys.exit()

    stack = [config]
    pkgs = {}
    idx = 0
    pk = partial(Package, exe=args.backend)

    while idx < len(stack):
        e = stack[idx]
        match e:
            case str():
                if (pkg := pk(e)).exists:
                    if not pkg.installed:
                        pkgs.setdefault("default", []).append(pkg)
                else:
                    logger.warning(f"{e} does not exists")
            case Mapping():
                if (
                    args.batch
                    and len(e) == 1
                    and (k := next(iter(e.keys()), None))
                    and all(isinstance(e, str) for e in e[k])
                ):
                    pkgs[k] = [
                        pkg for inner in e[k] if not (pkg := pk(inner)).installed
                    ]
                else:
                    stack.extend(e.values())
            case Sequence():
                stack.extend(e)
        idx += 1

    for group, group_pkgs in pkgs.items():
        if group_pkgs:
            print(f"Installing {group}")
            for pkg in group_pkgs:
                print(f"    Installing {pkg}")
                pkg.installed = True

if __name__ == "__main__":
    main()
