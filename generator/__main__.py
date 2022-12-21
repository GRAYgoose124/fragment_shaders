#!/usr/bin/python
import os
import argparse


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--path', help='Path to the project', default='.')
    parser.add_argument('name', help='Name of the project')

    args = parser.parse_args()

    # handle default/cwd path
    if args.path == '.':
        args.path = os.path.dirname(__file__)
    elif '..' in args.path:
        # attempt to resolve the path up one level
        args.path = os.path.dirname(os.path.dirname(__file__))

    # create the directory
    if not os.path.exists(args.path):
        os.mkdir(args.path)

    return args


def generate_project(path, name, buffers=1):
    cwd = os.path.dirname(__file__)
    proj_path = os.path.join(path, name)

    # if relative path, make it absolute
    if not os.path.isabs(proj_path):
        proj_path = os.path.join(cwd, proj_path)

    if not os.path.exists(proj_path):   
        os.mkdir(proj_path)
    else:
        print('Project already exists')
        return

    with open(os.path.join(cwd, 'main.glsl'), 'r') as template_buffer:
        template = template_buffer.read()
        
        # create the files
        if buffers:
            # create the buffers
            # TODO: link buffers
            for i in range(buffers):
                with open(os.path.join(proj_path, f"buffer{chr(ord('A')+i)*((i%26)+1)}.glsl"), 'w') as f:
                    f.write(template)

        # create the main file
        # TODO: link to final buffer
        with open(os.path.join(proj_path, 'main.glsl'), 'w') as f:
            # write templates/main.glsl to the file
                f.write(template)


if __name__ == '__main__':
    args = parse_args()
    generate_project(args.path, args.name)