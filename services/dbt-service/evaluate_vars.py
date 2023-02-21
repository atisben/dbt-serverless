import yaml
import re
import datetime


def generate_variable_file(input_file, output_file):
    with open(input_file, 'r') as file: # variables.yml
        data = yaml.safe_load(file)
    # Define a function to recursively evaluate variables in a dictionary
    def eval_vars(data):
        if isinstance(data, dict):
            for key, value in data.items():
                if isinstance(value, str):
                    data[key] = eval(re.sub(r'{{(.+?)}}', r'\1', value))
                elif isinstance(value, dict):
                    data[key] = eval_vars(value)
        return data

    # Evaluate variables in the dictionary
    data = eval_vars(data)

    # Write the updated dictionary back to the dbt_project.yml file
    with open(output_file, 'w') as file: # project/vars/project_vars.yml
        yaml.dump(data, file)