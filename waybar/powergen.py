import json
import logging
from typing import Dict, Any


def get_config(name: str) -> Dict[str, Any]:
    try:
        with open(name, "r") as config:
            return json.loads(config.read())
    except IOError as e:
        logging.error(f"Failed to open file {name}, {e!r}")
    except Exception as e:
        logging.error(f"{e!r}")


def rightarrow():
    count: int = 0
    while True:
        yield {f"custom/rightarrow{count}": {"format": ""}}
        count += 1


def leftarrow():
    count: int = 0
    while True:
        yield {f"custom/leftarrow{count}": {"format": ""}}
        count += 1


def main():
    GEN_CONFIG = get_config("genconfig.json")
    COLOR_SCHEME = get_config(GEN_CONFIG["scheme_config"])
    WAYBAR_CONFIG = get_config(GEN_CONFIG["waybar_config"])
    try:
        with open(GEN_CONFIG["css"], "a") as css:
            pass
    except Exception as e:
        logging.error(f"{e!r}")
