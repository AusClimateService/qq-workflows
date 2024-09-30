"""Command line program for the reverse glob command bolg."""

import os
import re
import difflib
import argparse


def bolg(filepaths, minOrphanCharacters=2):
    """
    Approximate inverse of `glob.glob`: take a sequence of `filepaths`
    and compute a glob pattern that matches them all. Only the star
    character will be used (no question marks or square brackets).

    Define an "orphan" substring as a sequence of characters, not
    including a file separator, that is sandwiched between two stars.   
    Orphan substrings shorter than `minOrphanCharacters` will be
    reduced to a star. If you don't mind having short orphan
    substrings in your result, set `minOrphanCharacters=1` or 0.
    Then you might get ugly results like '*0*2*.txt' (which contains
    two orphan substrings, both of length 1).
    
    Source: https://stackoverflow.com/questions/43808808/inverse-glob-reverse-engineer-a-wildcard-string-from-file-names
    """
    if os.path.sep == '\\':
        # On Windows, convert to forward-slashes (Python can handle
        # it, and Windows doesn't permit them in filenames anyway):
        filepaths = [filepath.replace('\\', '/') for filepath in filepaths]
    out = ''
    for filepath in filepaths:
        if not out: out = filepath; continue
        # Replace differing characters with stars:
        out = ''.join(x[-1] if x[0] == ' ' or x[-1] == '/' else '*' for x in difflib.ndiff(out, filepath))
        # Collapse multiple consecutive stars into one:
        out = re.sub(r'\*+', '*', out)
    # Deal with short orphan substrings:
    if minOrphanCharacters > 1:
        pattern = r'\*+[^/]{0,%d}\*+' % (minOrphanCharacters - 1)
        while True:
            reduced = re.sub(pattern, '*', out)
            if reduced == out: break
            out = reduced
    # Collapse any intermediate-directory globbing into a double-star:
    out = re.sub(r'(^|/).*\*.*/', r'\1**/', out)

    return out


def main(args):
    """Run the program."""

    print(bolg(args.infiles))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=__doc__,
        argument_default=argparse.SUPPRESS,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )                      
    parser.add_argument("infiles", nargs='*', type=str, help="input files")
    args = parser.parse_args()
    main(args)