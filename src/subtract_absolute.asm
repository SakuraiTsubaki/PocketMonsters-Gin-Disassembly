; Return |A - B| in A, with carry set when the original A was less than B.
SubtractAbsolute::
    sub b
    ret nc
    cpl
    add 1
    scf
    ret
