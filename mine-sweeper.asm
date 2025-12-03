    ORG 0
ST0, HEX 0         / interrupt return address
    STA BA
    LDA STT_NLH
    SPA
    BUN I_HND_NLH      / go to interrupt handler (I_HND)
    BUN I_HND_XY

    ORG 10
/---------MAIN---------
/--------input N, L, H-------
BSA INPUT_NLH   /Jyo
/--------transfer N, L, H to G_N, G_L, G_H--------
/made by Yoken
    LDA INPUT1
    BSA CTN   /transfer a char to a number
    STA G_N
    LDA INPUT2
    BSA CTN
    STA G_L
    LDA INPUT3
    BSA CTN
    STA G_H
/---------SET the STEP_REMAIN to -(L*H-N)
/made by Yoken
    LDA G_L
    CMA
    INC
    STA CNT
    CLA
L_STP,
    ADD G_H
    ISZ CNT
    BUN L_STP
    CMA
    INC
    ADD G_N
    STA STEP_REMAIN
    CLA
    CLE
/--------generate map--------
BSA G_Bomb  /Fumiya
BSA G_NUM   /Yoken
MAIN_LOOP,
/--------print map--------
BSA PRINT_MAP  /Yoken
/--------input X, Y--------
BSA INPUT_XY  /Jyo
/--------transfer X, Y to G_X, G_Y--------
/made by Yoken
    LDA INPUT1
    BSA CTN   /transfer a char to a number
    STA G_X
    LDA INPUT2
    BSA CTN
    STA G_Y
/--------Controler--------
BSA CTL     /Yoken
/--------back to input OR end--------
LDA END_FLAG
SZA
SPA
BUN MAIN_LOOP
BSA PRINT_MAP  /Yoken
HLT
/----------------------
/--------INPUT_NLH_and_XY--------
/input N, L, H
INPUT_NLH, HEX 0
    LDA VM3         / AC <- -3
    STA STT_NLH         / M[STT_NLH] <- -3
/open the output
    LDA VH4         / AC <- 4
    IMK             / IMSK <- (1000) (S_IN enabled)
    SIO             / IOT <- 1 (serial-IO selected)
    ION             / enable interrupt
L_NLH, LDA STT_NLH            / AC <- M[STT_NLH]
    SPA             / (M[STT_NLH] >= 0) ? skip next
    BUN L_NLH
    IOF             / IEN <- 0 (disable interrupt)
    CLA             / AC <- 0
    IMK             / IMSK <- 0 (disable S_IN)
    BUN INPUT_NLH I
/--------Input Handler-----------
/ 1. store AC & E to memory
I_HND_NLH,
    CIL                / AC[0] <- E    (AC[15:1] is not important here...)
    STA BE            / M[BE] <- AC    (store E)
/ 2. check SFG_NLH and S_IN
SIN_NLH,
    LDA SFG_NLH            / AC <- M[SFG_NLH]
    SZA                / (M[SFG_NLH] == 0) ? skip next
    BUN SOU_NLH            / goto SOU_NLH
    SKI                / (S_IN ready) ? skip next
    BUN IRT_NLH            / goto IRT_NLH
/ S_IN is ready --> update IMSK (disable S_IN, enable S_OUT)
    LDA VH4            / AC <- (0100)
    IMK                / IMSK <- (0100) (enable S_OUT)
/ read S_IN data
    INP                / AC(7:0) <- INPR
    STA INPUT_ADDR I/ M[M[INPUT_ADDR]] <- AC
    ISZ INPUT_ADDR    / ++M[INPUT_ADDR]
    ISZ SFG_NLH            / ++M[SFG_NLH]
    ISZ STT_NLH         / ++M[STT_NLH]
    BUN SOU_NLH
    LDA BE
    CIR
    LDA BA
    BUN ST0 I
/ 3. check GP_OUT
SOU_NLH,
    SKO                / (S_OUT ready) ? skip next
    BUN IRT_NLH            / goto IRT_NLH
/ S_OUT is ready --> update IMSK (disable S_OUT, enable S_IN)
    LDA VH8            / AC <- (1000)
    IMK                / IMSK <- (1000) (enable S_IN)
/ format output (N,H,L)
    LDA CHAR_OPEN    / AC <- '('
    OUT             / OUTR <- AC
    LDA INPUT1      / AC <- N
    OUT             / OUTR <- AC
    LDA CHAR_COMMA  / AC <- ','
    OUT             / OUTR <- AC
    LDA INPUT2      / AC <- H
    OUT             / OUTR <- AC
    LDA CHAR_COMMA  / AC <- ','
    OUT             / OUTR <- AC
    LDA INPUT3      / AC <- L
    OUT             / OUTR <- AC
    LDA CHAR_CLOSE  / AC <- ')'
    OUT             / OUTR <- AC
    CLA                / AC <- 0
    STA SFG_NLH            / M[SFG_NLH] <- 0
/ 4. restore AC & E from memory
IRT_NLH, LDA BE        / AC <- M[BE]
    CIR                / E <- AC[0]    (restore E)
    LDA BA            / AC <- M[BA]    (restore AC)
    ION                / IEN <- 1        (enable interrupt)
    BUN ST0 I        / indirect return (return address stored in ST0)

/input x, y
INPUT_XY, HEX 0
    LDA VM2         / AC <- -2
    STA STT_XY         / M[STT] <- -2
    LDA VH2
    STA SFG_XY
    LDA INPUT_1
    STA INPUT1
    LDA INPUT_2
    STA INPUT2
    LDA INPUT_ADDR_0
    STA INPUT_ADDR
/open the output
    LDA VH4         / AC <- 4
    IMK             / IMSK <- (1000) (S_IN enabled)
    SIO             / IOT <- 1 (serial-IO selected)
    ION             / enable interrupt
L_IN_XY, LDA STT_XY            / AC <- M[STT]
    LDA STT_XY
    LDA STT_XY
    SPA             / (M[STT] >= 0) ? skip next
    BUN L_IN_XY
    IOF             / IEN <- 0 (disable interrupt)
    CLA
    IMK             / IMSK <- 0 (disable S_IN)
    BUN INPUT_XY I

/--------interrupt handler--------
/ 1. store AC & E to memory
I_HND_XY,
    CIL                / AC[0] <- E    (AC[15:1] is not important here...)
    STA BE            / M[BE] <- AC    (store E)
/ 2. check SFG and S_IN
SIN,
    LDA SFG_XY            / AC <- M[SFG]
    SZA                / (M[SFG] == 0) ? skip next
    BUN SOU            / goto SOU
    SKI                / (S_IN ready) ? skip next
    BUN IRT            / goto IRT
/ S_IN is ready --> update IMSK (disable S_IN, enable S_OUT)
    LDA VH4            / AC <- (0100)
    IMK                / IMSK <- (0100) (enable S_OUT)
/ read S_IN data
    INP                / AC(7:0) <- INPR
    STA INPUT_ADDR I/ M[M[INPUT_ADDR]] <- AC
    ISZ INPUT_ADDR    / ++M[INPUT_ADDR]
    ISZ SFG_XY            / ++M[SFG]
    ISZ STT_XY         / ++M[STT]
    BUN IRT
    LDA BE
    CIR
    LDA BA
    BUN ST0 I
/ 3. check GP_OUT
SOU,
    SKO                / (S_OUT ready) ? skip next
    BUN IRT            / goto IRT
/ S_OUT is ready --> update IMSK (disable S_OUT, enable S_IN)
    LDA VH8            / AC <- (1000)
    IMK                / IMSK <- (1000) (enable S_IN)
/ format output (X,Y)
    LDA CHAR_OPEN    / AC <- '('
    OUT             / OUTR <- AC
    LDA INPUT1      / AC <- X
    OUT             / OUTR <- AC
    LDA CHAR_COMMA  / AC <- ','
    OUT             / OUTR <- AC
    LDA INPUT2      / AC <- Y
    OUT             / OUTR <- AC
    LDA CHAR_CLOSE  / AC <- ')'
    OUT             / OUTR <- AC
    CLA                / AC <- 0
    STA SFG_XY            / M[SFG] <- 0
/ 4. restore AC & E from memory
IRT, LDA BE        / AC <- M[BE]
    CIR                / E <- AC[0]    (restore E)
    LDA BA            / AC <- M[BA]    (restore AC)
    ION                / IEN <- 1        (enable interrupt)
    BUN ST0 I        / indirect return (return address stored in ST0)

/ Data storage
BA, DEC 0
BE, DEC 0
STT_NLH, DEC 0        / state
SFG_NLH, DEC 3        / flag
STT_XY, DEC 0
SFG_XY, DEC 2
INPUT_ADDR, SYM INPUT1
INPUT_ADDR_0, SYM INPUT1
INPUT1, DEC 78
INPUT2, DEC 72
INPUT3, DEC 76
INPUT4, DEC 0
INPUT_1, DEC 88
INPUT_2, DEC 89
VH4, HEX 4        / 0100
VH8, HEX 8        / 1000
CHAR_OPEN, DEC 40 / ASCII for '('
CHAR_COMMA, DEC 44 / ASCII for ','
CHAR_CLOSE, DEC 41 / ASCII for ')'
CHAR_ENTER, DEC 10  / ASCII for 'Enter'
OUTPUT_ADDR, SYM CHAR_N
CHAR_N, DEC 78   / ASCII for 'N'
CHAR_H, DEC 72   / ASCII for 'H'
CHAR_L, DEC 76   / ASCII for 'L'
/---------------------------------

/--------transfer a char to a number--------
CTN, HEX 0     /return address
    STA T
    ADD NAS_f
    SNA        / if AC - 'f' <= 0
    BUN MAIN_LOOP
    LDA T
    ADD NAS_a
    SNA        / if AC - 'a' < 0
    BUN AD10
    LDA T
    ADD NAS_F
    SNA        / if AC - 'F' <= 0
    BUN MAIN_LOOP
    LDA T
    ADD NAS_A
    SNA        / if AC - 'A' < 0
    BUN AD10
    LDA T
    ADD NAS_9
    SNA        / if AC - '9' <= 0
    BUN MAIN_LOOP
    LDA T
    ADD NAS_0
    SNA        / if AC - '0' < 0
    BUN AD0
    BUN MAIN_LOOP
/ add 10 and end
AD10, ADD A10
    CLE
    BUN CTN I
/ add 0 and end
AD0, CLE
    BUN CTN I

ERR, HLT

T,   DEC 0      / tmp
A10, DEC 10     / 10
NAS_0, DEC -48     / 0
NAS_9, DEC -58     / 9 + 1
NAS_A, DEC -65     / A
NAS_F, DEC -71     / F + 1
NAS_a, DEC -97     / a
NAS_f, DEC -103    / f + 1
/---------------------------------

/--------Generate Bomb--------
G_Bomb, HEX 0
/input Global N, L, H
    LDA G_N
    STA X
    LDA G_L
    STA W
    STA WD
    LDA G_H
    STA H
    STA HD
/start
    LDA X         / AC <- M[X]
    STA N         / M[N] <- AC
S0, CLE       / E <- 0
    LDA H     / AC <- M[H]
    SZA       / Skip if AC == 0
    BUN SY    / goto SY
    LDA HD    / AC <- M[HD]
    STA H     / M[H] <- AC
    LDA WD    / AC <- M[WD]
    STA W     / M[W] <- AC
    BUN S1    / goto S1
    / M[Y] >>= 1
SY, CIR       / AC(15:0) >>= 1
    STA H     / M[H] <- AC
    SZE       / Skip if E == 0
    BUN SP    / goto SP
    / M[X] <<= 1
SX, LDA W     / AC <- M[W]
    CIL       / AC <<= 1
    STA W     / M[W] <- AC
    BUN S0    / goto S0
    / M[P] += M[X]
SP, LDA W     / AC <- M[W]
    ADD XA    / AC <- AC + M[XA]
    STA XA    / M[XA] <- AC
    CLE       / E <- 0
    BUN SX    / goto SX

S1, CLE       / E <- 0
    LDA XA    / AC <- M[XA]
    SZA       / Skip if AC == 0
    BUN S3    / goto S3
    BUN R1    / goto R1
    / M[Y] >>= 1
S3, CIR       / AC(15:0) >>= 1
    STA XA    / M[XA] <- AC
    SZE       / Skip if E == 0
    BUN S5    / goto S5
    / M[X] <<= 1
S4, LDA X     / AC <- M[X]
    CIL       / AC <<= 1
    STA X     / M[X] <- AC
    BUN S1    / goto S1
    / M[P] += M[X]
S5, LDA X     / AC <- M[X]
    ADD XB    / AC <- AC + M[XB]
    STA XB    / M[XB] <- AC
    CLE       / E <- 0
    BUN S4    / goto S4

// Multiplication
R1, CLE       / E <- 0
    LDA Y     / AC <- M[Y]
    SZA       / Skip if AC == 0
    BUN RY    / goto RY
    BUN T0    / goto T0
    / M[Y] >>= 1
RY, CIR       / AC(15:0) >>= 1
    STA Y     / M[Y] <- AC
    SZE       / Skip if E == 0
    BUN RP    / goto RP
    / M[X] <<= 1
RX, LDA XB    / AC <- M[XB]
    CIL       / AC <<= 1
    STA XB    / M[XB] <- AC
    BUN R1    / goto R1
    / M[P] += M[X]
RP, LDA XB    / AC <- M[XB]
    ADD P     / AC <- AC + M[P]
    STA P     / M[P] <- AC
    CLE       / E <- 0
    BUN RX    / goto RX
    // Multiplication finished
    // Addition starts
T0, LDA YD    / AC <- M[YD]
    STA Y     / M[Y] <- AC
    LDA P     / AC <- M[P]
    ADD C     / AC <- AC + M[C]
    STA P1    / M[P1] <- AC
    STA XB    / M[XB] <- AC

    // Modulus calculation starts
M0, LDA W     / AC <- M[W]
    CMA       / AC <- ~AC
    INC       / AC <- AC + 1
    STA NB    / M[NB] <- AC
M1, CLE       / E <- 0
    LDA P1    / AC <- M[P1]
    CIL       / AC <<= 1
    STA P1    / M[P1] <- AC
    LDA R     / AC <- M[R]
    CIL       / AC <<= 1
    STA R     / M[R] <- AC
    ADD NB    / AC <- AC + M[NB]
    SNA       / Skip if AC < 0
    STA R     / M[R] <- AC
    LDA Q     / AC <- M[Q]
    CIL       / AC <<= 1
    STA Q     / M[Q] <- AC
    ISZ K     / M[K] <- M[K] + 1; Skip if M[K] == 0
    BUN M1    / goto M1
    LDA KD    / AC <- M[KD]
    STA K     / M[K] <- AC
    LDA R     / AC <- M[R]
    STA XB
    STA N_R    / M[X0] <- AC
    STA N_W    / M[X1] <- AC

// R2 section
R2, CLE       / E <- 0
    LDA Y     / AC <- M[Y]
    SZA       / Skip if AC == 0
    BUN LY    / goto LY
    BUN T1    / goto T1
    / M[Y] >>= 1
LY, CIR       / AC(15:0) >>= 1
    STA Y     / M[Y] <- AC
    SZE       / Skip if E == 0
    BUN LP    / goto LP
    / M[X] <<= 1
LX, LDA XB    / AC <- M[XB]
    CIL       / AC <<= 1
    STA XB    / M[XB] <- AC
    BUN R2    / goto R2
    / M[P] += M[X]
LP, LDA XB    / AC <- M[XB]
    ADD P     / AC <- AC + M[P]
    STA P     / M[P] <- AC
    CLE       / E <- 0
    BUN LX    / goto LX
    // Multiplication finished
    // Addition starts
T1, LDA YD    / AC <- M[YD]
    STA Y     / M[Y] <- AC
    LDA P     / AC <- M[P]
    ADD C     / AC <- AC + M[C]
    STA P1    / M[P1] <- AC
    STA XB    / M[XB] <- AC

    // Modulus calculation starts
M2, LDA H     / AC <- M[H]
    CMA       / AC <- ~AC
    INC       / AC <- AC + 1
    STA NB    / M[NB] <- AC
M3, CLE       / E <- 0
    LDA P1    / AC <- M[P1]
    CIL       / AC <<= 1
    STA P1    / M[P1] <- AC
    LDA R     / AC <- M[R]
    CIL       / AC <<= 1
    STA R     / M[R] <- AC
    ADD NB    / AC <- AC + M[NB]
    SNA       / Skip if AC < 0
    STA R     / M[R] <- AC
    LDA Q     / AC <- M[Q]
    CIL       / AC <<= 1
    STA Q     / M[Q] <- AC
    ISZ K     / M[K] <- M[K] + 1; Skip if M[K] == 0
    BUN M3    / goto M3
    LDA KD    / AC <- M[KD]
    STA K     / M[K] <- AC
    LDA R     / AC <- M[R]
    STA XB
    STA M_R    / M[Y0] <- AC
    STA M_W    / M[Y1] <- AC
    STA SAY    /addition
    LDA HD     /addition
    STA H       /addition

CHX,LDA SAX
    ADD DX
    SZA
    BUN XY
CHY,LDA SAY
    ADD DY
    SZA
    BUN XY
    LDA XB
    INC
    STA XB
    BUN R1
XY, LDA SAX
    CMA
    INC
    STA DX
    LDA SAY
    CMA
    INC
    STA DY

R3, BSA M_RD
    SZA
    BUN R5   /AC == 1 
R4, LDA B
    BSA M_WR /set bomb
    LDA N
    ADD DE
    STA N
    LDA N
    SZA
    BUN R1
    BUN G_Bomb I

R5, LDA W
    ADD DE
    STA W
    LDA H
    ADD DE
    STA H
    BUN R1

/datas
NB, HEX 0    / M[NB] <- 0
R,  HEX 0    / M[R] <- 0
Q,  HEX 0    / M[Q] <- 0
K,  DEC -16     / M[K] <- -16
KD, DEC -16
X,  DEC 10     / M[X] = 8 (input)
XA, DEC 0 
XB, DEC 0
N,  DEC 0       / bomb
Y,  DEC 33797   / M[Y] = 33797 (multiplicand)
YD, DEC 33797   / M[YD] <- 33797 (for saving)
P,  DEC 0       / M[P] = 0 (multiplication result)
P1, DEC 0       / addition result
C,  DEC 1      / addend
B,  DEC -1
//addition
SAX,DEC 0  /save X
SAY,DEC 0  /save Y
DX, DEC 0  /make -X
DY, DEC 0  /make -Y
//addition finish

W,  DEC 14
WD, DEC 10
H,  DEC 16
HD, DEC 9
DE, DEC -1
/----------------------------

/--------Generate Number--------
G_NUM, HEX 0
    LDA G_H
    CMA
    INC
    STA H
    CLA
    STA N_R
    STA M_R
LOOP_H,
    LDA G_L
    CMA
    INC
    STA L
    CLA
    STA M_R
    LOOP_L,
        /if M[X][Y] == -1, M[X-1][Y], M[X+1][Y], M[X][Y-1], M[X][Y+1], M[X-1][Y-1], M[X-1][Y+1], M[X+1][Y-1], M[X+1][Y+1] += 1
        BSA M_RD
        SPA
        BSA ADD_CIRCLE
        ISZ M_R
        ISZ L
        BUN LOOP_L
    ISZ N_R
    ISZ H
    BUN LOOP_H
    BUN G_NUM I

ADD_CIRCLE, HEX 0
/store center
    LDA N_R
    STA N_C
    LDA M_R
    STA M_C
/M[X-1][Y]
    LDA N_C
    ADD VM1
    STA N_R
    STA N_W
    LDA M_C
    STA M_R
    STA M_W
    BSA TRY_ADD
/M[X+1][Y]
    LDA N_C
    ADD VH1
    STA N_R
    STA N_W
    LDA M_C
    STA M_R
    STA M_W
    BSA TRY_ADD
/M[X][Y-1]
    LDA N_C
    STA N_R
    STA N_W
    LDA M_C
    ADD VM1
    STA M_R
    STA M_W
    BSA TRY_ADD
/M[X][Y+1]
    LDA N_C
    STA N_R
    STA N_W
    LDA M_C
    ADD VH1
    STA M_R
    STA M_W
    BSA TRY_ADD
/M[X-1][Y-1]
    LDA N_C
    ADD VM1
    STA N_R
    STA N_W
    LDA M_C
    ADD VM1
    STA M_R
    STA M_W
    BSA TRY_ADD
/M[X-1][Y+1]
    LDA N_C
    ADD VM1
    STA N_R
    STA N_W
    LDA M_C
    ADD VH1
    STA M_R
    STA M_W
    BSA TRY_ADD
/M[X+1][Y-1]
    LDA N_C
    ADD VH1
    STA N_R
    STA N_W
    LDA M_C
    ADD VM1
    STA M_R
    STA M_W
    BSA TRY_ADD
/M[X+1][Y+1]
    LDA N_C
    ADD VH1
    STA N_R
    STA N_W
    LDA M_C
    ADD VH1
    STA M_R
    STA M_W
    BSA TRY_ADD
/return center
    LDA N_C
    STA N_R
    LDA M_C
    STA M_R
    BUN ADD_CIRCLE I

TRY_ADD, HEX 0
    LDA N_R
    SPA             /if N_R < 0, skip
    BUN TRY_ADD I
    LDA G_H           /if N_R >= H, skip
    CMA
    INC
    ADD N_R
    SNA
    BUN TRY_ADD I
    LDA M_R
    SPA             /if M_R < 0, skip
    BUN TRY_ADD I
    LDA G_L           /if M_R >= L, skip
    CMA
    INC
    ADD M_R
    SNA
    BUN TRY_ADD I
    BSA M_RD
    SPA             /if M[X][Y] == -1, skip
    BUN TRY_ADD I
    ADD VH1
    BSA M_WR
    BUN TRY_ADD I

L,  DEC 0
N_C,DEC 0
M_C,DEC 0
/-------------------------------

/--------Controler--------
CTL, HEX 0
    BSA SWP
    LDA G_X
    STA N_R
    LDA G_Y
    STA M_R
/check if the point is bomb
    BSA M_RD
    SPA
    ISZ END_FLAG
    BUN CTL I
/-------------------------------

/--------SWEEP and JUDGE--------
/--------sweep X, Y--------
SWP, HEX 0
    LDA G_X
    STA N_J
    LDA G_Y
    STA M_J
    BSA JUD
    SZE        /if sweeped, skip
    BUN SWP I
/reduce STEP_REMAIN
    ISZ STEP_REMAIN
    SZE
    ISZ END_FLAG
/sweep
    LDA M_J
    ADD VH1
    CMA
    INC
    STA CNT
    CLE
    CLA
    CME
L_S,CIR
    ISZ CNT
    BUN L_S
    ADD SPO I
    STA SPO I
    BUN SWP I
/--------judge if the point is sweeped--------
/how to use(judge if the point is sweeped)
/BSA JUD
N_J, DEC 0
M_J, DEC 0
/result: E=1 if sweeped, E=0 if not sweeped
JUD, HEX 0         /return address
    LDA N_J      /load n
    ADD SPO0        /turn to X line
    STA SPO
    LDA M_J      /load m
    ADD VH1        /M++
    CMA
    INC
    STA CNT         /set counter
    LDA SPO I       /load X line
L_J,CIL             /turn to Y column
    ISZ CNT
    BUN L_J
    BUN JUD I      /return
/---------------------------------------------

/--------OUTPUT--------
PRINT_MAP, HEX 0
    SIO
    LDA VH0A    /enter
    OUT
    LDA G_H
    CMA
    INC
    STA H
    CLA
    STA N_J
    STA M_J
P_LOOP_H,
    LDA G_L
    CMA
    INC
    STA L
    CLA
    STA M_J
    /-----------------

    /-----------------
    P_LOOP_L,
        BSA TRY_OUT
        ISZ M_J
        /-------------------

        /-------------------
        ISZ L
        BUN P_LOOP_L
    ISZ N_J
    LDA VH0A
    OUT
    ISZ H
    BUN P_LOOP_H
    LDA VH0A
    OUT
    BUN PRINT_MAP I

TRY_OUT, HEX 0
    BSA JUD
/if unsweeped, print'/'
    SZE
    BUN OUT_IT
    BUN OUT_VOID
OUT_IT,
    LDA N_J
    STA N_R
    LDA M_J
    STA M_R
    BSA M_RD
/if AC==-1, print'*'
    SPA
    BUN OUT_STAR
/if AC==0, print' '
    SZA
    BUN OUT_DIGIT
    LDA VH20    / ' '
    OUT
    BUN TRY_OUT I
OUT_DIGIT,
    ADD VH30    / 0 to '0'
    OUT
    BUN TRY_OUT I
OUT_STAR,
    LDA VH2A    / '*'
    OUT
    BUN TRY_OUT I
OUT_VOID,
    LDA VH2F    / '/'
    OUT
    BUN TRY_OUT I
/----------------------

/--------READ and WRITE AC from/to MAP--------
/--------read AC from map-------
/how to use(read AC from MP[N_R][M_R])
N_R, DEC 0
M_R, DEC 0
M_RD, HEX 0         /return address
    LDA N_R         /load n
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
SK1,LDA M_R      /load m
    ADD PO
    STA PO          /add m to pointer
    LDA PO I        /load AC
    STA TMP         /save AC
    /initialize pointer
    LDA PO0
    STA PO
    LDA TMP         /load AC
    BUN M_RD I      /return
/--------write AC to map--------
/how to use(write AC to MP[N_W][M_W])
N_W, DEC 0
M_W, DEC 0
M_WR, HEX 0         /return address
    STA TMP         /save AC
    LDA N_W         /load n
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
SK0,LDA M_W     /load m
    ADD PO
    STA PO          /add m to pointer
    LDA TMP         /load AC
    STA PO I        /write AC to map
    /initialize pointer
    LDA PO0
    STA PO
    LDA TMP         /load AC
    BUN M_WR I      /return
/--------------------------------------

/--------DATA------------
G_N, DEC 16
G_L, DEC 16
G_H, DEC 16
G_X, DEC 0
G_Y, DEC 0
TMP,HEX 0           /temporary data
CNT,HEX 0           /counter
END_FLAG,HEX 0      /end flag
STEP_REMAIN,HEX 0   /step remain
/-------read-only data-------
VH0, HEX 0
VH1, HEX 1
VH2, HEX 2
VM1, DEC -1
VM2, DEC -2
VM3, DEC -3
VM4, DEC -4
VH0A, HEX 0A    / enter
VH20, HEX 20    / ' '
VH2A, HEX 2A    / '*'
VH2F, HEX 2F    / '/'
VH30, HEX 30    / '0'
VM48, DEC -48   / -'0'
/sweep-map
SPO,SYM SMP /sweep-map pointer
SPO0,SYM SMP /pointer initial value
SMP,HEX 0000
    HEX 0000
    HEX 0000
    HEX 0000
    HEX 0000
    HEX 0000
    HEX 0000
    HEX 0000
    HEX 0000
    HEX 0000
    HEX 0000
    HEX 0000
    HEX 0000
    HEX 0000
    HEX 0000
    HEX 0000
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