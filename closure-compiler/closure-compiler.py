#! /usr/bin/env python

import argparse
import gzip
import httplib
import urllib
import sys

class AppError(Exception):
    pass

class CompileError(Exception):
    pass


COMPILATION_LEVEL = {
    'whitespace': 'WHITESPACE_ONLY',
    'simple': 'SIMPLE_OPTIMIZATIONS',
    'advanced': 'ADVANCED_OPTIMIZATIONS',
}

OUTPUT_INFO = {
    'code': 'compiled_code',
    'warn': 'warnings',
    'errors': 'errors',
    'stats': 'statistics',
}

LANGUAGE = {
    'ecma3': 'ECMASCRIPT3',
    'ecma5': 'ECMASCRIPT5',
    'ecma6': 'ECMASCRIPT6',
}

def entrypoint():
    try:
        args = parse_command_line()

        _process_input(args, args.input)

    except KeyboardInterrupt:
        sys.exit(0)
    except CompileError as ex:
        sys.stderr.write(str(ex))
        sys.exit(1)
    except AppError as ex:
        sys.stderr.write('{}: {}\n'.format(ex.__class__.__name__, ex))
        sys.stderr.flush()
        sys.exit(1)


def _process_input(args, files):
    # read input file
    tmp = []
    for f in files:
        for line in f:
            # ignore lines starting with ;;;
            if not line.strip().startswith(';;;'):
                tmp.append(line)
    js_code = ''.join(tmp)

    # gzip type is text for Closure Compiler service
    if args.output_format == 'gzip':
        output_format = 'text'
    else:
        output_format = args.output_format

    # query closure compiler service
    js_output = _query(
        js_code,
        LANGUAGE[args.language],
        output_format,
        OUTPUT_INFO[args.output_info],
        COMPILATION_LEVEL[args.comp_level],
        args.pretty,
    )

    if args.output_info in ('errors', 'warnings'):
        if len(js_output.strip()) > 0:
            raise CompileError(js_output)
        else:
            return

    # if compiled code is empty..
    if args.output_info == 'code' and len(js_output.strip()) == 0:
        # re-run querying for errors
        errors = _query(
            js_code,
            LANGUAGE[args.language],
            'text',
            'errors',
            COMPILATION_LEVEL[args.comp_level]
        )
        raise CompileError(errors)

    # compress gzip output
    if args.output_format == 'gzip':
        with gzip.open('output.js.gz', 'wb') as f:
            f.write(js_output)
        print 'Wrote output.js.gz'
    else:
        sys.stdout.write(js_output)


def _query(js_code, lang, output_format, output_info, comp_level, pretty=False):
    # build POST params from args
    params = [
        ('js_code', js_code),
        ('language', lang),
        ('output_format', output_format),
        ('output_info', output_info),
        ('compilation_level', comp_level),
    ]
    if pretty:
        params.append(('formatting', 'pretty_print'))

    # connect to Closure service
    conn = httplib.HTTPConnection('closure-compiler.appspot.com')
    conn.request(
        'POST',
        '/compile', 
        urllib.urlencode(params),
        {'Content-type': 'application/x-www-form-urlencoded'}
    )
    response = conn.getresponse()
    js_output = response.read()
    conn.close()
    return js_output


def parse_command_line():
    parser = argparse.ArgumentParser(
        description="CLI for Google's Closure Compiler service"
    )

    parser.add_argument(
        'input', type=argparse.FileType('r'), nargs='+',
        help='File path or URL containing JS to process, also accepts STDIN')
    parser.add_argument(
        '-c', '--comp-level', choices=COMPILATION_LEVEL.keys(), default='simple',
        help='Compilation level: whitespace, simple or advanced. Defaults to simple.')
    parser.add_argument(
        '-o', '--output-info', choices=OUTPUT_INFO.keys(), default='code',
        help='Output info: code, warnings, errors or statistics.')
    parser.add_argument(
        '-f', '--output-format', choices=['text','gzip','xml','json'], default='text',
        help='Output format: text, gzip, XML or JSON. Defaults to text.')
    parser.add_argument(
        '-l', '--language', choices=LANGUAGE.keys(), default='ecma5',
        help='Language: ECMAScript language version to target')
    parser.add_argument(
        '-p', '--pretty', action='store_true',
        help='Pretty formatting for output javascript')

    # TODO output_file_name

    return parser.parse_args()


if __name__ == '__main__':
    entrypoint()
