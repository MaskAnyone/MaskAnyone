import argparse
import shutil

program = argparse.ArgumentParser(
    formatter_class=lambda prog: argparse.HelpFormatter(prog, max_help_position=100)
)
program.add_argument(
    "-s", "--source-image", help="select an source image", dest="source_path"
)
program.add_argument(
    "-t", "--in-path", help="select an target image or video", dest="target_path"
)
program.add_argument(
    "-o", "--out-path", help="select output file or directory", dest="output_path"
)
program.add_argument(
    "--backend-update-url",
    help="exact url of the backend server for status updates incl worker id and jobid",
    dest="backend_update_url",
    type=str,
)

args = program.parse_args()

source_path = "/app/models/docker_models/roop/faces/" + args.source_path + ".jpg"
target_path = "/app/" + args.target_path
output_path = "/app/" + args.output_path

shutil.copyfile(source_path, output_path)
