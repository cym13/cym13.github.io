#!/usr/bin/env rdmd

import std.file;
import std.stdio;
import std.algorithm;

enum vernum = "2.0.0";

enum help = q"EOF
Compute CRC32 checksum of streams and files

Usage: crc32 [options] [FILE...]

Arguments:
    FILE  The file to compute the checksum of
          If FILE is a directory all files within it will be taken
          If FILE is missing the standard input is taken

Options:
    -h, --help      Print this help and exit
    -v, --version   Print version and exit
    -r, --recursive Traverse subdirectories recursively
EOF";

/**
 * Computes the crc32 checksum of a file and returns it as a string
 */
string crc32(File chunks) {
    import std.uni;
    import std.digest.crc;

    return chunks.byChunk(8192)
                 .crc32Of
                 .reverse
                 .toHexString
                 .toLower;
}

int main(string[] args) {
    import std.getopt:       getopt;
    import std.array:        array;
    import core.stdc.stdlib: exit;

    auto spanmode = SpanMode.shallow;

    getopt(args,
        "recursive|r", { spanmode = SpanMode.depth; },
        "version|v",   { writeln("crc32 v", vernum); exit(0); },
        "help|h",      { write(help); exit(0); },
    );

    // Without arguments, use stdin
    if (args[1..$].length == 0) {
        writeln(stdin.crc32);
        return 0;
    }

    // Make list of inputs
    string[] fileList = args[1..$].filter!isFile.array;

    // Add inputs from directory arguments
    args[1..$].filter!isDir
              .map!(d => dirEntries(d, spanmode))
              .each!((dir) => fileList ~= dir.map!(e => e.name)
                                             .filter!isFile
                                             .array);

    // Remove duplicates
    sort(fileList);
    fileList = fileList.uniq.array;

    foreach (f ; fileList) {
        File file;
        scope(exit) file.close;

        try {
            file = File(f, "rb");
        } catch(FileException ex) {
            stderr.write(ex.msg);
            continue;
        }

        auto crc = file.crc32;
        if (crc)
            writefln("%s\t%s", crc, f);
    }

    return 0;
}
