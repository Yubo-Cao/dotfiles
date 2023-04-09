import requests
from lxml.etree import HTML
from pathlib import Path
from tomlkit import dumps, loads
from logging import getLogger

logger = getLogger(__name__)


def scrape_palette():
    doc = HTML(
        requests.get(
            "https://tailwindcss.com/docs/customizing-colors",
            headers={
                "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36"
            },
        ).text
    )
    data = dict(
        (
            el.xpath("./div[1]/text()")[0].lower(),
            dict(
                (x.xpath("./div[1]/text()")[0], x.xpath("./div[2]/text()")[0])
                for x in el.xpath(
                    './div[2]//div[contains(@class, "flex items-center")]/div[2]'
                )
            ),
        )
        for el in doc.xpath(
            "//*[@id='content-wrapper']//*[contains(@class, '2xl:contents')]"
        )
    )
    for k, v in data.items():
        data[k] = {**{"main": v["500"]}, **v}
    return data


def load_config():
    CONFIG_PATH = Path(__file__).parent / "palette_config.toml"
    try:
        config = loads(CONFIG_PATH.read_text(encoding="utf-8"))
    except FileNotFoundError:
        logger.error("Config file not found")
        exit(1)
    except Exception:
        logger.error("Invalid config file")
        exit(1)
    return config


def convert(colors):
    def hex_to_rgb(hex):
        hex = hex.lstrip("#")
        hlen = len(hex)
        return f'rgb({", ".join(tuple(str(int(hex[i:i+hlen//3], 16)) for i in range(0, hlen, hlen//3)))})'

    def apply_recursive(dct, fn):
        result = {}
        for k, v in dct.items():
            if isinstance(v, dict):
                result[k] = apply_recursive(v, fn)
            else:
                result[k] = fn(v)
        return result

    table = {
        "web": colors,
        "hex": apply_recursive(colors, lambda s: s.lstrip("#")),
        "rgb": apply_recursive(colors, lambda s: hex_to_rgb(s)),
    }

    def reduce(dct):
        # reduce the last dimension of the dict
        # {a: {b: 1, c: 1}} -> {a_b: 1, a_c: 1}
        result = {}
        for k, v in dct.items():
            if isinstance(v, dict):
                for k2, v2 in v.items():
                    result[f"{k}_{k2}"] = v2
            else:
                result[k] = v
        return result

    return {k: reduce(v) for k, v in table.items()}


def main():
    cfg = load_config()
    try:
        hues = [cfg[i] for i in "primary secondary tertiary dark".split()]
        [cfg[i] for i in "background title text border".split()]
    except KeyError:
        logger.error("Invalid config file")
        exit(1)
    data = scrape_palette()
    for hue in hues:
        if hue not in data:
            logger.error(f"Invalid semantic color: {hue}")
            exit(1)
    colors = {hue: data[cfg[hue]] for hue in "primary secondary tertiary dark".split()}
    for semantic in "background title text border".split():
        colors[semantic] = {
            hue: data[cfg[hue]][str(cfg[semantic])]
            for hue in "primary secondary tertiary dark".split()
        }
    table = convert({**colors, **data})
    print(dumps(dict(data=table)))


if __name__ == "__main__":
    main()
