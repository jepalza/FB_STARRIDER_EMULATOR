# FB_STARRIDER_EMULATOR
Freebasic emulador del juego Arcade LaserDisc StarRider
====================================================================

Actualizacion Octubre 2024:
Gracias a SynaMax (SynaMaxMusic) hemos logrado hacer funcionar el video sincronizado y los colores corregidos. Ahora se puede decir que funciona correcto, lo suficiente para poder jugar partidas Ademas, SynaMax ha proporcionado un nuevo "FRONTAL.BMP" que permite un mejor centrado del video de fondo (ahora los motoristas aparecen en el centro de la carretera)

https://youtu.be/tDmyhce6RxQ  (nota: el video es de antes de lograr el nuevo centrado en pantalla)

-------------------------------------------------------------
notas:
el emulador funciona a un 90%, le falta únicamente el sonido, que por problemas de velocidad al estar hecho enteramente en Basic, no es sencillo de implementar (aún).
Necesitaras una carpeta llamada ROMS:

' ROMS de la CPU

	LeeROM("roms/R30U8.CPU" ,3) 
 
	LeeROM("roms/R31U15.CPU",4) 
 
	LeeROM("roms/R32U26.CPU",5) 
   
	LeeROM("roms/R34U45.CPU",7) (mejor emplear "roms/rom_34.u45")
 
	LeeROM("roms/R35U52.CPU",8) (mejor emplear "roms/rom_35.u52")


' 16k : graficos generales	

' fila "par"
   
	LeeROM("roms/R1U4.ROM  ",09)
 
	LeeROM("roms/R3U5.ROM  ",10)
 
	LeeROM("roms/R5U6.ROM  ",11)
 
	LeeROM("roms/R7U7.ROM  ",12)
 
	LeeROM("roms/R9U8.ROM  ",13)
 
	LeeROM("roms/R11U9.ROM ",14)
 
	LeeROM("roms/R13U10.ROM",15) 	
 
	LeeROM("roms/R15U11.ROM",16) 
 
	LeeROM("roms/R17U12.ROM",17)
 
	LeeROM("roms/R19U13.ROM",18) 
 
 
' fila "impar"	
 
	LeeROM("roms/R2U19.ROM ",19)
 
	LeeROM("roms/R4U20.ROM ",20)
 
	LeeROM("roms/R6U21.ROM ",21)
 
	LeeROM("roms/R8U22.ROM ",22)
 
	LeeROM("roms/R10U23.ROM",23)
 
	LeeROM("roms/R12U24.ROM",24)
 
	LeeROM("roms/R14U25.ROM",25)
 
	LeeROM("roms/R16U26.ROM",26)
 
	LeeROM("roms/R18U27.ROM",27)
 

' 8k : graficos de textos	

	LeeROM("roms/R25U46.ROM",33)
 

' PIF: Processor Interface Board (por ahora no necesaria)

	'LeeROM("roms/R26U3.ROM ",49)
 

' SND: Sound Board (por ahora no necesaria)

	'LeeROM("roms/R27U11.ROM",50)
 

'PROMS de colores

	LeePROM("roms/u10.82s137")
 
	'LeePROM("roms/u11.82s137") (identica a la anterior, no necesaria)
 

 Ademas, un vídeo llamado "StarRider_Xvid.avi" dentro de una carpeta "video" 
 
 El vídeo, por razones de permisos, no puedo publicarlo, el juego puede funcionar sin el video

 Teclas:
 
 cursores y Z+X para control. 
 
 3 para monedas e iniciar juego (o Z para iniciar)
 
 W para entrar en modo chequeo 
 
 Q para avanzar o aceptar modos
 
 E para reiniciar CMOS
 
 F1 para entrar en modo depuracion
 
 ----------------------------------------------

Historia:

El primer intento fue en 2001 con unas ROM logradas mediante los "viejas" BBS

Pero no fue hasta aproximadamente en 2007, cuando decidí darle un buen empujón. Durante los anteriores 17 años lo he retomado y abandonado muchas veces, siempre por falta de información.
Llevaba abandonado unos 6 años, por problemas técnicos que impiden su continuación.

Pero gracias a SynaMax (Max) en 2024 he logrado averiguar varios fallos que me impedian continuar.

La única película existente que tenía, en la que me basé todos estos anteriores años, me la pasaron en 2011,pero la banda de datos no es 100% correcta debido a que se capturó la película con diferentes cuadros por segundo (¿variables?) lo que hacía que algunos de los datos daban saltos y se perdía información, haciendo que el juego acabara descompasado respecto al video, haciéndolo injugable.

Una gran fuente de inspiración ha sido:

http://www.dragons-lair-project.com/games/pages/sr.asp

-------------------------------------------

Este emulador esta hecho al 100% en Basic de FreeBasic.

Algunos videos publicados por mi en estos años:

https://www.youtube.com/watch?v=27pyGSNUNC4

https://www.youtube.com/watch?v=fSAn1RJJ1Eg

https://www.youtube.com/watch?v=tVKwQn9zctA


![Imagen starrider](https://github.com/jepalza/FB_STARRIDER_EMULATOR/blob/main/fb_starrider.png)

---------------------------------------
Información que ya conozco (retroingeniería):

![Imagen starrider](https://github.com/jepalza/FB_STARRIDER_EMULATOR/blob/main/info/ya_conocidos.png)
