'consolePrint.bi
'
#include once "windows.bi"
'
type tagConPrintDat
    cinfo as CONSOLE_SCREEN_BUFFER_INFO
    chand as HANDLE
end type
'
type tagConPrintObject
    declare function ConsoleCheck() as HANDLE
    declare function ConsolePrint(outtext as string ="",CRLF as string ="") as integer
    declare function ConsoleLocate(row as integer =1,col as integer =1) as integer
    declare function ConsoleColor(foreground as integer,background as integer) as integer
    declare function ConsoleCursor(size as integer =10,visible as integer =TRUE) as integer
    declare function ConsoleTitle(titleText as string) as integer
    declare function ConsoleCls() as integer
    declare function ConsoleMove(col as integer =1,row as integer =1) as integer
    declare function ConsoleVisible(state as integer =TRUE) as integer
    status as integer
    ConPrintDat as tagConPrintDat
end type
'
function tagConPrintObject.ConsoleCheck() as HANDLE
'
    this.status=0
    '
   dim as HANDLE chand=GetStdHandle(STD_OUTPUT_HANDLE)
   if chand<1 then
        this.status=1
        return chand
   end if
    '
    ConPrintDat.chand=chand
    '
    GetConsoleScreenBufferInfo(chand,@this.ConPrintDat.cinfo)
    '   
    return chand
'
end function
'
function tagConPrintObject.ConsolePrint(outtext as string,CRLF as string="") as integer
'
    this.status=0
    '
    dim as HANDLE chand=Consolecheck
    if chand<1 then this.status=1:return 0
    '
    dim as integer res,byteswritten
    '
    if CRLF="" then outtext+=chr(10)
    '
    res=WriteConsole(_
            chand,_
            strptr(outtext),_
            len(outtext),_
            @byteswritten,_
            NULL)
    '   
    if res=0 then this.status=2
    '
    return 0
'
end function
'
function tagConPrintObject.ConsoleLocate(row as integer =1,col as integer =1) as integer
'
    this.status=0
    '
    dim as HANDLE chand=Consolecheck
    if chand<1 then this.status=1:return 0
    '
    if col<0 orElse row<0 then
        this.status=2
        return 0
    end if
    '
    dim as integer res
    '
    dim as COORD cloc
    cloc.X=col
    cloc.Y=row
    '
    res=SetConsoleCursorPosition(_
            chand,_
            cloc)
    '
    if res=0 then this.status=3   
    '
    return 0
'
end function
'
function tagConPrintObject.ConsoleColor(foreground as integer,background as integer) as integer
'
    this.status=0
    '
    dim as HANDLE chand=Consolecheck
    if chand<1 then this.status=1:return 0
    '
    dim as integer res,outcolor
    '
    outcolor=(foreground OR background)
    '
    res=SetConsoleTextAttribute(_
            chand,_
            outcolor)
    '
    if res=0 then this.status=2
    '
    return 0
'
end function
'
function tagConPrintObject.ConsoleCursor(size as integer,visible as integer) as integer
'
    this.status=0
    '
    dim as HANDLE chand=Consolecheck
    if chand<1 then this.status=1:return 0
    '
    dim as integer res
    dim cursorinf as CONSOLE_CURSOR_INFO
    cursorinf.dwSize=size
    cursorinf.bVisible=visible
    '
    res=SetConsoleCursorInfo(_
            chand,_
            @cursorinf)
    '
    if res=0 then this.status=2
    '
    return 0
'
'See: http://msdn.microsoft.com/en-us/library/windows/desktop/ms682068(v=vs.85).aspx
'
end function
'
function tagConPrintObject.ConsoleTitle(titleText as string) as integer
'
    this.status=0
    '
    dim as HANDLE chand=Consolecheck
    if chand<1 then this.status=1:return 0
    '
    dim as integer res,byteswritten
    '
    res=SetConsoleTitle(strptr(titleText))
    '   
    if res=0 then this.status=2
    '
    return 0
'
end function
'
function tagConPrintObject.ConsoleCls() as integer
'
    this.status=0
    '
    dim as HANDLE chand=Consolecheck
    if chand<1 then this.status=1:return 0
    '
    shell("cls")
    '   
    return 0
'
end function
'
function tagConPrintObject.ConsoleMove(col as integer =1,row as integer =1) as integer
'
    this.status=0
    '
    dim as HANDLE chand=Consolecheck
    if chand<1 then this.status=1:return 0
    '
    dim as HWND chwnd=GetConsoleWindow
    if chwnd=NULL then this.status=2:return 0
    '
    dim as integer res
    '
    res=SetWindowPos(_
            chwnd,0,col,row,0,0,_
            SWP_NOSIZE or SWP_NOZORDER)
    '   
    return 0
'
end function
'
function tagConPrintObject.ConsoleVisible(state as integer =TRUE) as integer
'
    this.status=0
    '
    dim as HANDLE chand=Consolecheck
    if chand<1 then this.status=1:return 0
    '
    dim as HWND chwnd=GetConsoleWindow
    if chwnd=NULL then this.status=2:return 0
    '
    dim as integer res
    '
    if state=TRUE then
        state=SW_SHOW
    else
        state=SW_HIDE
    end if
    '
    res=ShowWindow(chwnd,state)
    '   
    return 0
'
end function
'
'/Consolefunctions/consolePrint.bi
