import subprocess
import argparse
from datetime import datetime, timedelta
import json
import os

# Argument parser

# Define the argument parser
parser = argparse.ArgumentParser(description='My App')
parser.add_argument('framework', help='Framework used')# Required argument
parser.add_argument('funct', help='Function used by the framework')# Required argument
parser.add_argument('--vars', help='Variable dictionnary to include in the run')# Optional argument
parser.add_argument('--project-dir', dest='project-dir', help='Name of the project directory')# Optional argument
parser.add_argument('--profiles-dir', dest='profiles-dir', help='Name of the profiles directory')# Optional argument


def evaluate_vars(vars):
    # json_str = vars.replace("'", "\"")
    vars_dict = json.loads(vars)
    for key, value in vars_dict.items():
        try:
            print(f"modifying {value}")
            vars_dict[key] = str(eval(value))
        except (NameError, SyntaxError) as e:
            print(f"Error: {e}")
            vars_dict[key] = value
    json_out = json.dumps(vars_dict)
    return(json_out)

def run_subprocess(args):

    # Replace the vars content
    if args.vars is not None:
        print("found some --vars to be replaced")
        vars_dict = evaluate_vars(args.vars)
        args.vars=vars_dict
    
    # Add '--' prefix to optional arguments
    args_dict = vars(args)

    args_dict = {
        f'--{k}' if k not in ['framework', 'funct'] else k: v for k, v in args_dict.items()}

    # Construct argument list for subprocess
    arg_list = [args_dict['framework'], args_dict['funct']]
    for arg_name, arg_value in args_dict.items():
        if arg_value is not None and arg_name not in ['framework', 'funct']:
            arg_list.append(str(arg_name))
            arg_list.append(str(arg_value))

    # Pass arguments to subprocess
    print(arg_list)
    subprocess.call(arg_list)

# Check the current working directory
run_subprocess(parser.parse_args())