' testeo de bits (se puede emplear la rutina BIT del FreeBasic)
Function cogebit(v As integer, b As integer) As Integer
 If (v And b) Then Return 1 Else Return 0
End Function


' rutinas de activado/lectura de Estados 
Sub SET_N8 (a As Integer) 
	ccn = (a and &h80   ) Shr 7
End Sub

Sub SET_N16(a As Integer) 
	ccn = (a and &h8000 ) Shr 15
End Sub

Sub SET_C8 (a As Integer) 
	ccc = (a and &h100  ) Shr 8 
End Sub

Sub SET_C16(a As Integer) 
	ccc = (a and &h10000) Shr 16 
End Sub

sub SET_Z8(a As Integer)     
	ccz = ((a And &hff)=0) *-1
End Sub

sub SET_Z16(a As Integer)     
	ccz = ((a And &hffff)=0) *-1
End Sub

sub SET_V8(a As integer,b As integer,r As Integer)   
	ccv = ((a xor b xor r xor (r Shr 1)) And &h80  ) Shr 7
End Sub

sub SET_V16(a As integer,b As integer,r As Integer)   
	ccv = ((a xor b xor r xor (r Shr 1)) And &h8000) Shr 15
End Sub

sub SET_H(a As integer,b As integer,r As Integer)    
	cch = ((a xor b Xor r              ) And &h10  ) Shr 4
End Sub

sub SET_NZ8(a As Integer)         
	SET_N8(a)
	SET_Z8(a)
End Sub

sub SET_NZ16(a As Integer)        
	SET_N16(a)
	SET_Z16(a)
End Sub

sub SET_NZVC8(a As integer,b As integer,r As Integer)    
	SET_NZ8(r)
	SET_V8 (a,b,r)
	SET_C8 (r)
End Sub

sub SET_NZVC16(a As integer,b As integer,r As Integer)   
	SET_NZ16(r)
	SET_V16 (a,b,r)
	SET_C16 (r)
End Sub