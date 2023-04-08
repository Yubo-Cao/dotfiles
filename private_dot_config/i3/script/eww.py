import asyncio
from collections import ChainMap
from logging import FileHandler, StreamHandler, getLogger
from operator import add, mul, sub, truediv
from pathlib import Path
from tomllib import loads
from typing import Literal

from i3ipc.aio import Connection
from i3ipc.aio.connection import Con
from i3ipc.replies import OutputReply, Rect

logger = getLogger(__name__)
logger.setLevel("DEBUG")
logger.addHandler(FileHandler("/tmp/eww.log"))
logger.addHandler(StreamHandler())


async def determine_output(conn: Connection, con: Con) -> OutputReply:
    outputs = [output for output in await conn.get_outputs() if output.active]

    def is_inside(a: Rect, b: Rect) -> bool:
        return (
            a.x >= b.x
            and a.y >= b.y
            and a.x + a.width <= b.x + b.width
            and a.y + a.height <= b.y + b.height
        )

    for output in outputs:
        if is_inside(con.rect, output.rect):
            logger.debug("Found output %s for %s", output.name, con.name)
            return output
    logger.warning("Could not find exact output for %s", con.name)

    def intersect(a: Rect, b: Rect) -> int:
        return max(0, min(a.x + a.width, b.x + b.width) - max(a.x, b.x)) * max(
            0, min(a.y + a.height, b.y + b.height) - max(a.y, b.y)
        )

    output = max(outputs, key=lambda output: intersect(con.rect, output.rect))
    logger.warning("Using output %s for %s", output.name, con.name)
    return output


async def load_config() -> dict:
    path = Path(__file__).resolve().parent / "eww.toml"
    try:
        return loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        logger.error("Could not find eww.toml")
        raise
    except IOError:
        logger.error("Could not read eww.toml")
        raise


def eval(expr: str | int, output: OutputReply, type: Literal["width", "height"]) -> int:
    if isinstance(expr, int):
        return expr

    tokens: list[str | int] = []
    i, j = 0, 0
    while i < len(expr):
        c = expr[i]
        if c.isdigit():
            while j < len(expr) and expr[j].isdigit():
                j += 1
            tokens.append(int(expr[i:j]))
            j -= 1
        elif c in {"+", "-", "*", "/", "(", ")", "%"}:
            tokens.append(c)
        i = j = j + 1
    precedence = dict(
        ChainMap(
            *[
                {operator: i for operator in operators}
                for i, operators in enumerate(("()", "+-", "*/", "%"))
            ]
        )
    )

    op_stack: list[str] = []
    num_stack: list[int] = []

    def eval_once():
        token = op_stack.pop()
        if token == "%":
            num_stack.append(
                (output.rect.width if type == "width" else output.rect.height)
                * (num_stack.pop() / 100)
            )
        else:
            b, a = num_stack.pop(), num_stack.pop()
            num_stack.append({"+": add, "-": sub, "*": mul, "/": truediv}[token](a, b))

    for token in tokens:
        match token:
            case int():
                num_stack.append(token)
            case "(":
                op_stack.append(token)
            case ")":
                while op_stack[-1] != "(":
                    eval_once()
                    if not op_stack:
                        logger.error("Unmatched parenthesis")
                        raise ValueError("Unmatched parenthesis")
                op_stack.pop()
            case "+" | "-" | "*" | "/" | "%":
                while op_stack and precedence[op_stack[-1]] > precedence[token]:
                    eval_once()
                op_stack.append(token)
    while op_stack:
        eval_once()

    return int(num_stack[0])


async def main() -> None:
    config = await load_config()

    i3 = await Connection().connect()
    root = await i3.get_tree()
    ewws: list[Con] = root.find_instanced("eww")
    for eww in ewws:
        output = await determine_output(i3, eww)
        name = eww.name.split(" ", 2)[-1]
        if name not in config:
    n       logger.error("Could not find config for %s", name)
            continue
        cfg = config[name]
        dimensions = {
            "width": eval(cfg.get("width", "100%"), output, "width"),
            "height": eval(cfg.get("height", 24), output, "height"),
            "x": eval(cfg.get("x", "0"), output, "width"),
            "y": eval(cfg.get("y", "0"), output, "height"),
        }
        logger.debug(f"Setting geometry of {eww.name} to {dimensions}")
        await eww.command(
            "floating enable;"
            "sticky enable;"
            f"resize set {dimensions['width']} {dimensions['height']};"
            f"move position {dimensions['x']} {dimensions['y']};"
            "border none;"
        )


asyncio.run(main())
