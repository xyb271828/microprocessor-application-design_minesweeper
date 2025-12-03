    ORG 0           / interrupt entry point
ST0, HEX 0         / interrupt return address
    BUN I_HND      / go to interrupt handler (I_HND)

    ORG 10          / program entry point
INI,
    LDA VM3         / AC <- -3
    STA STT         / M[STT] <- -3
/open the output
    LDA VH4         / AC <- 4
    IMK             / IMSK <- (1000) (S_IN enabled)
    SIO             / IOT <- 1 (serial-IO selected)
    ION             / enable interrupt
L0, LDA STT            / AC <- M[STT]
    SPA             / (M[STT] >= 0) ? skip next
    BUN L0
    HLT

/--------interrupt handler--------
/ 1. store AC & E to memory
I_HND, STA BA        / M[BA] <- AC    (store AC)
    CIL                / AC[0] <- E    (AC[15:1] is not important here...)
    STA BE            / M[BE] <- AC    (store E)
/ 2. check SFG and S_IN
SIN,
    LDA SFG            / AC <- M[SFG]
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
    ISZ SFG            / ++M[SFG]
    ISZ STT         / ++M[STT]
/ 3. check GP_OUT
SOU,
    SKO                / (S_OUT ready) ? skip next
    BUN IRT            / goto IRT
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
    STA SFG            / M[SFG] <- 0
/ 4. restore AC & E from memory
IRT, LDA BE        / AC <- M[BE]
    CIR                / E <- AC[0]    (restore E)
    LDA BA            / AC <- M[BA]    (restore AC)
    ION                / IEN <- 1        (enable interrupt)
    BUN ST0 I        / indirect return (return address stored in ST0)
    

/ Data storage
BA, DEC 0
BE, DEC 0
STT, DEC 0        / state
SFG, DEC 3        / flag
INPUT_ADDR, SYM INPUT1
INPUT1, DEC 78
INPUT2, DEC 72
INPUT3, DEC 76
VM3, DEC -3
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
END


