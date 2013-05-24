#!/usr/bin/env bash
osascript - $1 $2 $3 <<END

on date_time_to_iso(dt)
	set {year:y, month:m, day:d, hours:h, minutes:min, seconds:s} to dt
	set y to text 2 through -1 of ((y + 10000) as text)
	set m to text 2 through -1 of ((m + 100) as text)
	set d to text 2 through -1 of ((d + 100) as text)
	set h to text 2 through -1 of ((h + 100) as text)
	set min to text 2 through -1 of ((min + 100) as text)
	set s to text 2 through -1 of ((s + 100) as text)
	#return y & "-" & m & "-" & d & "T" & h & ":" & min & ":" & s
	#set day_abbr to (text 1 thru 3 of ((weekday of dt) as string)) 
	return  d & "-" & m & "-" & y & " " & h & ":" & min
end date_time_to_iso


on run argv
	
	set lineacomando to "$ task [command:'list','new','completelast'] [namelist] "
	
	set lista to ""
	set tarea to ""	

	set comando to ""
	set cmdLIST to "list"
	set cmdNEW to "new"
	set cmdALL to "all"
	set cmdCALS to "cals"
	set cmdCOMPLETELAST to "completelast"
	set cmdCOMPLETELASTCAL to "completelastcal"
	set cmdNEXT to "next"
	
	set dato to ""	
	set cmdCAL to "cal"

	if (count argv) >= 1 then
		set comando to item 1 of argv
	end if

	if (count argv) >= 2 then 
		set lista to item 2 of argv
	end if 


	set mensaje to " -- Do it Simple ! -- "
	set salida to "" 




	if comando is equal to cmdLIST then
		
		tell application "Reminders"
			
			set ListaaMostrar to lista
			set todoList to name of reminders in list ListaaMostrar whose completed is false
			set salida to "\n"
			if (count of (reminders in list ListaaMostrar whose completed is false)) > 0 then
				repeat with itemNum from 1 to (count of (reminders in list ListaaMostrar whose completed is false))
					set salida to salida & "[" & lista & "] " & (item itemNum of todoList) & "\n"
				end repeat
			else 
				set salida to "No hay pendientes registrados"
			end if

		end tell


	else if comando is equal to cmdNEW then

		tell application "Terminal"
			set input to ""
			display dialog "Nombre de la tarea:" default answer input
 			set tarea to text returned of result
		end tell 

		tell application "Reminders"
			set ListaaMostrar to lista
			tell list ListaaMostrar
				if tarea is not equal to "" then				
					make new reminder with properties {name:tarea}	
					set salida to "\n[" & ListaaMostrar & "] " & tarea
				end if
			end tell 
		end tell

	else if comando is equal to cmdALL then
	
		tell application "Reminders"
			repeat with listNum from 1 to (count of lists)
				set idLista to (list listNum)
				tell idLista
					set salida to salida & "\n[" & name & "]"
				end tell
			end repeat
		end tell

	else if comando is equal to cmdCALS then

		tell application "Calendar" 
			set Calendarios to calendars #whose description is not ""
			repeat with calNum from 1 to (count of Calendarios)
				set calendario to item calNum of Calendarios
				tell calendario
					set salida to salida & "DESC: [" & description & "] NAME: " & name & "\n"
				end tell
			end repeat

		end tell		

	else if comando contains cmdCOMPLETELAST then 

		tell application "Reminders"
			
			set ListaaMostrar to lista		
			set todoList to name of reminders in list ListaaMostrar whose completed is false
			tell list ListaaMostrar
				set recordatorio to last reminder whose completed is false
				copy name of recordatorio to tarea 
				set completed of recordatorio to true
			
				set tarea to "[" & ListaaMostrar & "] " & tarea 	
				set salida to "\n" & tarea & " ✔  \n"
			end tell

		end tell

		if comando is equal to cmdCOMPLETELASTCAL then 

			tell application "Calendar"
	
				set idCalendario to (first calendar whose description is lista)
				set idEvento to make new event at end of events of idCalendario
	
				tell idEvento
					set summary to tarea
					set allday event to true
				end tell
	
				set salida to salida & " -- synced to calendar"
	
			end tell

		end if
	
	else if comando is equal to cmdNEXT then


		set {year:y, month:m, day:d} to current date
		set str to (d as string) & " " & (m as string) & " " & (y as string)
		set inicio to date str
		set fin to inicio + 60 * 60 * 24 * lista
		set salida to salida & "\n --- Next " & lista & " day's --- \n"	
		#set salida to salida & inicio

		set eventos_nombre_calendarios to {}
		set eventos_resumen to {}
		set eventos_fechai to {}
		set eventos_fechaf to {}
		set eventos_todoeldia to {}

		tell application "Calendar"
			set Calendarios to calendars #whose description is not ""
			repeat with calNum from 1 to (count of Calendarios)
				set calendario to item calNum of Calendarios
				tell calendario
					set nombre_calendario to name 
					 
        			repeat with evento in every event whose ((start date <= fin) and (end date >= inicio))
  
						tell evento
							set todoeldia to ""	
							if allday event then 
								set todoeldia to " -- allday"
							end if
							
							set end of eventos_nombre_calendarios to nombre_calendario
							set end of eventos_resumen to summary
							set end of eventos_fechai to start date
							set end of eventos_fechaf to end date
							set end of eventos_todoeldia to todoeldia

						end tell

					end repeat
				end tell
			end repeat
		end tell

		repeat with eNum from 1 to (count of eventos_resumen)	
			set salida to salida & "\n"

			set salida to salida & " " & date_time_to_iso(item eNum of eventos_fechai)
			set salida to salida & " >" 
			set salida to salida & " " & date_time_to_iso(item eNum of eventos_fechaf)

			set salida to salida & "\t"

			set salida to salida & " [" & item eNum of eventos_nombre_calendarios & "]"
			set salida to salida & " " & item eNum of eventos_resumen 
			set salida to salida & " " & item eNum of eventos_todoeldia 
		end repeat


	else 

		set salida to "Use me in this way:\n\n" & lineacomando
	
	end if 
			


	tell application "Terminal"
		set output to salida & "\n" #& "\n\n" & mensaje & "\n"
	end tell 

end
END

# Referencias
# http://www.macosxtips.co.uk/geeklets/productivity/mountain-lion-reminders-list/
# http://apple.stackexchange.com/questions/66981/how-can-i-add-reminders-via-the-command-line
# http://www.mactech.com/articles/mactech/Vol.21/21.11/ScriptingiCal/index.html
# http://www.mactech.com/articles/mactech/Vol.21/21.11/ScriptingiCal/index.html
