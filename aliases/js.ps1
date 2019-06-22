function jssize
{
    # https://twitter.com/DasSurma/status/1130523000762187776
    pbpaste | terser -c -m | gzip -c9n | wc -c
}
