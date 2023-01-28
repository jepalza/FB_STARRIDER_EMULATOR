'**** 6809 DESENSAMBLADOR ****
' COMPILAR CON DEPRECATED O CON FB(WINDOWS-GUI) (MEJOR FB, MAS MODERNO)

' para que funcione como desensamblador de linea en el emul del 6809
' añadir esta linea:
'  ... Declare Sub M6809_DIS(DIRECCION As integer, longitud As integer)
' al inicio del emulador
' y llamarla con la direccion a desensamblar y un solo byte como longitud, para una sola linea

DECLARE FUNCTION OFF8 (A AS integer) AS Integer
DECLARE FUNCTION OFF16(A AS integer) AS Integer
DECLARE FUNCTION HEX8 (A AS Integer) AS STRING
DECLARE FUNCTION HEX16(A AS Integer) AS String

Dim SHARED INS1(2,15) AS STRING
DIM SHARED INS2(3,15) AS STRING
DIM SHARED REG1(3)    AS STRING
DIM SHARED REG2(11)   AS STRING

DIM SHARED DI AS STRING
DIM SHARED AM AS STRING
DIM SHARED JK AS STRING
DIM SHARED HX AS STRING
DIM SHARED SP AS STRING
DIM SHARED RR AS STRING
DIM SHARED IN AS STRING

Dim Shared II AS Integer
Dim Shared JJ AS Integer
DIM SHARED AC AS Integer
DIM SHARED AB AS Integer
DIM SHARED AD AS Integer
DIM SHARED VM AS Integer
DIM SHARED MV AS Integer 
DIM SHARED NS AS Integer
DIM SHARED MS AS Integer
DIM SHARED LS AS Integer
DIM SHARED OS AS Integer
DIM SHARED RE AS Integer
DIM SHARED RT AS Integer
Dim SHARED PA AS Integer
DIM SHARED PB AS Integer 
DIM SHARED LA AS Integer
DIM SHARED MT AS Integer
Dim SHARED IB AS Integer
DIM SHARED IR AS Integer
DIM SHARED LN AS Integer = 0


Sub M6809_dis(DIRECCION As integer, longiTUD As Integer)
 AD=DIRECCION
 LA=longiTUD	
	
  ' LECTURA DE INSTRUCCIONES COMO TEXTO
  Restore INSTRUCCIONES
 
  ' INSTRUCCIONES DE UN BYTE
  FOR  II=0 TO 2
   FOR  JJ=0 TO 15
     READ INS1(II,JJ)
   NEXT
  NEXT

  ' INSTRUCCIONES DE DOS BYTES
  FOR  II=0 TO 3
   FOR  JJ=0 TO 15
     READ INS2(II,JJ)
   NEXT
  NEXT

 ' REGISTROS
 FOR  II=0 TO 11:READ REG2(II):NEXT 

 ' REGISTROS 16bits
 REG1(0)="X"
 REG1(1)="Y"
 REG1(2)="U"
 REG1(3)="S"

INICIO:
 NS=0:VM=RAM(AD):AM="":PA=0
 MS=INT(VM/16):LS=VM-16*MS
 IF  VM=16 Then GoTo SEGUNDAPAGINA 
 IF  VM=17 Then GoTo TERCERAPAGINA 
 IF  MS>3  THEN GOTO TABLA_M       

TABLA_S:
'     ********** TABLA "S" **********
 NS=1
 IF  MS=1 AND (LS<4 OR LS=9 OR LS=13)  THEN  NS=0
 IF  MS=1 AND (LS=6 OR LS=7)           THEN  NS=2
 IF  MS=3 AND  LS>8 AND LS<>12         THEN  NS=0
 IN=INS2(MS,LS)
 ON MS GOTO L4,L5,L6

DIRECT:
 AB=AD+1:HX = HEX8(AB)				    ' [MS NIBBLE=0 : DIRECT PAGE]
 AM="<"+HX:GOTO SALIDA_DATOS

L4:
 IF  NS=0  THEN  GOTO SALIDA_DATOS ' [MS NIBBLE=1]
 IF  NS=1 AND  LS<13  THEN  AB=AD+1:HX = HEX8(AB):AM="#"+HX:GOTO SALIDA_DATOS
 IF  NS=1  THEN  GOTO L2:
 
L3:
 AB=AD+1:OS = OFF16(AB)
 AM=HEX(AD+3+OS)
 AM=""+STRING(4-LEN(AM),"0")+AM:GOTO SALIDA_DATOS

L2:
 RE=INT(RAM(AD+1)/16):RT=RAM(AD+1)-16*RE
 AM=REG2(RE)+","+REG2(RT):GOTO SALIDA_DATOS

L5:
 AB=AD+1:OS = OFF8(AB)				 ' [MS NIBBLE=2]
 AM=HEX(AD+2+OS)
 AM=""+STRING(4-LEN(AM),"0")+AM:GOTO SALIDA_DATOS

L6:
 IF NS= 0 THEN GOTO SALIDA_DATOS	 ' [MS NIBBLE=3]
 IF LS=12 THEN AB=AD+1:HX = HEX8(AB):AM="#"+HX:GOTO SALIDA_DATOS
 IF LS< 4 THEN GOTO INDEXAR
 PB=RAM(AD+1)
 IF  LS<6 THEN SP="U,"ELSE SP="S,"
 IF (PB And   1) THEN AM=AM+"CC,"
 IF (PB And   2) THEN AM=AM+"A,"
 IF (PB And   4) THEN AM=AM+"B,"
 IF (PB And   8) THEN AM=AM+"DP,"
 IF (PB And  16) THEN AM=AM+"X,"
 IF (PB And  32) THEN AM=AM+"Y,"
 IF (PB And  64) THEN AM=AM+SP
 IF (PB And 128) THEN AM=AM+"PC,"
 AM=LEFT(AM,LEN(AM)-1)
 GOTO SALIDA_DATOS

SEGUNDAPAGINA:
'    ********** SEGUNDA PAGINA **********
 PA=1
 AD=AD+1
 MV=RAM(AD)
 MS=INT(MV/16)
 LS=MV-16*MS
 IF MS>2 THEN GOTO L7
 NS=2:IN="L"+INS2(MS,LS)
 GOTO L3

L7:
 IF MS= 3 And LS=15 THEN IN="SWI2": GOTO SALIDA_DATOS
 IF MS> 7 And LS= 3 THEN IN="CMPD": GoTo MODO_DIR
 IF MS> 7 And LS=12 THEN IN="CMPY": GoTo MODO_DIR
 IF MS>11 And LS=14 THEN IN="LDS" : GoTo MODO_DIR
 IF MS>11 And LS=15 THEN IN="STS" : GoTo MODO_DIR
 IF MS> 7 And MS<12 And LS=14 THEN IN="LDY":GOTO MODO_DIR
 IF MS> 7 And MS<12 And LS=15 THEN IN="STY":GOTO MODO_DIR
 'PRINT "ERROR 1":SLEEP

TERCERAPAGINA:
'     ********** TERCERA PAGINA **********
 PA=1
 AD=AD+1
 MV=RAM(AD)
 MS=INT(MV/16)
 LS=MV-16*MS
 IF LS= 3 THEN IN="CMPU": GoTo MODO_DIR
 IF LS=12 THEN IN="CMPS": GoTo MODO_DIR
 IF LS=15 THEN IN="SWI3": GOTO SALIDA_DATOS
 'PRINT"ERROR 2":SLEEP

TABLA_M:
'     ********** TABLA "M" **********
 IF MS <8 THEN MT=0:GOTO M1
 IF MS<12 THEN MT=1:GOTO M1
 MT=2

M1:
IN=INS1(MT,LS)
 IF MS=8AND LS=13 THEN IN="BSR":NS=1:GOTO L5
 IF MS>5 THEN GOTO MODO_DIR
 IF MS=4 THEN AM="A": GOTO SALIDA_DATOS
 AM="B": GOTO SALIDA_DATOS

' MODOS DE DIRECCIONAMIENTO
MODO_DIR:
 AC=MS AND 3
 IF AC=2 THEN GOTO INDEXAR     ' [INDEXED]
 IF AC=1 THEN NS=1:GOTO DIRECT ' [DIRECT PAGE]
 IF AC=0 THEN GOTO INMEDIATE   ' [IMMEDIATE]
 NS=2:AB=AD+1:HX = HEX16(AB)   ' [EXTENDED]
 AM=">"+HX: GOTO SALIDA_DATOS

INMEDIATE:
 IF LS=3 OR LS=12 OR LS=14 THEN NS=2: GOTO L1
 NS=1:AB=AD+1:HX = HEX8(AB)
 AM="#"+HX: GOTO SALIDA_DATOS
 
L1:
 AB=AD+1:HX = HEX16(AB)
 AM="#"+HX: GOTO SALIDA_DATOS

'     ********** SALIDA DE DATOS  **********
SALIDA_DATOS:
 ' ventana normal
 'Locate 1,1:Print Space$(48):Locate 1,1
 'Print HEX(AD-PA);" "; 
 'IF PA=1 THEN PRINT TAB(6);HEX(RAM(AD-1));
 'FOR II=0 TO NS:AB=AD+II:HX = HEX8(AB)
 '  PRINT TAB(9+3*II);RIGHT(HX,2);
 'Next 
 'PRINT TAB(21);IN;
 'PRINT TAB(27);AM;
 'Print "    "
 
 ' consola de comandos (teniendo una grafica aparte)
 prt 1,1,Space(48)
 prt 1,1,Hex(AD-PA)
 IF PA=1 THEN prt 1,6,Hex(RAM(AD-1))
 FOR II=0 TO NS:AB=AD+II:HX = HEX8(AB)
   prt 1,(9+3*II),Right(HX,2)
 Next 
 prt 1,21,IN
 prt 1,27,AM+"    "


 ' INCREMENTA DIRECCION
 AD=AD+NS+1

' SI NO HEMOS LLEGADO AL FINAL (LA BYTES +AD DIRECCION INICIO), HACEMOS BUCLE
IF AD>LA THEN 
	Exit SUB 
Else 
	GOTO INICIO
EndIf


' **********************************************************************************
'                        SS  UU  BB  RR  UU  TT  II  NN  AA  SS 
' **********************************************************************************


'     ********** INDEXADO **********
INDEXAR:
 NS=1
 IB=RAM(AD+1)
 IR=INT((IB AND 96)/32):RR=REG1(IR)
 IF (IB AND 128) THEN GOTO ADDINDEX
 OS=IB AND 31		' [5 BIT OFFSET]
 IF (OS AND 16) THEN OS=OS-32
 HX=STR(OS)
 AM=HX+","+RR: GOTO SALIDA_DATOS

ADDINDEX:
 SELECT CASE (IB AND 15)
 	CASE 0
 		AM=","+RR+"+"
 	CASE 1
 		AM=","+RR+"++"
 	CASE 2
 		AM=",-"+RR
 	CASE 3
 		AM=",--"+RR
 	CASE 4
 		AM=","+RR
 	CASE 5
 		AM="B,"+RR
 	CASE 6
 		AM="A,"+RR
 	CASE 7,10,14
 		AM="ILEGAL"
 	CASE 8
 		NS=2:AB=AD+2:OS = OFF8(AB):AM=STR(OS)+","+RR
 	CASE 9
 		NS=3:AB=AD+2:OS = OFF16(AB):AM=STR(OS)+","+RR
 	CASE 11
 		AM="D,"+RR
 	CASE 12
 		NS=2:AB=AD+2:OS = OFF8(AB)
 		AM=STR(OS)+",PC("+HEX(AD+3+OS)+")"
 	CASE 13
 		NS=3:AB=AD+2:OS = OFF16(AB)
 		AM=STR(OS)+",PC("+HEX(AD+4+OS)+")"
 	CASE 15
 		NS=3:AB=AD+2:HX = HEX16(AB):AM=HX
 END SELECT

 IF (IB AND 16) THEN AM="["+AM+"]"
GOTO SALIDA_DATOS
End Sub

FUNCTION OFF8 (AB AS integer) AS Integer
 '     ********** CALCULA OFFSET 8BIT **********
 OS=RAM(AB)
 IF (OS AND 128) THEN OS=OS-256
 OFF8=OS
END FUNCTION

FUNCTION OFF16 (AB AS integer) AS Integer
 '     ********** CALCULA OFFSET 16BIT **********
 OS=RAM(AB)*256+RAM(AB+1)
 IF (RAM(AB)AND 128) THEN OS=OS-65536
 OFF16=OS
END FUNCTION

FUNCTION HEX8 (AB AS Integer) AS STRING
 '     ***** GENERA DIRECCION 8BIT *****
 HX=HEX(RAM(AB))
 IF  LEN(HX)=1 THEN HX="0"+HX
 HX=""+HX
 HEX8=HX
END FUNCTION

FUNCTION HEX16 (AB AS Integer) AS STRING
 '     ***** GENERA DIRECCION 16BIT *****
 HX=HEX(RAM(AB)*256+RAM(AB+1))
 HX=""+STRING(4-LEN(HX),"0")+HX
 HEX16=HX
END Function

instrucciones:
 DATA "NEG" ,"----","----","COM" ,"LSR" ,"----","ROR","ASR","ASL" ,"ROL" ,"DEC","----","INC" ,"TST","JMP","CLR"
 DATA "SUBA","CMPA","SBCA","SUBD","ANDA","BITA","LDA","STA","EORA","ADCA","ORA","ADDA","CMPX","JSR","LDX","STX"
 DATA "SUBB","CMPB","SBCB","ADDD","ANDB","BITB","LDB","STB","EORB","ADCB","ORB","ADDB","LDD" ,"STD","LDU","STU"

 DATA "NEG" ,"----","----","COM" ,"LSR" ,"----","ROR" ,"ASR" ,"LSL" ,"ROL","DEC" ,"----","INC" ,"TST","JMP" ,"CLR"
 DATA "----","----","NOP" ,"SYNC","----","----","LBRA","LBSR","----","DAA","ORCC","----","ANDC","SEX","EXG" ,"TFR"
 DATA "BRA" ,"BRN" ,"BHI" ,"BLS" ,"BHS" ,"BLO" ,"BNE" ,"BEQ" ,"BVC" ,"BVS","BPL" ,"BMI" ,"BGE" ,"BLT","BGT" ,"BLE"
 DATA "LEAX","LEAY","LEAS","LEAU","PSHS","PULS","PSHU","PULU","----","RTS","ABX" ,"RTI" ,"CWAI","MUL","----","SWI"

 DATA "D","X","Y","U","S","PC","-","-","A","B","CC","DP"