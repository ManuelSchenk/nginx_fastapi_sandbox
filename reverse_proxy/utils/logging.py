from icecream import ic
from datetime import datetime
import inspect
import os


def custom_ic_output(arg):
    frame = inspect.currentframe().f_back.f_back
    line_number = frame.f_lineno
    container_name = os.popen("hostname").read().strip()
    output_line = f"{datetime.now().strftime('%Y%m%d_%H:%M:%S')} | container: {container_name} | Line: {line_number} | {arg[3:].strip()}\n"
    with open('ic.log', 'a') as f:
        f.write(output_line)
    print(output_line, flush=True)

ic.configureOutput(includeContext=True, outputFunction=custom_ic_output)
