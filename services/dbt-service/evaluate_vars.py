import yaml
import re
import datetime

with open('variables.yml', 'r') as file:
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
with open('project/vars/project_vars.yml', 'w') as file:
    yaml.dump(data, file)