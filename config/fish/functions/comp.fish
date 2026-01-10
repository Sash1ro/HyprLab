#!/usr/bin/env fish

function comp
    if test (count $argv) -eq 0
        echo "Usage: ezgcc <file.c> [output_name]"
        return 1
    end

    set file $argv[1]
    set output (basename $file .c)

    # If user provides a second argument, use it as output
    if test (count $argv) -gt 1
        set output $argv[2]
    end

    gcc -std=c2x -Wall -Wextra -pedantic $file -o $output

    if test $status -eq 0
        echo "Compiled $file -> $output"
    else
        echo "Compilation failed"
    end
end
