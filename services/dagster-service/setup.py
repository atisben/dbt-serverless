from setuptools import find_packages, setup

if __name__ == "__main__":
    setup(
        name="dagster_service",
        packages=find_packages(exclude=["dagster_project_tests"]),
        install_requires=[
            "dagster",
        ],
        extras_require={"dev": ["dagit", "pytest"]},
    )
