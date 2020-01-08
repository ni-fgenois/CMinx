#!/usr/bin/python3

from cmakedoc.documenter import Documenter
import sys
import argparse
import os

def main(args = sys.argv[1:]):
    parser = argparse.ArgumentParser()
    parser.add_argument("file", nargs="+", help="CMake file to generate documentation for. If directory, will generate documentation for all .cmake files")
    parser.add_argument("-o", "--output", help="Directory to output generated RST to. If not specified will print to standard output. Output files will have the original filename with the cmake extension replaced by .rst")
    parser.add_argument("-r", "--recursive", help="If specified, will generate documentation for all subdirectories of specified directory recursively", action="store_true")
    args = parser.parse_args(args)
    output_path = None
    if args.output is not None:
         output_path = os.path.abspath(args.output)
         print(f"Writing RST files to {output_path}")

    for input in args.file:
         document(input, output_path, args.recursive)


def document(file, output_path = None, recursive = None):

    files = []
    input_path = os.path.abspath(file)

    if os.path.isdir(input_path):
        #Walk dir and add cmake files to list
        for root, subdirs, filenames in os.walk(input_path):
             for file in filenames:
                  if "cmake" == file.split(".")[-1].lower():
                       files.append(os.path.join(root, file))
             if not recursive:
                  break
    elif os.path.isfile(input_path):
        files.append(input_path)
    else:
        print("File is a special file (socket, FIFO, device file) and is unsupported", file=sys.stderr)
        exit(1)

    for file in files:
         if os.path.isdir(input_path):
              header_name = os.path.relpath(file, input_path) #Path to file relative to input_path
         else:
              header_name = file
         documenter = Documenter(file, header_name)
         output_writer = documenter.process()
         if output_path != None: #Determine where to place generated RST file
              print(f"Writing for file {file}")
              if os.path.isdir(output_path):
                   output_filename = os.path.join(output_path, ".".join(os.path.basename(file).split(".")[:-1]) + ".rst")
                   if os.path.isdir(input_path):
                        subpath = os.path.relpath(file, input_path) #Path to file relative to input_path
                        output_filename = os.path.join(output_path, os.path.join(os.path.dirname(subpath), ".".join(os.path.basename(file).split(".")[:-1]) + ".rst"))
                   print(f"Writing RST file {output_filename}")
                   os.makedirs(os.path.dirname(output_filename), exist_ok=True) #Make sure we have all the directories created
                   output_writer.write_to_file(output_filename)
         else: #Output was not specified so print to screen
              print(output_writer)
              print()

if __name__ == "__main__":
     main()
