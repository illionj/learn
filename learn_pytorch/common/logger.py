from __future__ import annotations

import sys
from pathlib import Path
from typing import Optional

from loguru import logger


_INITIALIZED = False
_PROJECT_ROOT = Path(__file__).resolve().parents[1]
_DEFAULT_LOG_DIR = _PROJECT_ROOT / "logs"
_SIMPLE_CONSOLE_FORMAT = "<level>{message}</level>"
_DETAILED_CONSOLE_FORMAT = (
    "<green>{time:YYYY-MM-DD HH:mm:ss}</green> | "
    "<level>{level: <8}</level> | "
    "<cyan>{extra[name]}</cyan> | "
    "<level>{message}</level>"
)
_FILE_FORMAT = (
    "{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | "
    "{process.name}:{thread.name} | {extra[name]} | {message}"
)


def setup_logger(
    name: str = "learn_pytorch",
    *,
    log_dir: Optional[Path | str] = None,
    console_level: str = "DEBUG",
    file_level: str = "INFO",
    enable_console: bool = True,
    enable_file: bool = True,
    console_style: str = "simple",
    rotation: str = "10 MB",
    retention: str = "7 days",
    force: bool = False,
) -> None:
    """Configure Loguru sinks once per logger name."""

    global _INITIALIZED

    if _INITIALIZED and not force:
        return

    logger.remove()

    if enable_console:
        console_format = (
            _DETAILED_CONSOLE_FORMAT
            if console_style == "detailed"
            else _SIMPLE_CONSOLE_FORMAT
        )
        logger.add(
            sys.stderr,
            level=console_level,
            enqueue=True,
            backtrace=False,
            diagnose=False,
            format=console_format,
        )

    if enable_file:
        log_path = Path(log_dir) if log_dir is not None else _DEFAULT_LOG_DIR
        log_path.mkdir(parents=True, exist_ok=True)
        logger.add(
            log_path / f"{name}.log",
            level=file_level,
            rotation=rotation,
            retention=retention,
            enqueue=True,
            encoding="utf-8",
            backtrace=False,
            diagnose=False,
            format=_FILE_FORMAT,
        )

    _INITIALIZED = True


def get_logger(
    name: str = "learn_pytorch",
    *,
    log_dir: Optional[Path | str] = None,
    console_level: str = "DEBUG",
    file_level: str = "INFO",
    enable_console: bool = True,
    enable_file: bool = False,
    console_style: str = "simple",
    rotation: str = "10 MB",
    retention: str = "7 days",
    force: bool = False,
):
    """Return a bound logger after applying the default project setup."""

    setup_logger(
        name,
        log_dir=log_dir,
        console_level=console_level,
        file_level=file_level,
        enable_console=enable_console,
        enable_file=enable_file,
        console_style=console_style,
        rotation=rotation,
        retention=retention,
        force=force,
    )
    return logger.bind(name=name)
