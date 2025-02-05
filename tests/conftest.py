import sys
import pathlib as path

project_path = path.Path(__file__).parents[1] / "reverse_proxy" 
sys.path.append(project_path.as_posix())

 
