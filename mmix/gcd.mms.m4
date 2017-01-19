        LOC   Data_Segment
        GREG  @
ErrMsg  BYTE  "Error!",10,0

        LOC   #100

a       IS $0
b       IS $1
u       IS $0
v       IS $1
k       IS $2
t       IS $3

% Gcd using division
Gcd     PUT   rD,0
1H      DIVU  t,a,b
        SET   a,b
        GET   b,rR
        PBNZ  b,1B
        POP   1,0

p       IS $4
q       IS $5
r       IS $6
GcdRsb  OR    t,u,v
        SUBU  k,t,1
        SADD  k,k,t
        SRU   u,u,k
        SRU   v,v,k

D1      ODIF  p,u,v
        ODIF  q,v,u
        ADDU  q,p,q  % q = abs(u-v)
        BZ    q,D2
        SUBU  v,u,p  % v = min(u,v)
        SUBU  p,q,1  % p = q - 1
        SADD  p,p,q  % p = k, 2^k | p
        SRU   u,q,p  % u = q >> k
        JMP   D1
D2      SLU   u,u,k
        POP   1,0

GcdBin  SET   k,0
0H      OR    t,u,v
        % either this:
        PBOD  t,B2
        SR    u,u,1
        SR    v,v,1
        ADD   k,k,1
        JMP   0B
        % or this:
        % SUBU  k,t,1
        % SADD  k,k,t
        % SR    u,u,k
        % SR    v,v,k

B2      NEG   t,v
        PBOD  u,B4
        SET   t,u
B3      SR    t,t,1
B4      BEV   t,B3
        CSP   u,t,t
        NEG   t,t
        CSNN  v,t,t
        SUB   t,u,v
        PBNZ  t,B3
        SL    u,u,k
        POP   1,0

gcd     IS $1
n       IS $2
m       IS $3
expected IS $0
tst     IS $5
ret     IS $6
arg1    IS $7
arg2    IS $8

nb      IS $0
consts  GREG @
        OCTA  #100  % nmax
        OCTA  #fe  % nb

Main    LDOU  n,consts,8
        LDOU  m,consts,8
        LDOU  nb,consts,16

oloop   SUBU  n,n,1
iloop   SUBU  m,m,1
        SET   arg1,n
        ADDU  arg1,arg1,nb
        SET   arg2,m
        ADDU  arg2,arg2,nb
        PUSHJ ret,GcdRsb
        BNZ   m,iloop
        LDOU  m,consts,8
        BNZ   n,oloop
        TRAP  0,Halt,0

% an m4 macro for computing gcd from constants
define(TST,`SETL  n,(($1)&#ffff)
        INCML n,(($1)&#ffff0000)>>16
        INCMH n,(($1)&#ffff00000000)>>32
        INCH  n,(($1)&#ffff000000000000)>>48
        SETL  m,(($2)&#ffff)
        INCML m,(($2)&#ffff0000)>>16
        INCMH m,(($2)&#ffff00000000)>>32
        INCH  m,(($2)&#ffff000000000000)>>48
        SETL  expected,(($3)&#ffff)
        INCML expected,(($3)&#ffff0000)>>16
        INCMH expected,(($3)&#ffff00000000)>>32
        PUSHJ gcd,GcdRsb
        CMPU  tst,gcd,expected
        BNZ   tst,Error')

        % do some actual tests for correctness
Main2    TST(12, 18, 6)
        TST(9223372036854775820,9223372036854775828,4)
        TST(13, 13, 13)
        TST(2772, 3883, 11)
        TST(624129, 2061517, 18913)
        TST(96495, 54221, 919)
        TST(42792, 21396, 21396)
        TST(34153, 56252, 2009)
        TST(54068, 63723, 1931)
        TST(90820, 54970, 2390)
        TST(97450, 23388, 3898)
        TST(136091, 8603318, 5917)
        TST(6564742, 5941507, 41549)
        TST(3002720, 6082040, 15320)
        TST(2454387, 3590236, 7943)
        TST(6782760, 9312675, 3405)
        TST(2635261, 9158612, 43201)

        TRAP  0,Halt,0

Error   LDA   $255,ErrMsg
        TRAP  0,Fputs,StdOut
        TRAP  0,Halt,0
