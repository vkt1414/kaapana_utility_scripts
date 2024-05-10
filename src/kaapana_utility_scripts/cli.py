"""Console script for kaapana_utility_scripts."""
import kaapana_utility_scripts

import typer
from rich.console import Console

app = typer.Typer()
console = Console()


@app.command()
def main():
    """Console script for kaapana_utility_scripts."""
    console.print("Replace this message by putting your code into "
               "kaapana_utility_scripts.cli.main")
    console.print("See Typer documentation at https://typer.tiangolo.com/")
    


if __name__ == "__main__":
    app()
