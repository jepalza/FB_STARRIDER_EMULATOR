' variables exclusivas del Motorola 6809

' registros del 6809
Dim shared PC  As Integer ' contador de programa
Dim shared rX  As Integer ' indice X
Dim shared rY  As Integer ' indice Y
Dim shared rU  As Integer ' pila U
Dim shared rS  As Integer ' pila S
Dim shared rA  As Integer ' registro simple 8bits A
Dim shared rB  As Integer ' registro simple 8bits B
Dim shared rDP as Integer ' registro simple 8bits D (tambien llamado DP)

' registros de estado CC
Dim Shared ccc As Integer
Dim Shared ccv As Integer
Dim Shared ccz As Integer
Dim Shared ccn As Integer
Dim Shared cci As Integer
Dim Shared cch As Integer
Dim Shared ccf As Integer
Dim Shared cce As integer

' variables para las rutinas de memoria (PEEK, POKE, PUSH Y PULL)
' T=temporal,V=valor,R=registro
Dim Shared PR As Integer
Dim Shared PT As Integer
Dim Shared PV As Integer

' variables uso general
Dim Shared r As Integer
Dim Shared v As Integer
Dim Shared vc As Integer
Dim Shared vd As Integer ' dato (normalmente leido de RAM)
Dim Shared vr As Integer ' registro RA,RB, etc
Dim Shared vt As Integer ' temporal
Dim Shared vv As Integer ' variable o registro

' interrupciones activas o no (uso exclusivo emulador, para ver su actividad)
Dim Shared firq_act As Integer = 0
Dim Shared irq_act  As Integer = 0
Dim Shared nmi_act  As Integer = 0

' rutina de chequeo de BITS de un registro: devuelve 0 o 1
Declare function cogebit(dato As integer, bite As integer) As Integer

' CPU
Dim Shared addrmode  As Integer ' almacena el modo de direccionamiento de la CPU
dim shared cicloscpu as Integer ' almacena los ciclos de reloj a emplear en la instruccion
Declare Sub      m6809_irq()
Declare Sub      m6809_firq()
Declare Sub      m6809_NMI()
Declare sub      m6809_reset()
Declare Sub      m6809_runins(ins As Integer)
Declare Function m6809_execute() As Integer

' registro CC de estado e instruccion EXG
Declare function get_CC () As Integer 
declare sub      set_CC (i As Integer)
Declare function Get_VAR(t As integer)  As Integer
declare sub      Set_VAR(t As integer,r As Integer)

' PUSH y PULL y variables asociadas temporales, para saber donde queda la pila al acabar
declare sub Push(d1 As integer, d2 As integer, PR As Integer)
declare sub Pull(d1 As integer, d2 As integer, PR As Integer)
Dim Shared  d1temp As Integer
Dim Shared  d2temp As Integer

' grupos 2 y 3 de instrucciones
Declare sub grupo2()
declare sub grupo3()

' rutinas de activado/lectura de estados de registros
Declare sub SET_Z8    (a As Integer)    
Declare sub SET_Z16   (a As Integer)   
Declare sub SET_N8    (a As Integer)
Declare sub SET_N16   (a As Integer)    
Declare sub SET_C8    (a As Integer)    
Declare sub SET_C16   (a As Integer)     
Declare sub SET_NZ8   (a As Integer)        
Declare sub SET_NZ16  (a As Integer)    
Declare sub SET_V8    (a As integer,b As integer,r As Integer)  
Declare sub SET_V16   (a As integer,b As integer,r As Integer)   
Declare sub SET_NZVC8 (a As integer,b As integer,r As Integer)  
Declare sub SET_NZVC16(a As integer,b As integer,r As Integer) 
Declare sub SET_H     (a As integer,b As integer,r As Integer)  

' rutinas de obtencion de datos en 8 y 16bits
Declare sub      set_rd(d As Integer)            ' set_rd pone en D (registro RD) A*256+B
Declare Function get_rd(            ) As Integer ' get_rd coje en D (registro RD) A*256+B

' instrucciones 6809
declare sub nulo()
declare sub abx()
declare sub adca()
declare sub adcb()
declare sub adda()
declare sub addb()
declare sub addd()
declare sub anda()
declare sub andb()
declare sub andc()
declare sub asla()
declare sub aslb()
declare sub asl()
declare sub asra()
declare sub asrb()
declare sub asr()
declare sub bita()
declare sub bitb()
declare sub clra()
declare sub clrb()
declare sub clr()
declare sub cmpa()
declare sub cmpb()
declare sub cmpd()
declare sub cmps()
declare sub cmpu()
declare sub cmpx()
declare sub cmpy()
declare sub coma()
declare sub comb()
declare sub com()
declare sub cwai()
declare sub daa()
declare sub deca()
declare sub decb()
declare sub dec()
declare sub eora()
declare sub eorb()
declare sub exg()
declare sub inca()
declare sub incb()
declare sub inc()
declare sub jmp()
declare sub jsr()
declare sub lda()
declare sub ldb()
declare sub ldd()
declare sub lds()
declare sub ldu()
declare sub ldx()
declare sub ldy()
declare sub leas()
declare sub leau()
declare sub leax()
declare sub leay()
declare sub lsra()
declare sub lsrb()
Declare sub lsr()
declare sub mul()
declare sub nega()
declare sub negb()
declare sub neg()
declare sub nop()
declare sub ora()
declare sub orb()
declare sub orcc()
declare sub pshs()
declare sub pshu()
declare sub puls()
declare sub pulu()
declare sub rola()
declare sub rolb()
declare sub rol()
declare sub rora()
declare sub rorb()
declare sub ror()
declare sub rti()
declare sub rts()
declare sub sbca()
declare sub sbcb()
declare sub sex()
declare sub sta()
declare sub stb()
declare sub std()
declare sub sts()
declare sub stu()
declare sub stx()
declare sub sty()
declare sub suba()
declare sub subb()
declare sub subd()
declare sub swi()
declare sub swi2()
declare sub swi3()
declare sub syn()
declare sub tfr()
declare sub tsta()
declare sub tstb()
declare sub tst()
declare sub bcc()
declare sub lbcc()
declare sub bcs()
declare sub lbcs()
declare sub beq()
declare sub lbeq()
declare sub bge()
declare sub lbge()
declare sub bgt()
declare sub lbgt()
declare sub bhi()
declare sub lbhi()
declare sub ble()
declare sub lble()
declare sub bls()
declare sub lbls()
declare sub blt()
declare sub lblt()
declare sub bmi()
declare sub lbmi()
declare sub bne()
declare sub lbne()
declare sub bpl()
declare sub lbpl()
declare sub bra()
declare sub lbra()
declare sub brn()
declare sub lbrn()
declare sub bsr()
declare sub lbsr()
declare sub bvc()
declare sub lbvc()
declare sub bvs()
declare sub lbvs()

' funciones de memoria
Declare function peekb (adr As integer) As Integer       ' coge un byte sin mas
Declare function peekw (adr As integer) As Integer       ' coge una palabra sin mas
Declare function peekxb ()  As Integer                   ' coge un byte segun el modo de direccionamiento
Declare function peekxw ()  As Integer                   ' coge una palabra segun el modo de direccinamiento
Declare sub      pokeb (adr As integer, valor As Integer)' pokea un byte sin mas
declare sub      pokew (adr As integer, valor As Integer)' pokea una palabra sin mas
Declare Function get_byte ()As Integer                   ' coge un byte e incrementa PC en 1
Declare Function get_word ()as Integer                   ' coge una palabra e incrementa PC en 2

' modos de direccionamiento (0 al 6)
Declare function nib5    (v As integer) As Integer ' obtiene el "Nibble5", para el modo IDX
Declare Function get_modob  as Integer ' elige el modo de direccionamiento de byte
Declare Function get_modow()As Integer ' elige el modo de direccionamiento de palabra
Declare Function mop_null ()As Integer ' nulo
Declare Function mop_inmb ()As Integer ' inmediato byte
Declare Function mop_inmw ()As Integer ' inmediato palabra
Declare Function mop_dir  ()As Integer ' directo
Declare Function mop_idx  ()As Integer ' indexado
Declare Function mop_ext  ()As Integer ' extendido
Declare Function mop_relb ()As Integer ' relativo byte
Declare Function mop_relw ()As Integer ' relativo palabra