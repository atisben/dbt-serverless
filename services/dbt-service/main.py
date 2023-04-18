import subprocess
import argparse
from datetime import datetime, timedelta
import json

# Argument parser

# Define the argument parser
parser = argparse.ArgumentParser(description='My App')
parser.add_argument('framework', help='Framework used')# Required argument
parser.add_argument('funct', help='Function used by the framework')# Required argument
parser.add_argument('--vars', help='Variable dictionnary to include in the run')# Optional argument
parser.add_argument('--project-dir', help='Name of the project directory')# Optional argument
parser.add_argument('--profiles-dir', help='Name of the profiles directory')# Optional argument


def evaluate_vars(vars):
    print(vars)
    json_str = vars.replace("'", "\"")
    vars_dict = json.loads(json_str)
    for key, value in vars_dict.items():
        try:
            vars_dict[key] = eval(value)
        except (NameError, SyntaxError):
            vars_dict[key] = value
    return vars_dict

def run_subprocess(args):

    # Access the arguments
    # Replace the vars content
    vars_dict = evaluate_vars(args.vars)
    vars(args).update(vars_dict)

    # Add '--' prefix to optional arguments
    args_dict = vars(args)

    args_dict = {
        f'--{k}' if k not in ['framework', 'funct'] else k: v for k, v in args_dict.items()}
    print(args_dict)

    # Construct argument list for subprocess
    arg_list = [args.framework, args.funct]
    for arg_name, arg_value in args_dict.items():
        if arg_value is not None and arg_name not in ['framework', 'funct']:
            arg_list.append(arg_name)
            arg_list.append(str(arg_value))

    # Pass arguments to subprocess
    print(' '.join(arg_list))
    subprocess.call(arg_list)

run_subprocess(parser.parse_args())