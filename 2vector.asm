ORG 10

/-----------TEST------------
/writes 1 to MP[1][4]
    LDA T1
    BSA M_WR
    DEC 1
    DEC 4
/write 2 to MP[2][5]
    LDA T2
    BSA M_WR
    DEC 2
    DEC 5
/reads MP[1][4] to R1
    BSA M_RD
    DEC 1
    DEC 4
    STA R1
/reads MP[2][5] to R2
    BSA M_RD
    DEC 2
    DEC 5
    STA R2
    HLT
/---------------------------

/--------read AC from map-------
/how to use(read AC from MP[n][m])
/BSA M_RD
/DEC n
/DEC m
M_RD, HEX 0         /return address
    LDA M_RD I      /load n
    CMA
    INC             
    STA CNT         /set counter
    SZA
    BUN L1
    BUN SK1         /if n==0, skip L1
L1, LDA PO
    ADD LN          /add line numbers
    STA PO
    ISZ CNT      /n++
    BUN L1
SK1,ISZ M_RD
    LDA M_RD I      /load m
    ADD PO
    STA PO          /add m to pointer
    LDA PO I        /load AC
    STA TMP         /save AC
    /initialize pointer
    LDA PO0
    STA PO
    LDA TMP         /load AC
    ISZ M_RD
    BUN M_RD I      /return
/-------------------------------
/--------write AC to map--------
/how to use(write AC to MP[n][m])
/BSA M_WR
/DEC n
/DEC m
M_WR, HEX 0         /return address
    STA TMP         /save AC
    LDA M_WR I      /load n
    CMA
    INC
    STA CNT         /set counter
    SZA
    BUN L0
    BUN SK0         /if n==0, skip L0
L0, LDA PO
    ADD LN          /add line numbers
    STA PO
    ISZ CNT      /n++
    BUN L0
SK0,ISZ M_WR
    LDA M_WR I      /load m
    ADD PO
    STA PO          /add m to pointer
    LDA TMP         /load AC
    STA PO I        /write AC to map
    /initialize pointer
    LDA PO0
    STA PO
    LDA TMP         /load AC
    ISZ M_WR
    BUN M_WR I      /return
/--------------------------------
/----------TEST_DATA--------
T1, DEC 1
T2, DEC 2
R1, DEC 0
R2, DEC 0
/---------------------------
/--------DATA------------
TMP,HEX 0 /temporary data
CNT,HEX 0 /counter
/map(two-dimension array)
PO, SYM MP  /map pointer
PO0,SYM MP  /pointer initial value
LN, DEC 16  /map line number
/--------0st_line--------
MP, DEC 0   /map data
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
/--------1nd_line--------
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
/--------2rd_line--------
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
/--------3th_line--------
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
/--------4th_line--------
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
/--------5th_line--------
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
/--------6th_line--------
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
/--------7th_line--------
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
/--------8th_line--------
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
/--------9th_line--------
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
/--------10th_line--------
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
/--------11th_line--------
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
/--------12th_line--------
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
/--------13th_line--------
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
/--------14th_line--------
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
/--------15th_line--------
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
    DEC 0
END