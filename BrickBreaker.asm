
INCLUDE Irvine32.inc
.STACK 4096

; ---- Color constants ----
BLACK         = 0
DARK_BLUE     = 1
DARK_GREEN    = 2
DARK_CYAN     = 3
DARK_RED      = 4
DARK_MAGENTA  = 5
BROWN         = 6
LIGHT_GRAY    = 7
DARK_GRAY     = 8
LIGHT_BLUE    = 9
LIGHT_GREEN   = 10
LIGHT_CYAN    = 11
LIGHT_RED     = 12
LIGHT_MAGENTA = 13
YELLOW        = 14
WHITE         = 15

; ---- Key codes ----
EXT_PREFIX_DOS = 0
EXT_PREFIX_WIN = 0E0h
KEY_UP         = 48h
KEY_DOWN       = 50h
KEY_LEFT       = 4Bh
KEY_RIGHT      = 4Dh
KEY_ENTER      = 0Dh
KEY_ESCAPE     = 1Bh
KEY_BACKSPACE  = 08h
KEY_A          = 61h
KEY_D          = 64h
KEY_P          = 70h

; ---- Menu constants ----
MENU_START    = 0
MENU_INST     = 1
MENU_HIGH     = 2
MENU_EXIT     = 3
MENU_COUNT    = 4

; ---- Game area boundaries ----
GAME_LEFT     = 1
GAME_RIGHT    = 78
GAME_TOP      = 2
GAME_BOTTOM   = 22
HUD_ROW       = 1

; ---- Paddle constants ----
PADDLE_WIDTH_NORMAL = 12
PADDLE_WIDTH_MED    = 10
PADDLE_WIDTH_SMALL  = 8
PADDLE_WIDTH_BIG    = 18
PADDLE_ROW    = 21
PADDLE_MIN    = 2
PADDLE_MAX    = 66
PADDLE_SPEED  = 3

; ---- Ball constants ----
BALL_START_COL = 39
BALL_START_ROW = 14

; ---- Brick grid constants ----
BRICK_ROWS_L1 = 3        ; Level 1: 3 rows
BRICK_ROWS    = 4        ; Level 2: 4 rows
BRICK_ROWS_L3 = 5        ; Level 3: 5 rows
BRICK_COLS    = 10
BRICK_COL_START = 2
BRICK_W       = 7
BRICK_ROW_START = 3
BRICK_H       = 2

; ---- Delay constants per level ----
DELAY_L1      = 55
DELAY_L2      = 38
DELAY_L3      = 22

; ---- Power-up types ----
PWR_NONE      = 0
PWR_SLOWBALL  = 1
PWR_EXTRALIFE = 2
PWR_BIGPADDLE = 3

; ---- Power-up constants ----
PWR_CHAR_SLOW = 'S'
PWR_CHAR_LIFE = 'L'
PWR_CHAR_BIG  = 'B'

; ---- High score count ----
HS_COUNT      = 5

; ============================================================
; .DATA
; ============================================================
.DATA

    ; ---- Player / game state ----
    playerName     BYTE 30 DUP(0)
    nameLen        DWORD 0
    selectedOption BYTE MENU_START
    score          DWORD 0
    lives          BYTE 3
    level          BYTE 1
    paused         BYTE 0

    ; ---- Frame delay ----
    frameDelay     DWORD DELAY_L1

    ; ---- Paddle state ----
    paddleX        BYTE 34
    paddleWidth    BYTE PADDLE_WIDTH_NORMAL
    paddleSpeed    BYTE 3

    ; ---- Timers ----
    bigPaddleTimer DWORD 0
    slowBallTimer  DWORD 0

    ; ---- Ball state ----
    ballX          BYTE BALL_START_COL
    ballY          BYTE BALL_START_ROW
    ballDX         SBYTE 1
    ballDY         SBYTE -1
    ballActive     BYTE 1

    ; ---- Power-up state ----
    pwrActive      BYTE PWR_NONE
    pwrX           BYTE 0
    pwrY           BYTE 0
    pwrFrameCnt    DWORD 0

    ; ---- Random seed ----
    randSeed       DWORD 12345

    ; ---- Brick layouts ----

    ; Level 1: Easy intro — 3 rows, simple full grid
    ; 30 bricks total, wide paddle, slow ball
    ; Player learns ball physics with no tricks
    lvl1Bricks BYTE 1,1,1,1,1,1,1,1,1,1
               BYTE 1,1,1,1,1,1,1,1,1,1
               BYTE 1,1,1,1,1,1,1,1,1,1

    ; Level 2: Hard — 4 rows, checkerboard fortress pattern
    ; Alternating gaps force ball into unpredictable angles.
    ; The gaps are NOT escape routes — ball ricochets through
    ; the holes and bounces back at sharp unexpected angles,
    ; making it very hard to predict where it will go next.
    ; 28 bricks total but much harder to clear than Level 1.
    lvl2Bricks BYTE 1,0,1,0,1,0,1,0,1,0
               BYTE 0,1,0,1,0,1,0,1,0,1
               BYTE 1,0,1,0,1,0,1,0,1,0
               BYTE 0,1,0,1,0,1,0,1,0,1

    ; Level 3: Hardest — 5 rows, nearly full with trap gaps
    ; Only 6 holes total, placed to funnel ball into corners.
    ; Corner gaps cause extreme angle bounces that are nearly
    ; impossible to track at Level 3 speed (22ms delay).
    ; 44 bricks + smallest paddle + fastest ball = brutal.
lvl3Bricks   BYTE 1,1,1,1,1,1,1,1,1,1
               BYTE 1,1,1,1,1,1,1,1,1,1
               BYTE 1,1,0,1,1,1,1,0,1,1
               BYTE 1,1,1,1,1,1,1,1,1,1
               BYTE 1,0,1,1,1,1,1,1,0,1
               
    ; brickAlive holds up to 5 rows x 10 cols = 50 bytes
    brickAlive     BYTE 50 DUP(0)

    ; ---- High Score Table ----
    hsName1  BYTE "Ahmed Ali           ", 0, 0, 0, 0
    hsScore1 DWORD 400
    hsName2  BYTE "Sara Khan           ", 0, 0, 0, 0
    hsScore2 DWORD 390
    hsName3  BYTE "Usman Raza          ", 0, 0, 0, 0
    hsScore3 DWORD 350
    hsName4  BYTE "Fatima Noor         ", 0, 0, 0, 0
    hsScore4 DWORD 310
    hsName5  BYTE "Bilal Tariq         ", 0, 0, 0, 0
    hsScore5 DWORD 300

    ; Parallel arrays for easier access
    hsNamePtrs  DWORD OFFSET hsName1, OFFSET hsName2, OFFSET hsName3,
                      OFFSET hsName4, OFFSET hsName5
    hsScorePtrs DWORD OFFSET hsScore1, OFFSET hsScore2, OFFSET hsScore3,
                      OFFSET hsScore4, OFFSET hsScore5

    ; ---- HUD strings ----
    str_hudScore  BYTE " SCR:", 0
    str_hudLives  BYTE " LVS:", 0
    str_hudLevel  BYTE " LVL:", 0
    str_hudPlayer BYTE " PLR:", 0

    ; ---- HOME SCREEN strings ----
    bk1  BYTE " ____  ____  ___   ____  _  __", 0
    bk2  BYTE "| __ )|  _ \|_ _| / ___|| |/ /", 0
    bk3  BYTE "|  _ \| |_) || | | |    | ' / ", 0
    bk4  BYTE "| |_) |  _ < | | | |___ | . \ ", 0
    bk5  BYTE "|____/|_| \_\___| \____||_|\_\", 0

    br1  BYTE " ____  ____  ___    _   _  _  ____  ____  ", 0
    br2  BYTE "| __ )|  _ \| __|  / \ | |/ /| ___||  _ \ ", 0
    br3  BYTE "|  _ \| |_) |  _| / _ \|   < |  _| | |_) |", 0
    br4  BYTE "| |_) |  _ <| |__/ ___ \ . \ | |___| |  < ", 0
    br5  BYTE "|____/|_| \_\____/_/   \_\_|\_\_____|_| \_\", 0

    str_pressKey    BYTE "     >>> Press any key to start <<<", 0
    str_homeTag     BYTE "       ~ A Console Arcade Game ~", 0

    ; ---- Name input strings ----
    str_nameBorder BYTE "+================================================+", 0
    str_nameTitle  BYTE "|         ** ENTER YOUR PLAYER NAME **          |", 0
    str_namePrompt BYTE "  >> Name: ", 0
    str_nameInstr1 BYTE "  Type your name then press ENTER to continue", 0
    str_nameInstr2 BYTE "  Press BACKSPACE to delete a character", 0
    str_nameWarn   BYTE "  !! Name cannot be empty !!                 ", 0
    str_cursor     BYTE "_", 0

    ; ---- Main menu strings ----
    str_menuTop   BYTE "+==============================================+", 0
    str_menuTitle BYTE "|      B R I C K   B R E A K E R              |", 0
    str_menuSub   BYTE "|            M A I N   M E N U                |", 0
    str_menuBot   BYTE "+==============================================+", 0
    str_opt0      BYTE "        [ 1 ]   Start Game          ", 0
    str_opt1      BYTE "        [ 2 ]   Instructions        ", 0
    str_opt2      BYTE "        [ 3 ]   High Scores         ", 0
    str_opt3      BYTE "        [ 4 ]   Exit Game           ", 0
    str_arrow     BYTE "  -->  ", 0
    str_menuWelc  BYTE "  Welcome, ", 0
    str_menuExcl  BYTE "!  Good luck!", 0
    str_menuNav   BYTE "    UP / DOWN arrows then ENTER to select", 0

    ; ---- Instructions strings ----
    str_instTop   BYTE "+===========================================+", 0
    str_instTitle BYTE "|           GAME  INSTRUCTIONS             |", 0
    str_instBot   BYTE "+===========================================+", 0
    str_sec1      BYTE "  [ CONTROLS ]", 0
    str_ic1       BYTE "  LEFT  Arrow / A  -->  Move paddle left", 0
    str_ic2       BYTE "  RIGHT Arrow / D  -->  Move paddle right", 0
    str_ic3       BYTE "  P                -->  Pause / Resume", 0
    str_ic4       BYTE "  ESC              -->  Return to menu", 0
    str_sec2      BYTE "  [ OBJECTIVE ]", 0
    str_io1       BYTE "  Bounce the ball to destroy all bricks.", 0
    str_io2       BYTE "  Clear all bricks to reach the next level.", 0
    str_io3       BYTE "  Don't let the ball fall below the paddle!", 0
    str_sec3      BYTE "  [ SCORING ]", 0
    str_ib1       BYTE "  Each brick destroyed = +10 points", 0
    str_sec4      BYTE "  [ POWER-UPS ]", 0
    str_ip1       BYTE "  S = Slow Ball   (catch with paddle)", 0
    str_ip2       BYTE "  L = Extra Life  (catch with paddle)", 0
    str_ip3       BYTE "  B = Big Paddle  (catch with paddle)", 0
    str_instBack  BYTE "  [ Press ESC to return to Main Menu ]", 0

    ; ---- High scores strings ----
    str_hsTop     BYTE "+===========================================+", 0
    str_hsTitle   BYTE "|           T O P   S C O R E S           |", 0
    str_hsBot     BYTE "+===========================================+", 0
    str_hsColH    BYTE "   RANK    NAME                    SCORE", 0
    str_hsDivide  BYTE "   ----    --------------------    -----", 0
    str_hsRank1   BYTE "   #1   ", 0
    str_hsRank2   BYTE "   #2   ", 0
    str_hsRank3   BYTE "   #3   ", 0
    str_hsRank4   BYTE "   #4   ", 0
    str_hsRank5   BYTE "   #5   ", 0
    str_hsBack    BYTE "  [ Press ESC to return to Main Menu ]", 0

    ; ---- Level transition strings ----
    str_lvlClr1   BYTE "  *****  LEVEL COMPLETE!  *****", 0
    str_lvlClr2   BYTE "  Prepare for the next challenge...", 0
    str_lvlClr3   BYTE "  Press ENTER to continue", 0

    ; ---- Pause string ----
    str_paused    BYTE "  ** PAUSED - Press P to Resume **", 0

    ; ---- Win screen strings ----
    str_win1   BYTE "  __   __ ___  _   _   __        ___  _   _  _ ", 0
    str_win2   BYTE "  \ \ / // _ \| | | | \ \      / /_ \| \ | || |", 0
    str_win3   BYTE "   \ V /| | | | | | |  \ \ /\ / / | ||  \| || |", 0
    str_win4   BYTE "    | | | |_| | |_| |   \ V  V /  | || |\  ||_|", 0
    str_win5   BYTE "    |_|  \___/ \___/     \_/\_/  |___||_| \_|(_)", 0
    str_winSub BYTE "    Congratulations! You cleared ALL 3 Levels!", 0
    str_winScr BYTE "         Final Score: ", 0
    str_winPly BYTE "       Player: ", 0
    str_winRet BYTE "    [ Press ENTER to return to Main Menu ]", 0

    ; ---- Game over strings ----
    str_goTitle   BYTE "  GGGGG    A    M   M  EEEEE", 0
    str_goTitle2  BYTE " G        A A   MM MM  E    ", 0
    str_goTitle3  BYTE " G  GG   AAAAA  M M M  EEEE ", 0
    str_goTitle4  BYTE " G   G  A     A M   M  E    ", 0
    str_goTitle5  BYTE "  GGGGG A     A M   M  EEEEE", 0
    str_goOver1   BYTE "  OOO   V   V  EEEEE  RRRR  ", 0
    str_goOver2   BYTE " O   O  V   V  E      R   R ", 0
    str_goOver3   BYTE " O   O  V   V  EEEE   RRRR  ", 0
    str_goOver4   BYTE " O   O   V V   E      R  R  ", 0
    str_goOver5   BYTE "  OOO     V    EEEEE  R   R ", 0
    str_goScore   BYTE "         Final Score: ", 0
    str_goPlay    BYTE "       Player: ", 0
    str_goRetry   BYTE "    [ Press ENTER to return to Main Menu ]", 0

    ; ---- Power-up HUD label ----
    str_pwrHud   BYTE " PWR:", 0
    str_pwrNone  BYTE "NONE      ", 0
    str_pwrSlow  BYTE "SLOW BALL ", 0
    str_pwrLife  BYTE "EXTRA LIFE", 0
    str_pwrBig   BYTE "BIG PADDLE", 0

    ; Blank line
    str_blank     BYTE "                                                                                ", 0

; ============================================================
; .CODE
; ============================================================
.CODE

; ------------------------------------------------------------
; DrawLine: draws 80 '=' chars on row DH
; ------------------------------------------------------------
DrawLine PROC
    push eax
    push ecx
    push edx
    call SetTextColor
    mov  dl, 0
    call Gotoxy
    mov  ecx, 80
drawLineLoop:
    mov  al, '='
    call WriteChar
    loop drawLineLoop
    pop  edx
    pop  ecx
    pop  eax
    ret
DrawLine ENDP

; ------------------------------------------------------------
; DrawStars: draws 80 '*' chars on row DH
; ------------------------------------------------------------
DrawStars PROC
    push eax
    push ecx
    push edx
    call SetTextColor
    mov  dl, 0
    call Gotoxy
    mov  ecx, 80
drawStarsLoop:
    mov  al, '*'
    call WriteChar
    loop drawStarsLoop
    pop  edx
    pop  ecx
    pop  eax
    ret
DrawStars ENDP

; ------------------------------------------------------------
; DelayRoutine: sleeps frameDelay ms
; ------------------------------------------------------------
DelayRoutine PROC
    push eax
    cmp  slowBallTimer, 0
    jle  delayNormal
    mov  eax, frameDelay
    add  eax, 25
    call Delay
    jmp  delayDone
delayNormal:
    mov  eax, frameDelay
    call Delay
delayDone:
    pop  eax
    ret
DelayRoutine ENDP

; ------------------------------------------------------------
; RandByte: LCG random, returns 0..99 in EAX
; ------------------------------------------------------------
RandByte PROC
    push edx
    mov  eax, randSeed
    imul eax, 1664525
    add  eax, 1013904223
    mov  randSeed, eax
    xor  edx, edx
    mov  ecx, 100
    div  ecx
    mov  eax, edx
    pop  edx
    ret
RandByte ENDP

; ============================================================
; SCREEN 1: HomeScreen
; ============================================================
HomeScreen PROC
    call Clrscr

    mov  eax, YELLOW
    mov  dh, 0
    call DrawStars
    mov  dh, 24
    call DrawStars

    mov  eax, YELLOW
    call SetTextColor

    mov  dl, 4
    mov  dh, 2
    call Gotoxy
    mov  edx, OFFSET bk1
    call WriteString

    mov  dl, 4
    mov  dh, 3
    call Gotoxy
    mov  edx, OFFSET bk2
    call WriteString

    mov  dl, 4
    mov  dh, 4
    call Gotoxy
    mov  edx, OFFSET bk3
    call WriteString

    mov  dl, 4
    mov  dh, 5
    call Gotoxy
    mov  edx, OFFSET bk4
    call WriteString

    mov  dl, 4
    mov  dh, 6
    call Gotoxy
    mov  edx, OFFSET bk5
    call WriteString

    mov  eax, LIGHT_CYAN
    call SetTextColor

    mov  dl, 0
    mov  dh, 9
    call Gotoxy
    mov  edx, OFFSET br1
    call WriteString

    mov  dl, 0
    mov  dh, 10
    call Gotoxy
    mov  edx, OFFSET br2
    call WriteString

    mov  dl, 0
    mov  dh, 11
    call Gotoxy
    mov  edx, OFFSET br3
    call WriteString

    mov  dl, 0
    mov  dh, 12
    call Gotoxy
    mov  edx, OFFSET br4
    call WriteString

    mov  dl, 0
    mov  dh, 13
    call Gotoxy
    mov  edx, OFFSET br5
    call WriteString

    mov  eax, LIGHT_GRAY
    call SetTextColor
    mov  dl, 1
    mov  dh, 16
    call Gotoxy
    mov  edx, OFFSET str_homeTag
    call WriteString

    mov  eax, DARK_GRAY
    mov  dh, 18
    call DrawLine

    mov  eax, LIGHT_GREEN
    call SetTextColor
    mov  dl, 16
    mov  dh, 20
    call Gotoxy
    mov  edx, OFFSET str_pressKey
    call WriteString

    call ReadChar
    ret
HomeScreen ENDP

; ============================================================
; SCREEN 2: NameInputScreen
; ============================================================
NameInputScreen PROC
    push ecx
    push edi

    ; Clear name buffer
    mov  ecx, 30
    mov  edi, OFFSET playerName
    xor  eax, eax
    rep  stosb
    pop  edi
    pop  ecx
    mov  nameLen, 0

    call Clrscr

    mov  eax, LIGHT_CYAN
    mov  dh, 0
    call DrawStars
    mov  dh, 24
    call DrawStars

    mov  eax, YELLOW
    call SetTextColor
    mov  dl, 14
    mov  dh, 5
    call Gotoxy
    mov  edx, OFFSET str_nameBorder
    call WriteString

    mov  eax, LIGHT_CYAN
    call SetTextColor
    mov  dl, 14
    mov  dh, 6
    call Gotoxy
    mov  edx, OFFSET str_nameTitle
    call WriteString

    mov  eax, YELLOW
    call SetTextColor
    mov  dl, 14
    mov  dh, 7
    call Gotoxy
    mov  edx, OFFSET str_nameBorder
    call WriteString

    mov  eax, LIGHT_GRAY
    call SetTextColor
    mov  dl, 14
    mov  dh, 12
    call Gotoxy
    mov  edx, OFFSET str_nameInstr1
    call WriteString

    mov  dl, 14
    mov  dh, 13
    call Gotoxy
    mov  edx, OFFSET str_nameInstr2
    call WriteString

    mov  eax, WHITE
    call SetTextColor
    mov  dl, 14
    mov  dh, 10
    call Gotoxy
    mov  edx, OFFSET str_namePrompt
    call WriteString

nameLoop:
    ; Redraw name field
    mov  dl, 25
    mov  dh, 10
    call Gotoxy
    mov  eax, BLACK
    call SetTextColor
    mov  edx, OFFSET str_blank
    call WriteString

    mov  dl, 25
    mov  dh, 10
    call Gotoxy
    mov  eax, YELLOW
    call SetTextColor
    mov  edx, OFFSET playerName
    call WriteString

    ; Draw cursor right after name
    mov  eax, nameLen
    add  eax, 25
    mov  dl, al
    mov  dh, 10
    call Gotoxy
    mov  eax, LIGHT_GREEN
    call SetTextColor
    mov  edx, OFFSET str_cursor
    call WriteString

    call ReadChar

    cmp  al, KEY_ENTER
    je   nameTryDone
    cmp  al, KEY_BACKSPACE
    je   nameBack

    ; Printable ASCII only (space=32 to tilde=126)
    cmp  al, 32
    jl   nameLoop
    cmp  al, 126
    jg   nameLoop

    ; Max 20 chars
    mov  ebx, nameLen
    cmp  ebx, 20
    jge  nameLoop

    mov  edi, OFFSET playerName
    add  edi, ebx
    mov  [edi], al
    inc  nameLen
    ; Clear warning if visible
    mov  eax, BLACK
    call SetTextColor
    mov  dl, 14
    mov  dh, 15
    call Gotoxy
    mov  edx, OFFSET str_nameWarn
    call WriteString
    jmp  nameLoop

nameBack:
    cmp  nameLen, 0
    je   nameLoop
    dec  nameLen
    mov  ebx, nameLen
    mov  edi, OFFSET playerName
    add  edi, ebx
    mov  BYTE PTR [edi], 0
    jmp  nameLoop

nameTryDone:
    ; Block if name is empty
    cmp  nameLen, 0
    jne  nameRet
    ; Show warning
    mov  eax, LIGHT_RED
    call SetTextColor
    mov  dl, 14
    mov  dh, 15
    call Gotoxy
    mov  edx, OFFSET str_nameWarn
    call WriteString
    jmp  nameLoop

nameRet:
    ret
NameInputScreen ENDP

; ============================================================
; DrawMenu
; ============================================================
DrawMenu PROC
    push eax
    push edx

    movzx eax, selectedOption
    cmp   eax, MENU_START
    jne   opt0_unsel

    mov   eax, YELLOW
    call  SetTextColor
    mov   dl, 8
    mov   dh, 13
    call  Gotoxy
    mov   edx, OFFSET str_arrow
    call  WriteString
    mov   edx, OFFSET str_opt0
    call  WriteString
    jmp   opt1_check

opt0_unsel:
    mov   eax, LIGHT_GRAY
    call  SetTextColor
    mov   dl, 14
    mov   dh, 13
    call  Gotoxy
    mov   edx, OFFSET str_opt0
    call  WriteString

opt1_check:
    movzx eax, selectedOption
    cmp   eax, MENU_INST
    jne   opt1_unsel

    mov   eax, YELLOW
    call  SetTextColor
    mov   dl, 8
    mov   dh, 15
    call  Gotoxy
    mov   edx, OFFSET str_arrow
    call  WriteString
    mov   edx, OFFSET str_opt1
    call  WriteString
    jmp   opt2_check

opt1_unsel:
    mov   eax, LIGHT_GRAY
    call  SetTextColor
    mov   dl, 14
    mov   dh, 15
    call  Gotoxy
    mov   edx, OFFSET str_opt1
    call  WriteString

opt2_check:
    movzx eax, selectedOption
    cmp   eax, MENU_HIGH
    jne   opt2_unsel

    mov   eax, YELLOW
    call  SetTextColor
    mov   dl, 8
    mov   dh, 17
    call  Gotoxy
    mov   edx, OFFSET str_arrow
    call  WriteString
    mov   edx, OFFSET str_opt2
    call  WriteString
    jmp   opt3_check

opt2_unsel:
    mov   eax, LIGHT_GRAY
    call  SetTextColor
    mov   dl, 14
    mov   dh, 17
    call  Gotoxy
    mov   edx, OFFSET str_opt2
    call  WriteString

opt3_check:
    movzx eax, selectedOption
    cmp   eax, MENU_EXIT
    jne   opt3_unsel

    mov   eax, YELLOW
    call  SetTextColor
    mov   dl, 8
    mov   dh, 19
    call  Gotoxy
    mov   edx, OFFSET str_arrow
    call  WriteString
    mov   edx, OFFSET str_opt3
    call  WriteString
    jmp   drawDone

opt3_unsel:
    mov   eax, LIGHT_GRAY
    call  SetTextColor
    mov   dl, 14
    mov   dh, 19
    call  Gotoxy
    mov   edx, OFFSET str_opt3
    call  WriteString

drawDone:
    pop  edx
    pop  eax
    ret
DrawMenu ENDP

; ============================================================
; SCREEN 3: MainMenuScreen
; ============================================================
MainMenuScreen PROC
    call Clrscr

    mov  eax, LIGHT_MAGENTA
    mov  dh, 0
    call DrawStars
    mov  dh, 24
    call DrawStars

    mov  eax, LIGHT_MAGENTA
    call SetTextColor
    mov  dl, 15
    mov  dh, 4
    call Gotoxy
    mov  edx, OFFSET str_menuTop
    call WriteString

    mov  eax, YELLOW
    call SetTextColor
    mov  dl, 15
    mov  dh, 5
    call Gotoxy
    mov  edx, OFFSET str_menuTitle
    call WriteString

    mov  eax, LIGHT_CYAN
    call SetTextColor
    mov  dl, 15
    mov  dh, 6
    call Gotoxy
    mov  edx, OFFSET str_menuSub
    call WriteString

    mov  eax, LIGHT_MAGENTA
    call SetTextColor
    mov  dl, 15
    mov  dh, 7
    call Gotoxy
    mov  edx, OFFSET str_menuBot
    call WriteString

    mov  eax, LIGHT_GREEN
    call SetTextColor
    mov  dl, 15
    mov  dh, 10
    call Gotoxy
    mov  edx, OFFSET str_menuWelc
    call WriteString
    mov  edx, OFFSET playerName
    call WriteString
    mov  edx, OFFSET str_menuExcl
    call WriteString

    mov  eax, DARK_GRAY
    call SetTextColor
    mov  dl, 15
    mov  dh, 22
    call Gotoxy
    mov  edx, OFFSET str_menuNav
    call WriteString

    mov  selectedOption, MENU_START
    call DrawMenu

menuLoop:
    call ReadKey
    jz   menuLoop
    cmp  al, 0
    je   checkScan
    cmp  al, KEY_ENTER
    je   menuConfirm
    jmp  menuLoop

checkScan:
    cmp  ah, 48h
    je   doMoveUp
    cmp  ah, 50h
    je   doMoveDown
    jmp  menuLoop

doMoveUp:
    cmp  selectedOption, 0
    je   wrapToBottom
    dec  selectedOption
    jmp  redrawMenu

wrapToBottom:
    mov  selectedOption, MENU_COUNT - 1
    jmp  redrawMenu

doMoveDown:
    cmp  selectedOption, MENU_COUNT - 1
    je   wrapToTop
    inc  selectedOption
    jmp  redrawMenu

wrapToTop:
    mov  selectedOption, 0

redrawMenu:
    call DrawMenu
    jmp  menuLoop

menuConfirm:
    movzx eax, selectedOption
    ret
MainMenuScreen ENDP

; ============================================================
; SCREEN 4: InstructionsScreen
; ============================================================
InstructionsScreen PROC
    call Clrscr

    mov  eax, LIGHT_CYAN
    mov  dh, 0
    call DrawStars
    mov  dh, 24
    call DrawStars

    mov  eax, LIGHT_CYAN
    call SetTextColor
    mov  dl, 16
    mov  dh, 1
    call Gotoxy
    mov  edx, OFFSET str_instTop
    call WriteString

    mov  eax, YELLOW
    call SetTextColor
    mov  dl, 16
    mov  dh, 2
    call Gotoxy
    mov  edx, OFFSET str_instTitle
    call WriteString

    mov  eax, LIGHT_CYAN
    call SetTextColor
    mov  dl, 16
    mov  dh, 3
    call Gotoxy
    mov  edx, OFFSET str_instBot
    call WriteString

    mov  eax, YELLOW
    call SetTextColor
    mov  dl, 6
    mov  dh, 4
    call Gotoxy
    mov  edx, OFFSET str_sec1
    call WriteString

    mov  eax, WHITE
    call SetTextColor

    mov  dl, 6
    mov  dh, 5
    call Gotoxy
    mov  edx, OFFSET str_ic1
    call WriteString

    mov  dl, 6
    mov  dh, 6
    call Gotoxy
    mov  edx, OFFSET str_ic2
    call WriteString

    mov  dl, 6
    mov  dh, 7
    call Gotoxy
    mov  edx, OFFSET str_ic3
    call WriteString

    mov  dl, 6
    mov  dh, 8
    call Gotoxy
    mov  edx, OFFSET str_ic4
    call WriteString

    mov  eax, LIGHT_GREEN
    call SetTextColor
    mov  dl, 6
    mov  dh, 9
    call Gotoxy
    mov  edx, OFFSET str_sec2
    call WriteString

    mov  eax, WHITE
    call SetTextColor

    mov  dl, 6
    mov  dh, 10
    call Gotoxy
    mov  edx, OFFSET str_io1
    call WriteString

    mov  dl, 6
    mov  dh, 11
    call Gotoxy
    mov  edx, OFFSET str_io2
    call WriteString

    mov  dl, 6
    mov  dh, 12
    call Gotoxy
    mov  edx, OFFSET str_io3
    call WriteString

    mov  eax, LIGHT_MAGENTA
    call SetTextColor
    mov  dl, 6
    mov  dh, 13
    call Gotoxy
    mov  edx, OFFSET str_sec3
    call WriteString

    mov  eax, YELLOW
    call SetTextColor
    mov  dl, 6
    mov  dh, 14
    call Gotoxy
    mov  edx, OFFSET str_ib1
    call WriteString

    mov  eax, LIGHT_CYAN
    call SetTextColor
    mov  dl, 6
    mov  dh, 15
    call Gotoxy
    mov  edx, OFFSET str_sec4
    call WriteString

    mov  eax, WHITE
    call SetTextColor
    mov  dl, 6
    mov  dh, 16
    call Gotoxy
    mov  edx, OFFSET str_ip1
    call WriteString

    mov  dl, 6
    mov  dh, 17
    call Gotoxy
    mov  edx, OFFSET str_ip2
    call WriteString

    mov  dl, 6
    mov  dh, 18
    call Gotoxy
    mov  edx, OFFSET str_ip3
    call WriteString

    mov  eax, LIGHT_RED
    call SetTextColor
    mov  dl, 6
    mov  dh, 22
    call Gotoxy
    mov  edx, OFFSET str_instBack
    call WriteString

instWait:
    call ReadChar
    cmp  al, KEY_ESCAPE
    jne  instWait
    ret
InstructionsScreen ENDP

; ============================================================
; SCREEN 5: HighScoreScreen
; ============================================================
HighScoreScreen PROC
    push eax
    push ebx
    push edx

    call Clrscr

    mov  eax, YELLOW
    mov  dh, 0
    call DrawStars
    mov  dh, 24
    call DrawStars

    mov  eax, YELLOW
    call SetTextColor
    mov  dl, 16
    mov  dh, 2
    call Gotoxy
    mov  edx, OFFSET str_hsTop
    call WriteString

    mov  dl, 16
    mov  dh, 3
    call Gotoxy
    mov  edx, OFFSET str_hsTitle
    call WriteString

    mov  dl, 16
    mov  dh, 4
    call Gotoxy
    mov  edx, OFFSET str_hsBot
    call WriteString

    mov  eax, LIGHT_CYAN
    call SetTextColor
    mov  dl, 8
    mov  dh, 6
    call Gotoxy
    mov  edx, OFFSET str_hsColH
    call WriteString

    mov  eax, DARK_GRAY
    call SetTextColor
    mov  dl, 8
    mov  dh, 7
    call Gotoxy
    mov  edx, OFFSET str_hsDivide
    call WriteString

    ; Draw entries 0..4
    mov  ebx, 0
hsDrawLoop:
    cmp  ebx, HS_COUNT
    jge  hsDrawDone

    ; Row = 9 + ebx*2
    mov  eax, ebx
    imul eax, 2
    add  eax, 9
    mov  dh, al

    ; Pick color by rank
    cmp  ebx, 0
    jne  hsCol1
    mov  eax, YELLOW
    jmp  hsColSet
hsCol1:
    cmp  ebx, 1
    jne  hsCol2
    mov  eax, LIGHT_GRAY
    jmp  hsColSet
hsCol2:
    cmp  ebx, 2
    jne  hsCol3
    mov  eax, BROWN
    jmp  hsColSet
hsCol3:
    mov  eax, WHITE
hsColSet:
    call SetTextColor

    ; Print rank string (#1..#5)
    mov  dl, 8
    call Gotoxy

    cmp  ebx, 0
    je   hsR1
    cmp  ebx, 1
    je   hsR2
    cmp  ebx, 2
    je   hsR3
    cmp  ebx, 3
    je   hsR4
    mov  edx, OFFSET str_hsRank5
    jmp  hsRPrint
hsR1: mov  edx, OFFSET str_hsRank1
    jmp  hsRPrint
hsR2: mov  edx, OFFSET str_hsRank2
    jmp  hsRPrint
hsR3: mov  edx, OFFSET str_hsRank3
    jmp  hsRPrint
hsR4: mov  edx, OFFSET str_hsRank4
hsRPrint:
    call WriteString

    ; Print name (from hsNamePtrs[ebx])
    mov  eax, ebx
    shl  eax, 2
    mov  ecx, OFFSET hsNamePtrs
    add  ecx, eax
    mov  edx, [ecx]
    call WriteString

    ; Print score (from hsScorePtrs[ebx])
    mov  eax, ebx
    shl  eax, 2
    mov  ecx, OFFSET hsScorePtrs
    add  ecx, eax
    mov  ecx, [ecx]
    mov  eax, [ecx]
    call WriteDec

    inc  ebx
    jmp  hsDrawLoop

hsDrawDone:
    mov  eax, LIGHT_RED
    call SetTextColor
    mov  dl, 8
    mov  dh, 22
    call Gotoxy
    mov  edx, OFFSET str_hsBack
    call WriteString

hsWait:
    call ReadChar
    cmp  al, KEY_ESCAPE
    jne  hsWait

    pop  edx
    pop  ebx
    pop  eax
    ret
HighScoreScreen ENDP

; ============================================================
; UpdateHighScores
; ============================================================
UpdateHighScores PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov  ebx, HS_COUNT
    mov  ecx, 0

uhsFindPos:
    cmp  ecx, HS_COUNT
    jge  uhsNoInsert

    mov  eax, ecx
    shl  eax, 2
    mov  esi, OFFSET hsScorePtrs
    add  esi, eax
    mov  esi, [esi]
    mov  eax, [esi]

    cmp  score, eax
    jg   uhsFoundPos
    inc  ecx
    jmp  uhsFindPos

uhsFoundPos:
    mov  ebx, ecx

    mov  ecx, HS_COUNT - 1

uhsShiftLoop:
    cmp  ecx, ebx
    jl   uhsShiftDone

    cmp  ecx, HS_COUNT - 1
    je   uhsShiftJustDec

    mov  eax, ecx
    inc  eax
    shl  eax, 2
    mov  edi, OFFSET hsNamePtrs
    add  edi, eax
    mov  edi, [edi]

    mov  eax, ecx
    shl  eax, 2
    mov  esi, OFFSET hsNamePtrs
    add  esi, eax
    mov  esi, [esi]

    push ecx
    mov  ecx, 20
uhsNameCpy:
    mov  al, [esi]
    mov  [edi], al
    inc  esi
    inc  edi
    loop uhsNameCpy
    pop  ecx

    mov  eax, ecx
    inc  eax
    shl  eax, 2
    mov  edi, OFFSET hsScorePtrs
    add  edi, eax
    mov  edi, [edi]

    mov  eax, ecx
    shl  eax, 2
    mov  esi, OFFSET hsScorePtrs
    add  esi, eax
    mov  esi, [esi]

    mov  eax, [esi]
    mov  [edi], eax

uhsShiftJustDec:
    dec  ecx
    jmp  uhsShiftLoop

uhsShiftDone:
    mov  eax, ebx
    shl  eax, 2
    mov  edi, OFFSET hsNamePtrs
    add  edi, eax
    mov  edi, [edi]

    mov  esi, OFFSET playerName
    mov  ecx, 20
uhsWriteName:
    mov  al, [esi]
    cmp  al, 0
    je   uhsPadName
    mov  [edi], al
    inc  esi
    inc  edi
    dec  ecx
    jnz  uhsWriteName
    jmp  uhsWriteScore
uhsPadName:
    cmp  ecx, 0
    je   uhsWriteScore
    mov  BYTE PTR [edi], ' '
    inc  edi
    dec  ecx
    jmp  uhsPadName

uhsWriteScore:
    mov  eax, ebx
    shl  eax, 2
    mov  edi, OFFSET hsScorePtrs
    add  edi, eax
    mov  edi, [edi]
    mov  eax, score
    mov  [edi], eax

uhsNoInsert:
    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    ret
UpdateHighScores ENDP

; ============================================================
; LoadLevelBricks
; Zeroes all 50 bytes then copies the correct level layout.
; Level 1: 3 rows x 10 cols = 30 bytes  (BRICK_ROWS_L1)
; Level 2: 4 rows x 10 cols = 40 bytes  (BRICK_ROWS)
; Level 3: 5 rows x 10 cols = 50 bytes  (BRICK_ROWS_L3)
; ============================================================
LoadLevelBricks PROC
    push eax
    push ecx
    push esi
    push edi

    ; --- Zero the entire 50-byte buffer first ---
    mov  edi, OFFSET brickAlive
    mov  ecx, BRICK_ROWS_L3 * BRICK_COLS   ; always 50
    xor  eax, eax
    rep  stosb

    ; --- Copy the correct level layout ---
    mov  edi, OFFSET brickAlive

    movzx eax, level
    cmp  eax, 1
    je   loadLvl1
    cmp  eax, 2
    je   loadLvl2

    ; Level 3: 5 rows x 10 cols = 50 bytes
    mov  ecx, BRICK_ROWS_L3 * BRICK_COLS
    mov  esi, OFFSET lvl3Bricks
    jmp  doCopy

loadLvl1:
    ; Level 1: 3 rows x 10 cols = 30 bytes
    mov  ecx, BRICK_ROWS_L1 * BRICK_COLS
    mov  esi, OFFSET lvl1Bricks
    jmp  doCopy

loadLvl2:
    ; Level 2: 4 rows x 10 cols = 40 bytes
    mov  ecx, BRICK_ROWS * BRICK_COLS
    mov  esi, OFFSET lvl2Bricks

doCopy:
    rep  movsb

    pop  edi
    pop  esi
    pop  ecx
    pop  eax
    ret
LoadLevelBricks ENDP

; ============================================================
; SetLevelDelay
;   Level 1: 55ms delay, paddleSpeed=3, paddleWidth=12 (Normal)
;   Level 2: 38ms delay, paddleSpeed=3, paddleWidth=10 (Med)
;   Level 3: 22ms delay, paddleSpeed=3, paddleWidth=8  (Small)
; ============================================================
SetLevelDelay PROC
    push eax
    movzx eax, level
    cmp  eax, 1
    je   setD1
    cmp  eax, 2
    je   setD2
    ; Level 3
    mov  frameDelay, DELAY_L3
    mov  paddleSpeed, 3
    mov  paddleWidth, PADDLE_WIDTH_SMALL
    jmp  setDone
setD1:
    mov  frameDelay, DELAY_L1
    mov  paddleSpeed, 3
    mov  paddleWidth, PADDLE_WIDTH_NORMAL
    jmp  setDone
setD2:
    mov  frameDelay, DELAY_L2
    mov  paddleSpeed, 3
    mov  paddleWidth, PADDLE_WIDTH_MED
setDone:
    pop  eax
    ret
SetLevelDelay ENDP

; ============================================================
; ResetBall
; ============================================================
ResetBall PROC
    push eax
    mov  al, BALL_START_COL
    mov  ballX, al
    mov  al, BALL_START_ROW
    mov  ballY, al
    mov  ballDX, 1
    mov  ballDY, -1
    pop  eax
    ret
ResetBall ENDP

; ============================================================
; ResetPowerUp
; ============================================================
ResetPowerUp PROC
    cmp  pwrActive, PWR_NONE
    je   rpuDone

    push eax
    push edx
    mov  eax, BLACK
    call SetTextColor
    movzx eax, pwrX
    mov  dl, al
    movzx eax, pwrY
    mov  dh, al
    call Gotoxy
    mov  al, ' '
    call WriteChar
    pop  edx
    pop  eax

rpuDone:
    mov  pwrActive, PWR_NONE
    mov  pwrX, 0
    mov  pwrY, 0
    mov  pwrFrameCnt, 0
    ret
ResetPowerUp ENDP

; ============================================================
; DrawHUD
; ============================================================
DrawHUD PROC
    push eax
    push edx

    mov  eax, DARK_CYAN
    call SetTextColor
    mov  dl, 0
    mov  dh, HUD_ROW
    call Gotoxy
    mov  edx, OFFSET str_blank
    call WriteString

    mov  eax, YELLOW
    call SetTextColor
    mov  dl, 1
    mov  dh, HUD_ROW
    call Gotoxy
    mov  edx, OFFSET str_hudScore
    call WriteString
    mov  eax, score
    call WriteDec

    mov  eax, LIGHT_RED
    call SetTextColor
    mov  dl, 16
    mov  dh, HUD_ROW
    call Gotoxy
    mov  edx, OFFSET str_hudLives
    call WriteString
    movzx eax, lives
    call WriteDec

    mov  eax, LIGHT_GREEN
    call SetTextColor
    mov  dl, 30
    mov  dh, HUD_ROW
    call Gotoxy
    mov  edx, OFFSET str_hudLevel
    call WriteString
    movzx eax, level
    call WriteDec

    mov  eax, LIGHT_CYAN
    call SetTextColor
    mov  dl, 44
    mov  dh, HUD_ROW
    call Gotoxy
    mov  edx, OFFSET str_hudPlayer
    call WriteString
    mov  edx, OFFSET playerName
    call WriteString

    pop  edx
    pop  eax
    ret
DrawHUD ENDP

; ============================================================
; DrawTopWall
; ============================================================
DrawTopWall PROC
    push eax
    push ecx
    push edx
    mov  eax, WHITE
    call SetTextColor
    mov  dl, 0
    mov  dh, GAME_TOP
    call Gotoxy
    mov  ecx, 80
dtwLoop:
    mov  al, '='
    call WriteChar
    loop dtwLoop
    pop  edx
    pop  ecx
    pop  eax
    ret
DrawTopWall ENDP

; ============================================================
; DrawWalls
; ============================================================
DrawWalls PROC
    push eax
    push ebx
    push edx

    mov  eax, WHITE
    mov  dh, GAME_TOP
    call DrawLine

    mov  dh, GAME_BOTTOM
    call DrawLine

    mov  ebx, GAME_TOP + 1
sideWallLoop:
    cmp  ebx, GAME_BOTTOM
    jge  wallsDone

    mov  eax, WHITE
    call SetTextColor

    mov  dl, 0
    mov  dh, bl
    call Gotoxy
    mov  al, '|'
    call WriteChar

    mov  dl, 79
    mov  dh, bl
    call Gotoxy
    mov  al, '|'
    call WriteChar

    inc  ebx
    jmp  sideWallLoop

wallsDone:
    pop  edx
    pop  ebx
    pop  eax
    ret
DrawWalls ENDP

; ============================================================
; DrawBricks
; Draws correct number of rows per level:
;   Level 1 = 3 rows, Level 2 = 4 rows, Level 3 = 5 rows
; ============================================================
DrawBricks PROC
    push eax
    push ebx
    push esi
    push edi
    push edx

    ; Determine row count for this level
    movzx eax, level
    cmp  eax, 1
    je   dbRowCount3
    cmp  eax, 3
    je   dbRowCount5
    mov  eax, BRICK_ROWS        ; Level 2: 4 rows
    jmp  dbRowCountSet
dbRowCount3:
    mov  eax, BRICK_ROWS_L1     ; Level 1: 3 rows
    jmp  dbRowCountSet
dbRowCount5:
    mov  eax, BRICK_ROWS_L3     ; Level 3: 5 rows
dbRowCountSet:
    push eax                    ; save row count on stack

    mov  ebx, 0                 ; current row index

bkRowLoop:
    mov  eax, [esp]
    cmp  ebx, eax
    jge  bkDone

    ; Pick color based on row index
    cmp  ebx, 0
    je   bkColorRed
    cmp  ebx, 1
    je   bkColorMag
    cmp  ebx, 2
    je   bkColorCyan
    cmp  ebx, 3
    je   bkColorGreen
    mov  eax, YELLOW
    jmp  bkColorSet
bkColorRed:
    mov  eax, LIGHT_RED
    jmp  bkColorSet
bkColorMag:
    mov  eax, LIGHT_MAGENTA
    jmp  bkColorSet
bkColorCyan:
    mov  eax, LIGHT_CYAN
    jmp  bkColorSet
bkColorGreen:
    mov  eax, LIGHT_GREEN
bkColorSet:
    call SetTextColor

    mov  esi, 0

bkColLoop:
    cmp  esi, BRICK_COLS
    jge  bkNextRow

    mov  eax, ebx
    imul eax, BRICK_COLS
    add  eax, esi
    mov  edi, OFFSET brickAlive
    add  edi, eax
    mov  al, [edi]
    cmp  al, 1
    jne  bkSkip

    mov  eax, esi
    imul eax, BRICK_W
    add  eax, BRICK_COL_START
    mov  dl, al

    mov  eax, ebx
    imul eax, BRICK_H
    add  eax, BRICK_ROW_START
    mov  dh, al

    call Gotoxy
    mov  al, '['
    call WriteChar
    mov  al, '#'
    call WriteChar
    call WriteChar
    mov  al, ']'
    call WriteChar

bkSkip:
    inc  esi
    jmp  bkColLoop

bkNextRow:
    inc  ebx
    jmp  bkRowLoop

bkDone:
    pop  eax
    pop  edx
    pop  edi
    pop  esi
    pop  ebx
    pop  eax
    ret
DrawBricks ENDP

; ============================================================
; EraseBrick: erases brick at (EBX=row, ESI=col)
; ============================================================
EraseBrick PROC
    push eax
    push edx

    mov  eax, BLACK
    call SetTextColor

    mov  eax, esi
    imul eax, BRICK_W
    add  eax, BRICK_COL_START
    mov  dl, al

    mov  eax, ebx
    imul eax, BRICK_H
    add  eax, BRICK_ROW_START
    mov  dh, al

    call Gotoxy
    mov  al, ' '
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar

    pop  edx
    pop  eax
    ret
EraseBrick ENDP

; ============================================================
; DrawPaddle
; ============================================================
DrawPaddle PROC
    push eax
    push ebx
    push ecx
    push edx

    mov  eax, LIGHT_CYAN
    call SetTextColor

    movzx ebx, paddleX
    movzx ecx, paddleWidth

drawPaddleLoop:
    cmp  ecx, 0
    je   drawPaddleDone
    cmp  ebx, GAME_LEFT + 1
    jl   dpSkip
    cmp  ebx, GAME_RIGHT - 1
    jg   drawPaddleDone

    mov  dl, bl
    mov  dh, PADDLE_ROW
    call Gotoxy
    mov  al, '='
    call WriteChar

dpSkip:
    inc  ebx
    dec  ecx
    jmp  drawPaddleLoop

drawPaddleDone:
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    ret
DrawPaddle ENDP

; ============================================================
; ErasePaddle
; ============================================================
ErasePaddle PROC
    push eax
    push ebx
    push ecx
    push edx

    mov  eax, BLACK
    call SetTextColor

    movzx ebx, paddleX
    movzx ecx, paddleWidth

erasePaddleLoop:
    cmp  ecx, 0
    je   erasePaddleDone
    cmp  ebx, GAME_LEFT + 1
    jl   epSkip
    cmp  ebx, GAME_RIGHT - 1
    jg   erasePaddleDone

    mov  dl, bl
    mov  dh, PADDLE_ROW
    call Gotoxy
    mov  al, ' '
    call WriteChar

epSkip:
    inc  ebx
    dec  ecx
    jmp  erasePaddleLoop

erasePaddleDone:
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    ret
ErasePaddle ENDP

; ============================================================
; MovePaddle
; ============================================================
MovePaddle PROC
    push eax
    push ebx

    call ReadKey
    jz   movePaddleDone

    cmp  al, KEY_P
    je   togglePause

    cmp  al, 0
    je   checkExtended
    cmp  al, 0E0h
    je   checkExtended

    cmp  al, KEY_A
    je   movePaddleLeft
    cmp  al, KEY_D
    je   movePaddleRight
    jmp  movePaddleDone

checkExtended:
    cmp  ah, KEY_LEFT
    je   movePaddleLeft
    cmp  ah, KEY_RIGHT
    je   movePaddleRight
    jmp  movePaddleDone

togglePause:
    cmp  paused, 0
    je   doPause
    mov  paused, 0
    mov  eax, BLACK
    call SetTextColor
    mov  dl, 20
    mov  dh, 12
    call Gotoxy
    mov  edx, OFFSET str_blank
    call WriteString
    call DrawHUD
    call DrawTopWall
    call DrawWalls
    jmp  movePaddleDone
doPause:
    mov  paused, 1
    mov  eax, YELLOW
    call SetTextColor
    mov  dl, 20
    mov  dh, 12
    call Gotoxy
    mov  edx, OFFSET str_paused
    call WriteString
    jmp  movePaddleDone

movePaddleLeft:
    cmp  paused, 1
    je   movePaddleDone
    call ErasePaddle
    movzx ebx, paddleX
    movzx eax, paddleSpeed
    sub  ebx, eax
    cmp  ebx, GAME_LEFT + 1
    jge  setPaddleX_L
    mov  ebx, GAME_LEFT + 1
setPaddleX_L:
    mov  paddleX, bl
    call DrawPaddle
    jmp  movePaddleDone

movePaddleRight:
    cmp  paused, 1
    je   movePaddleDone
    call ErasePaddle
    movzx ebx, paddleX
    movzx eax, paddleSpeed
    add  ebx, eax
    movzx eax, paddleWidth
    mov  ecx, GAME_RIGHT - 1
    sub  ecx, eax
    inc  ecx
    cmp  ebx, ecx
    jle  setPaddleX_R
    mov  ebx, ecx
setPaddleX_R:
    mov  paddleX, bl
    call DrawPaddle

movePaddleDone:
    pop  ebx
    pop  eax
    ret
MovePaddle ENDP

; ============================================================
; DrawBall
; ============================================================
DrawBall PROC
    push eax
    push edx

    movzx eax, ballY
    cmp  eax, GAME_TOP
    je   drawBallSkip
    cmp  eax, GAME_BOTTOM
    je   drawBallSkip

    mov  eax, YELLOW
    call SetTextColor

    movzx eax, ballX
    mov  dl, al
    movzx eax, ballY
    mov  dh, al
    call Gotoxy
    mov  al, 'O'
    call WriteChar

drawBallSkip:
    pop  edx
    pop  eax
    ret
DrawBall ENDP

; ============================================================
; EraseBall
; ============================================================
EraseBall PROC
    push eax
    push edx

    movzx eax, ballY
    cmp  eax, GAME_TOP
    je   eraseBallSkip
    cmp  eax, GAME_BOTTOM
    je   eraseBallSkip

    mov  eax, BLACK
    call SetTextColor

    movzx eax, ballX
    mov  dl, al
    movzx eax, ballY
    mov  dh, al
    call Gotoxy
    mov  al, ' '
    call WriteChar

eraseBallSkip:
    pop  edx
    pop  eax
    ret
EraseBall ENDP

; ============================================================
; CheckWallCollision
; ============================================================
CheckWallCollision PROC
    push eax

    movzx eax, ballX
    cmp  eax, GAME_LEFT + 1
    jg   checkRightWall
    mov  ballX, GAME_LEFT + 2
    mov  ballDX, 1

checkRightWall:
    movzx eax, ballX
    cmp  eax, GAME_RIGHT - 1
    jl   checkTopWall
    mov  ballX, GAME_RIGHT - 2
    mov  ballDX, -1

checkTopWall:
    movzx eax, ballY
    cmp  eax, GAME_TOP + 1
    jg   wallCheckDone
    mov  ballY, GAME_TOP + 2
    mov  ballDY, 1

wallCheckDone:
    pop  eax
    ret
CheckWallCollision ENDP

; ============================================================
; CheckPaddleCollision
; ============================================================
CheckPaddleCollision PROC
    push eax
    push ebx
    push ecx

    movzx eax, ballY
    cmp  eax, PADDLE_ROW
    jne  paddleCheckDone

    movsx eax, ballDY
    cmp  eax, 1
    jne  paddleCheckDone

    movzx eax, ballX
    movzx ebx, paddleX
    cmp  eax, ebx
    jl   paddleCheckDone

    movzx ecx, paddleWidth
    add  ecx, ebx
    cmp  eax, ecx
    jge  paddleCheckDone

    mov  ballDY, -1

    movzx ecx, paddleWidth
    mov  ebx, ecx
    shr  ebx, 2

    movzx eax, ballX
    movzx ecx, paddleX

    mov  edx, ecx
    add  edx, ebx
    cmp  eax, edx
    jl   paddleGoLeft

    mov  edx, ecx
    movzx ecx, paddleWidth
    mov  esi, ecx
    sub  esi, ebx
    add  edx, esi
    movzx eax, ballX
    cmp  eax, edx
    jge  paddleGoRight
    jmp  paddleCheckDone

paddleGoLeft:
    mov  ballDX, -1
    jmp  paddleCheckDone
paddleGoRight:
    mov  ballDX, 1

paddleCheckDone:
    pop  ecx
    pop  ebx
    pop  eax
    ret
CheckPaddleCollision ENDP

; ============================================================
; CheckBrickCollision
; Scans correct number of rows per level (3, 4, or 5)
; ============================================================
CheckBrickCollision PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; Determine row count for this level
    movzx eax, level
    cmp  eax, 1
    je   cbcRowCount3
    cmp  eax, 3
    jne  cbcRowCount4
    mov  eax, BRICK_ROWS_L3
    jmp  cbcRowCountSet
cbcRowCount3:
    mov  eax, BRICK_ROWS_L1
    jmp  cbcRowCountSet
cbcRowCount4:
    mov  eax, BRICK_ROWS
cbcRowCountSet:
    push eax

    mov  ebx, 0

brickRowScan:
    mov  eax, [esp]
    cmp  ebx, eax
    jge  brickCheckDone

    mov  eax, ebx
    imul eax, BRICK_H
    add  eax, BRICK_ROW_START

    movzx ecx, ballY

    cmp  ecx, eax
    je   brickRowMatch
    inc  eax
    cmp  ecx, eax
    je   brickRowMatch
    jmp  brickNextRow

brickRowMatch:
    mov  esi, 0

brickColScan:
    cmp  esi, BRICK_COLS
    jge  brickNextRow

    mov  eax, ebx
    imul eax, BRICK_COLS
    add  eax, esi
    mov  edi, OFFSET brickAlive
    add  edi, eax
    mov  al, [edi]
    cmp  al, 1
    jne  brickNextCol

    mov  eax, esi
    imul eax, BRICK_W
    add  eax, BRICK_COL_START

    movzx ecx, ballX
    cmp  ecx, eax
    jl   brickNextCol

    mov  edx, eax
    add  edx, 3
    cmp  ecx, edx
    jg   brickNextCol

    ; *** HIT ***
    mov  eax, ebx
    imul eax, BRICK_COLS
    add  eax, esi
    mov  edi, OFFSET brickAlive
    add  edi, eax
    mov  BYTE PTR [edi], 0

    call EraseBrick

    add  score, 10
    call UpdateScoreDisplay

    movsx eax, ballDY
    neg  eax
    mov  ballDY, al

    cmp  pwrActive, PWR_NONE
    jne  brickCheckDone

    call TrySpawnPowerUp

    jmp  brickCheckDone

brickNextCol:
    inc  esi
    jmp  brickColScan

brickNextRow:
    inc  ebx
    jmp  brickRowScan

brickCheckDone:
    pop  eax
    pop  edi
    pop  esi
    pop  edx
    pop  ecx
    pop  ebx
    pop  eax
    ret
CheckBrickCollision ENDP

; ============================================================
; TrySpawnPowerUp: 30% chance
; Spawn row is level-aware:
;   L1: row  9  (3 + 3*2)
;   L2: row 11  (3 + 4*2)
;   L3: row 13  (3 + 5*2)
; ============================================================
TrySpawnPowerUp PROC
    push eax
    push ebx

    call RandByte
    cmp  eax, 30
    jge  spawnSkip

    movzx eax, ballX
    cmp  eax, GAME_LEFT + 2
    jge  spawnXok
    mov  eax, GAME_LEFT + 2
spawnXok:
    cmp  eax, GAME_RIGHT - 2
    jle  spawnXok2
    mov  eax, GAME_RIGHT - 2
spawnXok2:
    mov  pwrX, al

    ; Choose spawn row based on level
    movzx eax, level
    cmp  eax, 1
    je   spawnRowL1
    cmp  eax, 3
    je   spawnRowL3
    ; Level 2
    mov  pwrY, BRICK_ROW_START + BRICK_ROWS * BRICK_H       ; = 3+4*2 = 11
    jmp  spawnRowDone
spawnRowL1:
    mov  pwrY, BRICK_ROW_START + BRICK_ROWS_L1 * BRICK_H    ; = 3+3*2 = 9
    jmp  spawnRowDone
spawnRowL3:
    mov  pwrY, BRICK_ROW_START + BRICK_ROWS_L3 * BRICK_H    ; = 3+5*2 = 13
spawnRowDone:

    call RandByte
    cmp  eax, 33
    jle  spawnSlow
    cmp  eax, 66
    jle  spawnLife
    mov  pwrActive, PWR_BIGPADDLE
    jmp  spawnDone
spawnSlow:
    mov  pwrActive, PWR_SLOWBALL
    jmp  spawnDone
spawnLife:
    mov  pwrActive, PWR_EXTRALIFE
spawnDone:
    mov  pwrFrameCnt, 0

spawnSkip:
    pop  ebx
    pop  eax
    ret
TrySpawnPowerUp ENDP

; ============================================================
; DrawPowerUp
; ============================================================
DrawPowerUp PROC
    push eax
    push edx

    cmp  pwrActive, PWR_NONE
    je   dpuDone

    movzx eax, pwrY
    cmp  eax, GAME_TOP
    je   dpuDone
    cmp  eax, GAME_BOTTOM
    jge  dpuDone

    mov  eax, LIGHT_GREEN
    call SetTextColor

    movzx eax, pwrX
    mov  dl, al
    movzx eax, pwrY
    mov  dh, al
    call Gotoxy

    cmp  pwrActive, PWR_SLOWBALL
    je   dpuDrawS
    cmp  pwrActive, PWR_EXTRALIFE
    je   dpuDrawL
    mov  al, PWR_CHAR_BIG
    call WriteChar
    jmp  dpuDone
dpuDrawS:
    mov  al, PWR_CHAR_SLOW
    call WriteChar
    jmp  dpuDone
dpuDrawL:
    mov  al, PWR_CHAR_LIFE
    call WriteChar

dpuDone:
    pop  edx
    pop  eax
    ret
DrawPowerUp ENDP

; ============================================================
; ErasePowerUp
; ============================================================
ErasePowerUp PROC
    push eax
    push edx

    cmp  pwrActive, PWR_NONE
    je   epuDone

    movzx eax, pwrY
    cmp  eax, GAME_TOP
    je   epuDone
    cmp  eax, GAME_BOTTOM
    jge  epuDone

    mov  eax, BLACK
    call SetTextColor

    movzx eax, pwrX
    mov  dl, al
    movzx eax, pwrY
    mov  dh, al
    call Gotoxy
    mov  al, ' '
    call WriteChar

epuDone:
    pop  edx
    pop  eax
    ret
ErasePowerUp ENDP

; ============================================================
; UpdatePowerUp
; ============================================================
UpdatePowerUp PROC
    push eax
    push ebx
    push ecx

    cmp  pwrActive, PWR_NONE
    je   upuDone

    inc  pwrFrameCnt
    mov  eax, pwrFrameCnt
    cmp  eax, 3
    jl   upuCheckCollect

    mov  pwrFrameCnt, 0
    call ErasePowerUp

    movzx eax, pwrY
    inc  eax
    mov  pwrY, al

    cmp  al, GAME_BOTTOM
    jge  upuMissed

upuCheckCollect:
    movzx eax, pwrY
    cmp  eax, PADDLE_ROW
    jne  upuDraw

    movzx eax, pwrX
    movzx ebx, paddleX
    cmp  eax, ebx
    jl   upuMissed

    movzx ecx, paddleWidth
    add  ecx, ebx
    cmp  eax, ecx
    jge  upuMissed

    call ApplyPowerUp
    jmp  upuDone

upuDraw:
    call DrawPowerUp
    jmp  upuDone

upuMissed:
    call ErasePowerUp
    mov  pwrActive, PWR_NONE

upuDone:
    pop  ecx
    pop  ebx
    pop  eax
    ret
UpdatePowerUp ENDP

; ============================================================
; ApplyPowerUp
; ============================================================
ApplyPowerUp PROC
    push eax

    cmp  pwrActive, PWR_SLOWBALL
    je   applySlowBall
    cmp  pwrActive, PWR_EXTRALIFE
    je   applyExtraLife

    ; Big Paddle
    call ErasePaddle
    mov  paddleWidth, PADDLE_WIDTH_BIG
    movzx eax, paddleX
    movzx ecx, paddleWidth
    mov  ebx, GAME_RIGHT - 1
    sub  ebx, ecx
    inc  ebx
    cmp  eax, ebx
    jle  applyBigOk
    mov  paddleX, bl
applyBigOk:
    call DrawPaddle
    mov  bigPaddleTimer, 300
    mov  pwrActive, PWR_NONE
    jmp  applyDone

applySlowBall:
    mov  slowBallTimer, 250
    mov  pwrActive, PWR_NONE
    jmp  applyDone

applyExtraLife:
    movzx eax, lives
    cmp  eax, 5
    jge  applyDoneLife
    inc  lives
    call DrawHUD
    call DrawTopWall
applyDoneLife:
    mov  pwrActive, PWR_NONE

applyDone:
    pop  eax
    ret
ApplyPowerUp ENDP

; ============================================================
; UpdateTimers
; ============================================================
UpdateTimers PROC
    push eax

    cmp  bigPaddleTimer, 0
    jle  timerSlowCheck
    dec  bigPaddleTimer
    jnz  timerSlowCheck
    call ErasePaddle
    call SetLevelDelay
    call DrawPaddle

timerSlowCheck:
    cmp  slowBallTimer, 0
    jle  timerDone
    dec  slowBallTimer

timerDone:
    pop  eax
    ret
UpdateTimers ENDP

; ============================================================
; MoveBall
; ============================================================
MoveBall PROC
    push eax
    push ecx

    movsx eax, ballDX
    movzx ecx, ballX
    add  ecx, eax
    mov  ballX, cl

    movsx eax, ballDY
    movzx ecx, ballY
    add  ecx, eax
    mov  ballY, cl

    pop  ecx
    pop  eax
    ret
MoveBall ENDP

; ============================================================
; AllBricksGone
; Checks correct brick count per level: 30, 40, or 50
; ============================================================
AllBricksGone PROC
    push ecx
    push edi

    ; Determine brick count for this level
    movzx eax, level
    cmp  eax, 1
    je   abgCount3
    cmp  eax, 3
    jne  abgCount4
    mov  ecx, BRICK_ROWS_L3 * BRICK_COLS   ; 50 for Level 3
    jmp  abgScan
abgCount3:
    mov  ecx, BRICK_ROWS_L1 * BRICK_COLS   ; 30 for Level 1
    jmp  abgScan
abgCount4:
    mov  ecx, BRICK_ROWS * BRICK_COLS      ; 40 for Level 2
abgScan:
    mov  edi, OFFSET brickAlive

scanLoop:
    mov  al, [edi]
    cmp  al, 1
    je   notAllGone
    inc  edi
    loop scanLoop

    mov  eax, 1
    jmp  allBricksRet

notAllGone:
    mov  eax, 0

allBricksRet:
    pop  edi
    pop  ecx
    ret
AllBricksGone ENDP

; ============================================================
; UpdateScoreDisplay
; ============================================================
UpdateScoreDisplay PROC
    push eax
    push edx

    mov  eax, YELLOW
    call SetTextColor
    mov  dl, 1
    mov  dh, HUD_ROW
    call Gotoxy
    mov  edx, OFFSET str_hudScore
    call WriteString
    mov  eax, score
    call WriteDec
    mov  al, ' '
    call WriteChar
    call WriteChar
    call WriteChar

    pop  edx
    pop  eax
    ret
UpdateScoreDisplay ENDP

; ============================================================
; LevelTransitionScreen
; ============================================================
LevelTransitionScreen PROC
    push eax
    push edx

    call Clrscr

    mov  eax, LIGHT_GREEN
    mov  dh, 0
    call DrawStars
    mov  dh, 24
    call DrawStars

    mov  eax, YELLOW
    call SetTextColor
    mov  dl, 20
    mov  dh, 10
    call Gotoxy
    mov  edx, OFFSET str_lvlClr1
    call WriteString

    mov  eax, LIGHT_CYAN
    call SetTextColor
    mov  dl, 20
    mov  dh, 12
    call Gotoxy
    mov  edx, OFFSET str_lvlClr2
    call WriteString

    mov  eax, WHITE
    call SetTextColor
    mov  dl, 28
    mov  dh, 14
    call Gotoxy
    mov  edx, OFFSET str_hudLevel
    call WriteString
    movzx eax, level
    call WriteDec

    mov  eax, LIGHT_GREEN
    call SetTextColor
    mov  dl, 25
    mov  dh, 18
    call Gotoxy
    mov  edx, OFFSET str_lvlClr3
    call WriteString

ltWait:
    call ReadChar
    cmp  al, KEY_ENTER
    jne  ltWait

    pop  edx
    pop  eax
    ret
LevelTransitionScreen ENDP

; ============================================================
; WinScreen
; ============================================================
WinScreen PROC
    call Clrscr

    mov  eax, LIGHT_GREEN
    mov  dh, 0
    call DrawStars
    mov  dh, 24
    call DrawStars

    mov  eax, YELLOW
    call SetTextColor

    mov  dl, 10
    mov  dh, 3
    call Gotoxy
    mov  edx, OFFSET str_win1
    call WriteString

    mov  dl, 10
    mov  dh, 4
    call Gotoxy
    mov  edx, OFFSET str_win2
    call WriteString

    mov  dl, 10
    mov  dh, 5
    call Gotoxy
    mov  edx, OFFSET str_win3
    call WriteString

    mov  dl, 10
    mov  dh, 6
    call Gotoxy
    mov  edx, OFFSET str_win4
    call WriteString

    mov  dl, 10
    mov  dh, 7
    call Gotoxy
    mov  edx, OFFSET str_win5
    call WriteString

    mov  eax, LIGHT_CYAN
    call SetTextColor
    mov  dl, 10
    mov  dh, 10
    call Gotoxy
    mov  edx, OFFSET str_winSub
    call WriteString

    mov  eax, LIGHT_CYAN
    call SetTextColor
    mov  dl, 15
    mov  dh, 14
    call Gotoxy
    mov  edx, OFFSET str_winPly
    call WriteString
    mov  edx, OFFSET playerName
    call WriteString

    mov  eax, YELLOW
    call SetTextColor
    mov  dl, 15
    mov  dh, 15
    call Gotoxy
    mov  edx, OFFSET str_winScr
    call WriteString
    mov  eax, score
    call WriteDec

    mov  eax, LIGHT_GREEN
    call SetTextColor
    mov  dl, 15
    mov  dh, 21
    call Gotoxy
    mov  edx, OFFSET str_winRet
    call WriteString

wsWait:
    call ReadChar
    cmp  al, KEY_ENTER
    jne  wsWait
    ret
WinScreen ENDP

; ============================================================
; GameOverScreen
; ============================================================
GameOverScreen PROC
    call Clrscr

    mov  eax, DARK_RED
    mov  dh, 0
    call DrawStars
    mov  dh, 24
    call DrawStars

    mov  eax, LIGHT_RED
    call SetTextColor

    mov  dl, 20
    mov  dh, 4
    call Gotoxy
    mov  edx, OFFSET str_goTitle
    call WriteString

    mov  dl, 20
    mov  dh, 5
    call Gotoxy
    mov  edx, OFFSET str_goTitle2
    call WriteString

    mov  dl, 20
    mov  dh, 6
    call Gotoxy
    mov  edx, OFFSET str_goTitle3
    call WriteString

    mov  dl, 20
    mov  dh, 7
    call Gotoxy
    mov  edx, OFFSET str_goTitle4
    call WriteString

    mov  dl, 20
    mov  dh, 8
    call Gotoxy
    mov  edx, OFFSET str_goTitle5
    call WriteString

    mov  eax, YELLOW
    call SetTextColor

    mov  dl, 20
    mov  dh, 10
    call Gotoxy
    mov  edx, OFFSET str_goOver1
    call WriteString

    mov  dl, 20
    mov  dh, 11
    call Gotoxy
    mov  edx, OFFSET str_goOver2
    call WriteString

    mov  dl, 20
    mov  dh, 12
    call Gotoxy
    mov  edx, OFFSET str_goOver3
    call WriteString

    mov  dl, 20
    mov  dh, 13
    call Gotoxy
    mov  edx, OFFSET str_goOver4
    call WriteString

    mov  dl, 20
    mov  dh, 14
    call Gotoxy
    mov  edx, OFFSET str_goOver5
    call WriteString

    mov  eax, LIGHT_CYAN
    call SetTextColor
    mov  dl, 15
    mov  dh, 17
    call Gotoxy
    mov  edx, OFFSET str_goPlay
    call WriteString
    mov  edx, OFFSET playerName
    call WriteString

    mov  eax, YELLOW
    call SetTextColor
    mov  dl, 15
    mov  dh, 18
    call Gotoxy
    mov  edx, OFFSET str_goScore
    call WriteString
    mov  eax, score
    call WriteDec

    mov  eax, LIGHT_GREEN
    call SetTextColor
    mov  dl, 15
    mov  dh, 21
    call Gotoxy
    mov  edx, OFFSET str_goRetry
    call WriteString

goWait:
    call ReadChar
    cmp  al, KEY_ENTER
    jne  goWait
    ret
GameOverScreen ENDP

; ============================================================
; StartGame: resets all state, runs all 3 levels
; FIX: level now starts at 1 (was incorrectly set to 3)
; ============================================================
StartGame PROC
    mov  score, 0
    mov  lives, 3
    mov  level, 1          

    call ResetForLevel

gameAllLevels:
    call PlayLevel          ; EAX: 1=level won, 0=game over

    cmp  eax, 0
    je   sgGameOver

    movzx eax, level
    cmp  eax, 3
    je   sgWin

    inc  level
    call ResetForLevel
    call LevelTransitionScreen
    jmp  gameAllLevels

sgWin:
    call UpdateHighScores
    call WinScreen
    ret

sgGameOver:
    call UpdateHighScores
    call GameOverScreen
    ret
StartGame ENDP

; ============================================================
; ResetForLevel
; ============================================================
ResetForLevel PROC
    mov  paddleX, 34
    mov  bigPaddleTimer, 0
    mov  slowBallTimer, 0
    mov  paused, 0
    call ResetPowerUp
    call ResetBall
    call LoadLevelBricks
    call SetLevelDelay
    ret
ResetForLevel ENDP

; ============================================================
; PlayLevel: runs game loop for current level
; Returns EAX: 1 = level cleared, 0 = game over
; ============================================================
PlayLevel PROC
    push ebx

    call Clrscr
    call DrawHUD
    call DrawWalls
    call DrawBricks
    call DrawPaddle
    call DrawBall

gameFrameLoop:
    cmp  paused, 1
    je   pausedFrame

    call MovePaddle
    call EraseBall
    call MoveBall
    call CheckWallCollision
    call CheckPaddleCollision
    call CheckBrickCollision
    call UpdatePowerUp
    call UpdateTimers

    movzx eax, ballY
    cmp  eax, GAME_BOTTOM
    jl   drawBallNow

    ; Life lost
    call ResetPowerUp
    dec  lives
    cmp  lives, 0
    je   plLivesOut

    ; Respawn
    call ErasePaddle
    mov  paddleX, 34
    mov  bigPaddleTimer, 0
    mov  slowBallTimer, 0
    call SetLevelDelay
    call ResetBall
    call DrawWalls
    call DrawHUD
    call DrawTopWall
    call DrawPaddle

drawBallNow:
    call DrawBall
    call DrawTopWall

    call AllBricksGone
    cmp  eax, 1
    je   plLevelWon

    jmp  doDelay

pausedFrame:
    call MovePaddle

doDelay:
    call DelayRoutine
    jmp  gameFrameLoop

plLevelWon:
    call ResetPowerUp
    mov  eax, 1
    jmp  plDone

plLivesOut:
    call DrawHUD
    call DrawTopWall
    mov  eax, 0

plDone:
    pop  ebx
    ret
PlayLevel ENDP

; ============================================================
; main
; ============================================================
main PROC
    call HomeScreen
    call NameInputScreen

mainLoop:
    call MainMenuScreen

    cmp  eax, MENU_START
    je   goGame

    cmp  eax, MENU_INST
    je   goInst

    cmp  eax, MENU_HIGH
    je   goHigh

    cmp  eax, MENU_EXIT
    je   goExit

    jmp  mainLoop

goGame:
    call StartGame
    jmp  mainLoop

goInst:
    call InstructionsScreen
    jmp  mainLoop

goHigh:
    call HighScoreScreen
    jmp  mainLoop

goExit:
    mov  eax, WHITE
    call SetTextColor
    call Clrscr
    invoke ExitProcess, 0

main ENDP

END main