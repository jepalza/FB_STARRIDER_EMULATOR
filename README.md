# FB_STARRIDER_EMULATOR
Freebasic emulador del juego Arcade LaserDisc StarRider
====================================================================

Actualizacion Octubre 2024:
gracias a SynaMax (SynaMaxMusic) he (hemos) logrado hacer funcionar el video sincronizado y los colores corregidos. Ahora se puede decir que funciona correcto, lo suficiente para poder jugar partidas !!!! 
.
SynaMax ha proporcionado un nuevo "FRONTAL.BMP" que permite un mejor centrado del video de fondo (ahora los motoristas aparecen en el centro de la carretera)
video:
https://youtu.be/tDmyhce6RxQ
-------------------------------------------------------------
notas:
el emulador funciona a un 90%, le falta únicamente el sonido, que por problemas de velocidad al estar hecho enteramente en Basic, no es sencillo de implementar (aún).
Necesitaras una carpeta llamada ROMS:

' ROMS de la CPU

	LeeROM("roms/R30U8.CPU" ,3) 
 
	LeeROM("roms/R31U15.CPU",4) 
 
	LeeROM("roms/R32U26.CPU",5) 
 
  	'LeeROM("roms/xxxx37.CPU",5) 
   
	LeeROM("roms/R34U45.CPU",7) 
 
	LeeROM("roms/R35U52.CPU",8) 


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
 
	'LeeROM("roms/R25U46.ROM",28)
 

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
 
 cursores y Z+X para control. 3 para moneda e iniciar juego
 
 W para entrar en modo chequeo y Q para avanzar o aceptar modos
 
 E para reinicar CMOS
 
 F1 para entrar en modo depuracion
 
 ----------------------------------------------


Este es el primer intento de crear un emulador del juego StarRider Arcade LaserDisc.

Lo inicié aproximadamente en 2008, cuando aún nadie lo había intentado. Lleva abandonado unos 6 años, por problemas técnicos que impiden su continuación.
Algunos de esos problemas tienen que ver con la información obtenida desde la propia película del juego (la llamada "banda Manchester") que incluye datos del juego, como inercia, velocidad, curvatura/linealidad de los tramos de carretera, fuerza de cada curva, etc.

La única película existente que conzoco, me la pasaron hace muchos años, y la banda de datos no es 100% correcta debido a que se capturó la película con diferentes cuadros por segundo (¿variables?) lo que hacía que algunos de los datos daban saltos y se perdía información, haciendo que el juego acabara descompasado respecto al video, haciéndolo injugable.


Una gran fuente de inspiración ha sido:
http://www.dragons-lair-project.com/games/pages/sr.asp

------------------------------------------
Informacion
--
Para completar el emulador se necesita un VIDEO REAL al que poder extraer el MANCHESTER que indica el número de cuadro!!!!
puedo sacar los 42 datos de abajo (3 columnas por 14 filas), pero no puedoO sacar el número de cuadro, que son tres bytes mas
y que van , si no he investigado mal, en la fila 18 de los cuadros de sincronía (osea, arriba del todo, escondidos, no se ve, vendría antes de la primera línea visible)

en vista de que no puedo encontrar el cuadro leído, no encuentor manera de sincronizar el cuadro que leo de "mi actual vídeo", con el que el juego necesita.
Al no conseguir esa sincronía real, no hay manera de que el video vaya acompasado al juego, se lanza, o se retrasa, y se decompensa.
Es posible hacerlo compensando, pero no es lo mismo. puedo emular y decirle que el cuadro que he leído yo (de MI video), es el número "x", pero el juego tiene que creerselo, y si "mi" cuadro está desfasado, lo normal, dado que desconozco números de cuadros reales, se acaba descompensado

Haría falta un video real, leido con cuadros verdaderos, en los cuales, el cuadro "x" que pide el juego, sea el "x" del video.
o en su defecto, uno que contenga la linea manchester arriba.

mientras eso no ocurra, es difícil seguir emulando.

-------------------------------------------
Este emulador es mio al 100%, desarrollado a lo largo de muchos años de investigación, tanto mia propia como con ayuda de terceros (Matt ownby , auto del emulador Daphne).

Algunos videos publicados por mi en estos años:

https://www.youtube.com/watch?v=27pyGSNUNC4

https://www.youtube.com/watch?v=fSAn1RJJ1Eg

https://www.youtube.com/watch?v=tVKwQn9zctA


![Imagen starrider](https://github.com/jepalza/FB_STARRIDER_EMULATOR/blob/main/fb_starrider.png)

---------------------------------------
Información que ya conozco (retroingeniería):

![Imagen starrider](https://github.com/jepalza/FB_STARRIDER_EMULATOR/blob/main/info/ya_conocidos.png)
