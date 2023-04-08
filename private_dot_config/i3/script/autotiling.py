import argparse
import sys
from functools import partial
from logging import FileHandler, StreamHandler, getLogger
from pathlib import Path
from tempfile import gettempdir

from i3ipc import Connection, Event, Con

logger = getLogger(__name__)
logger.addHandler(StreamHandler())
logger.addHandler(FileHandler("autotiling.log"))


def resolve_output(container: Con) -> str | None:
    if container.type == "root":
        return None

    if p := container.parent:
        if p.type == "output":
            return p.name
        else:
            return resolve_output(p)

    return None


def switch_splitting(
    i3: Connection,
    events: list[Event | str],
    outputs: list[str],
    workspaces: list[int],
    depth_limit: int,
) -> None:
    try:
        container = i3.get_tree().find_focused()
        output = resolve_output(container)

        if outputs and output not in outputs:
            logger.debug("Autotiling turned off on output {}".format(output))
            return

        if (
            container
            and not workspaces
            or (str(container.workspace().num) in workspaces)
        ):
            # i3 use floating_con, while sway use _on
            is_floating = (
                "_on" in container.floating
                if container.floating
                else container.type == "floating_con"
            )

            if depth_limit:
                depth_limit_reached = True
                current_con = container
                current_depth = 0
                while current_depth < depth_limit:
                    if current_con.type == "workspace":
                        depth_limit_reached = False
                        break

                    current_con = current_con.parent
                    if len(current_con.nodes) > 1:
                        current_depth += 1

                if depth_limit_reached:
                    logger.info("Depth limit reached")
                    return

            is_full_screen = container.fullscreen_mode == 1
            is_stacked = container.parent.layout == "stacked"
            is_tabbed = container.parent.layout == "tabbed"

            if (
                not is_floating
                and not is_stacked
                and not is_tabbed
                and not is_full_screen
            ):
                new_layout = (
                    "splitv"
                    if container.rect.height > container.rect.width
                    else "splith"
                )
                if new_layout != container.parent.layout:
                    result = i3.command(new_layout)
                    if result[0].success:
                        logger.debug("Switched to {}".format(new_layout))
                    else:
                        logger.error(
                            "Switch failed with err {}".format(result[0].error)
                        )
        else:
            logger.warning(
                "No focused container found or autotiling on the workspace turned off"
            )

    except Exception as events:
        logger.error("Error: {}".format(events))


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--level",
        default="DEBUG",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="set logging level",
    )
    parser.add_argument(
        "-o",
        "--outputs",
        help="restricts autotiling to certain output; "
        "example: autotiling --output  DP-1 HDMI-0",
        nargs="*",
        type=str,
        default=[],
    )
    parser.add_argument(
        "-w",
        "--workspaces",
        help="restricts autotiling to certain workspaces; example: autotiling --workspaces 8 9",
        nargs="*",
        type=str,
        default=[],
    )
    parser.add_argument(
        "-l",
        "--limit",
        help="limit how often autotiling will split a container; "
        'try "2", if you like master-stack layouts; default: 0 (no limit)',
        type=int,
        default=0,
    )
    parser.add_argument(
        "-e",
        "--events",
        help="list of events to trigger switching split orientation; default: WINDOW MODE",
        nargs="*",
        type=str,
        default=["WINDOW", "MODE"],
    )

    args = parser.parse_args()
    return args


def main():
    args = parse_args()
    logger.setLevel(args.level)

    if args.outputs:
        logger.debug("autotiling is only active on outputs:", ",".join(args.outputs))

    if args.workspaces:
        logger.debug(
            "autotiling is only active on workspaces:", ",".join(args.workspaces)
        )

    workspace_file = Path(gettempdir()) / "autotiling"

    if args.workspaces:
        workspace_file.write_text(",".join(args.workspaces))
    else:
        if workspace_file.exists() and workspace_file.is_file():
            workspace_file.unlink()

    if not args.events:
        logger.error("No events specified")
        sys.exit(1)

    handler = partial(
        switch_splitting,
        outputs=args.outputs,
        workspaces=args.workspaces,
        depth_limit=args.limit,
    )
    i3 = Connection()
    for e in args.events:
        try:
            i3.on(Event[e], handler)
            logger.debug("{} subscribed".format(Event[e]))
        except KeyError:
            logger.error("'{}' is not a valid event".format(e), file=sys.stderr)
            sys.exit(1)

    i3.main()


if __name__ == "__main__":
    main()
