BEGIN { FS = "," }
{ a[ $1.$2 ]++;
if ( a[ $1.$2 ] != 1 )
  print($0)
}
