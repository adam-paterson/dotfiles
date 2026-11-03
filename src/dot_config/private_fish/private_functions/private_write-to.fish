function write-to --description 'Write stdin to a file, creating parent directories first'
    if test (count $argv) -ne 1
        echo "usage: write-to <file>" >&2
        return 2
    end
    mkdir -p (path dirname -- $argv[1])
    or return
    cat > $argv[1]
end
