import re


def concatenate_files(input_file, output_file):
    with open(input_file, "r") as file:
        file_paths = [
            re.search(r'import "(.+)"', line).group(1) + ".lua"
            for line in file.read().splitlines()
        ]

    with open(output_file, "w+") as output:
        for file_path in file_paths:
            with open(file_path, "r") as file:
                output.write(f"-- {file_path}\n")
                output.write(file.read())
                output.write("\n")


input_file = "./source/pp-engine.lua"  # Path to the file containing list of file paths
output_file = "./pp-engine.lua"  # Path to the output file

if __name__ == "__main__":
    concatenate_files(input_file, output_file)
