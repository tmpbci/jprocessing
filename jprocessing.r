
REBOL [ Title: "Mind Processing" 
	author: JGC
	note: "Display live Mindset Raw Data"
	Version: 0.3
]

;;
;; Initial setup 
;;
do %jresources/ieee.r
xsig: xatt: xmed: yhgam: 5
ysigp: yattp: ymedp: yhgamp: 0
count: 1
average1: [0 0 0 0 0 0]
average2: [0 0 0 0 0 0]
average3: [0 0 0 0 0 0]
dmxcolor: [0 0 0 0 0 0]
oscpattern: [0 0 0 0 0 0]
dmxcolor/5: "000000"
dmxcolor/4: "000000"
dmxcolor/3: "000000"
dmxcolor/2: "000000"
dmxcolor/1: "000000"
vpcolor: [0 0 0 0 0 0]
data: make binary! 1000
namefile: %jresources/tosleep.csv
lightedport: 7000
host_name: system/network/host
lightedip: host_name
jliveipOUT: 127.0.0.1
jliveportOUT: 13856 
oscipOUT: "127.0.0.1"
oscportOUT: 8000
ledlvl: 10
leds1: "1,2,3,4,5"
leds2: "2"
leds3: "3"
leds4: "4"
leds5: "5"
lan: 0
osc: 0
forceset: 0
basemultiplier: 2
multiplier: basemultiplier
	

Get_Os: does [
	switch system/version/4 [
		3 [os: "Windows" countos: "n"]
		2 [os: "MacOSX" countos: "c"]
		4 [os: "Linux" countos: "c"]
		5 [os: "BeOS" countos: "c"]
		7 [os: "NetBSD" countos: "c"]
		9 [os: "OpenBSD" countos: "c"]
		10 [os: "SunSolaris" countos: "c"]
	]
]
;;
;; jROLLER Engine
;; 
doengine: does [
					data: 0
					if lan = 1 [
						newval: [count ysig yatt ymed yhgam yhgam yhgam yhgam yhgam yhgam yhgam yhgam]
				    	newdata: reform newval
				    	print newval
				    	insert outport newdata
				    	]
				    if osc = 1 [doosc]
					instruc/text: ""
					attlight: remove/part to-hex to-integer yatt 6
					h: to-integer multiplier * yhgam
					hval/text: form h
					show hval
					print ajoin [yhgam " " multiplier " " h]
					;print h
					huetorgb
					case [
					     all [ymed = 0 forceset = 0][
					     dmxcolor/5: ajoin ["00" attlight "00"]
					     case  [
					     		ysig > 100
					     					[lvlbox1/color: red
					     				 	lvlbox2/color: 60.0.0
					     				 	lvlbox3/color: 60.0.0
					     					lvlbox4/color: 60.0.0]
					     		all [ysig > 30	ysig < 60] 
					     					[lvlbox1/color: red
					     				 	lvlbox2/color: red
					     				 	lvlbox3/color: 60.0.0
					     				 	lvlbox4/color: 60.0.0]
					     	   all [ysig > 0 ysig < 30] 
					     					[lvlbox1/color: red
					     				 	lvlbox2/color: red
					     				 	lvlbox3/color: red
					     				 	lvlbox4/color: 60.0.0]
					     	 ysig = 0
					     					[lvlbox1/color: red
					     					 lvlbox2/color: red
					     					 lvlbox3/color: red
					     				 	 lvlbox4/color: red]
					     		]
					     	show lvlbox1
					     	show lvlbox2
					     	show lvlbox3
					     	show lvlbox4
					     vpcolor/5: 0.0.0
					     
						 ]
					  	 any [ymed > 0 forceset = 1][
					  	 dmxcolor/5: ajoin [RGB.RHex "" RGB.GHex "" RGB.BHex]
					  	 vpcolor/5: to-tuple (ajoin [RGB.R "." RGB.G "." RGB.B])
					  	 ]
						 ] 
					print ajoin [dmxcolor/5 " " dmxcolor/4 " " dmxcolor/3 " " dmxcolor/2 " " dmxcolor/1]
					print vpcolor/5
			    	do ajoin ["read http://" lightedip ":" lightedport "/" leds1 "/" dmxcolor/5]
			    	;do ajoin ["read http://" lightedip ":" lightedport "/" leds2 "/" dmxcolor/4]
			    	;do ajoin ["read http://" lightedip ":" lightedport "/" leds3 "/" dmxcolor/3]
			    	;do ajoin ["read http://" lightedip ":" lightedport "/" leds4 "/" dmxcolor/2]
			    	;do ajoin ["read http://" lightedip ":" lightedport "/" leds5 "/" dmxcolor/1]
			    	;vpbox1/color: vpcolor/5
			    	;show vpbox1
			    	vled1/color: vpcolor/1
			    	vled2/color: vpcolor/2
			    	vled3/color: vpcolor/3
			    	vled4/color: vpcolor/4
			    	vled5/color: vpcolor/5
			    	show vled1
			    	show vled2
			    	show vled3
			    	show vled4
			    	show vled5
			    	bigbox/color: vpcolor/5
			    	show bigbox
			    	average1/5: yhgam
			    	average1/6: ( average1/1 + average1/2 + average1/3 + average1/4 + average1/5 ) / 5
			    	either average1/6 > 7 [hgambciled/data: true] [hgambciled/data: false]
			    	average1/1: average1/2
					average1/2: average1/3
					average1/3: average1/4
					average1/4: average1/5
					dmxcolor/1: dmxcolor/2
					dmxcolor/2: dmxcolor/3
					dmxcolor/3: dmxcolor/4
					dmxcolor/4: dmxcolor/5
					vpcolor/1: vpcolor/2
					vpcolor/2: vpcolor/3
					vpcolor/3: vpcolor/4
					vpcolor/4: vpcolor/5
					count: count + 1
					tcount/text: form count
					status/text: "Connected. Improve signal to calibrate"
					if any [ymed <> 0 forceset = 1]    
									[status/text: "Calibrated"
									 hide lvlbox1
									 hide lvlbox2
									 hide lvlbox3
									 hide lvlbox4
									]
					if yhgam = average1/3 [status/text: "Error TGC"]
					show tcount
					show hgambciled
					hgamval/text: yhgam
					show hgamval
					hval/text: h
					show hval
]
;;
;; Monome Command
;;

doosc: does [
			elementx: to-integer yhgam
			oscpattern/5: min elementx 255 ; 8bits max
			oscommand: ajoin [oscipOUT " " oscportOUT " /40h/frame 0 " oscpattern/5 " " oscpattern/4 " " oscpattern/3 " " oscpattern/2 " " oscpattern/1 " 0 0"]	
			insert oscport oscommand
			oscpattern/1: oscpattern/2
			oscpattern/2: oscpattern/3
			oscpattern/3: oscpattern/4
			oscpattern/4: oscpattern/5
			]
;;
;; yhgam is Hue. Conversion to RGB  
;;

huetorgb: does [
	
	s: 80
	v: 80
	
	s: s / 100
	v: v / 100
	either s = 0 [RGB.R: v * 255
		 		  RGB.G: v * 255
				  RGB.B: v * 255]

			[h: h / 60
			idec: to-integer h
			f: h - idec
			h1: v * (1 - s)
			h2: v * (1 - (s * f))
			h3: v * ((1 - s) * (1 - f))
		
			case [
				idec = 0 [ r: v 
					    g: h3 
					    b: h1]
					  
				idec = 1 [ r: h2
					    g: v 
					    b: h1]
			
				idec = 2 [ r: h1 
			 			g: v 
						b: h3]
			 
				idec = 3 [ r: h1
						g: h2 
						b: v]
						
				idec = 4 [ r: h3 
				  		g: h1 
				  		b: v]
				  		 
				idec > 4 [ r: v
				  		g: h1 
				  		b: h2]
				]
			RGB.R: to-integer (r * 255)
			RGB.G: to-integer (g * 255)
			RGB.B: to-integer (b * 255)
			RGB.Rhex: remove/part to-hex RGB.R 6
			RGB.Ghex: remove/part to-hex RGB.G 6
			RGB.Bhex: remove/part to-hex RGB.B 6
		    ]
	]



;;
;; Controllers UI
;;
controllers: layout [
	anti-alias on
	backdrop effect [gradient 1x1 0.0.0 50.50.50] 
	at 20x10 text "Mind Processing" white
	at 230x13 hgambciled: led green
	at 20x35 status: info bold "jprocessing v0.3. Start to connect" 220x25 font-color white 
;; Live recording buttons
	at 20x70 text "Live Play" snow  
	at 180x10 hgamval: text "0000" gray 
	at 130x10 hval: text "0000" gray       
	at 197x70 tcount: text "00000" snow
	at 155x70 tsignal: text "000" snow 
	at 100x95 button 70 50.50.50 edge [size: 1x1] "Stop" [
		status/font/color: snow
		status/text: "Ready"
		show status
		tcount/text: "000"
		show tcount
		close tp
		]
	at 185x95 button 70 50.50.50 edge [size: 1x1] "Quit" [quit]		

;; Prefs buttons
	
		at 20x127 text "DMX server IP" snow 
		at 130x127 lbl "Port" left snow 
		at 200x127 lbl "type" snow 
		at 20x150 tolightedip: field 100 to-string lightedip snow 
		at 130x150 tolightedport: field 55 to-string lightedport
		at 200x150 dmxcontroller: choice 55 50.50.50 edge [size: 1x1] "enttec" "arduino"
		at 20x182 text "first channel all DMX device" snow
		at 20x202 dmxdevices: field 230 "3" snow 
		at 20x237 text "if local DMX server, serial port :" snow 
		at 20x260 lightedserial: field 230 "" snow 
		
		at 20x300 text "VirtualLED level" snow 
		at 120x299 toledlvl: field 55 to-string ledlvl
		at 185x300 button 70 50.50.50 edge [size: 1x1] "SavePrefs" [
													saveprefs
													status/text: "Preferences saved"
													show status
													]
		;at 20x410 vpbox1: box 230x30 black 
		at 40x400 vled1: box 30x30 60.0.0 
	    at 80x400 vled2: box 30x30 60.0.0
	    at 120x400 vled3: box 30x30 60.0.0
	    at 160x400 vled4: box 30x30 60.0.0
	    at 200x400 vled5: box 30x30 60.0.0
		at 20x335 button 70 50.50.50 edge [size: 1x1] "Load" [namefile: to-file request-file
															  tcount/text: "0"
															  show tcount]
		at 185x335 jlivebtn: button 70 50.50.50 edge [size: 1x1] "jLIVE O/F" [
										either lan <> 1 [
													lan: 1
       												outport: open/lines/no-wait tcp://localhost:13856
       												status/text: "Send Data ON"
       												show status]
       												[
       												lan: 0
       												close outport
       												status/text: "Send Data Off"
       												show status
       												]
       									]
       									
		at 100x335 button 70 50.50.50 edge [size: 1x1] "Draw" [ print "Loading.."
																print namefile
																eeg-data: read/lines namefile
																records: ( length? eeg-data ) - 1
																print records
																tsignal/text: ""
																show tsignal
																status/text: "Rendering..."
																show status
																print "Rendering..."
																count: 1
																current: 2
																endgraph: records - 1
																print current
																print endgraph
																for element current endgraph 1 [ 
															 	data-line: pick eeg-data element 
																dataline: parse/all data-line ","
																tcount/text: form element
																show tcount
																if dataline/1 <> "count" [
																	ysig: to-decimal dataline/2
																	yatt: to-decimal dataline/3
																	ymed: to-decimal dataline/4
																	ydelta: to-decimal dataline/5
																	ytheta: to-decimal dataline/6
																	ylalp: to-decimal dataline/7
																	yhalp: to-decimal dataline/8
																	ylbeta: to-decimal dataline/9
																	yhbeta: to-decimal dataline/10
																	ylgam: to-decimal dataline/11
																	yhgam: to-decimal dataline/12
																	print "yhgam mutliplier h"
																	doengine
																	]
																wait 1
																]
																]
     at 185x370 jlivebtn: button 70 50.50.50 edge [size: 1x1] "OSC O/F" [
										either osc <> 1 [
													osc: 1
       												oscport: open/lines tcp://localhost:13857
       												status/text: "Send OSC ON"
       												show status]
       												[
       												osc: 0
       												close outport
       												status/text: "Send OSC Off"
       												show status
       												]
       									]
	at 20x370 multibtn: choice 70 50.50.50 edge [size: 1x1] "x1" "x2" "x5" "x10" "x20" "x50"
													[multi: form multibtn/text
													case [
														multi = "x1" [status/text: "Base multiplier"
																		 show status
																		 multiplier: basemultiplier]
														multi = "x2"  [status/text: "multiplier x2"
																		  show status
																		  multiplier: multiplier * 2]
														multi = "x5"  [status/text: "multiplier x5"
																		  show status
																		  multiplier: multiplier * 5]
														multi = "x10" [status/text: "multiplier x10"
																		  show status
																		  multiplier: multiplier * 10]
														multi = "x20" [status/text: "multiplier x20"
																		  show status
																		  multiplier: multiplier * 20]
														multi = "x50" [status/text: "multiplier x50"
																	      show status
																		  multiplier: multiplier * 50]						
														]
														]
	at 100x370 button 70 50.50.50 edge [size: 1x1] "GO O/F" [
										either forceset <> 1 [
													forceset: 1
       												status/text: "GO LED ON"
       												show status]
       												[
       												forceset: 0
       												status/text: "GO LED Off"
       												show status
       												]
															]
		
;;       						
;; RECORD from Headset data
;;
	at 20x95 button 70 50.50.50 edge [size: 1x1] "Start" [
	if os = "MacOSX" [
					if any [lightedip = "localhost" lightedip = "127.0.0.1" lightedip = host_name] [
									print "test local"
									checkdevdmx
									]
					print "test MAC"
					;checktgc
				  	]
		status/text: "connect.."
		show status
		tp: open/binary/no-wait tcp://localhost:13854
		show status
		forever [  
			wait tp 
			data: copy tp
			signal: copy/part skip data 3 1
			ysig: to-integer signal
			tsignal/text: form ysig
			show tsignal
			attention: copy/part skip data 5 1
			yatt: to-integer attention
			meditation: copy/part skip data 7 1
			ymed: to-integer meditation
			hgam: copy/part skip data 38 4
			yhgam: from-ieee hgam
			either ysig < 200  
			[doengine]
			[status/text: "WRONG SIGNALS"
			instruc/text: "       Mettre le casque"
			hide lvlbox1
			hide lvlbox2
			hide lvlbox3
			hide lvlbox4
			do ajoin ["read http://" lightedip ":" lightedport "/" leds1 "/000000"]
			]
		show instruc
		show status
		]
		
		]
]

Set_TimeOut: func [newto] [
	oldto: system/schemes/default/timeout
	system/schemes/default/timeout: newto
]

Restore_TimeOut: does [
	system/schemes/default/timeout: oldto 
]

; Read prefs
readprefs: does [

;jDMX prefs
					prefs-data: read/lines %jresources/jDMX.conf
					allplage: length? prefs-data
					data-line: pick prefs-data 1  
					data-line: pick prefs-data 2           
					prefline: parse/all data-line " "
	    			lightedip: prefline/1
	    			data-line: pick prefs-data 3          
					prefline: parse/all data-line " "
	    			ledlvl: prefline/1

;lighted server prefs					
					prefs-data: read/lines %jresources/lighted/lighted.conf
					allplage: length? prefs-data
					data-line: pick prefs-data 1  
					data-line: pick prefs-data 2
					prefline: parse/all data-line " = "
					lightedserial/text: prefline/4
					data-line: pick prefs-data 3
					prefline: parse/all data-line " = "
					dmxcontroller/text: prefline/4
					data-line: pick prefs-data 4
					prefline: parse/all data-line " = "
					dmxdevices/text: prefline/4
					dmxdev: parse/all dmxdevices/text ","
					nbdmx: length? dmxdev
					dmxaddr: "1"
					if nbdmx <> 1 [for i 2 nbdmx 1 [dmxaddr: ajoin [dmxaddr ","i ]]]
					print dmxaddr
					data-line: pick prefs-data 5
					prefline: parse/all data-line " = "
					lightedport: prefline/7
					
					tolightedip/text: lightedip
					tolightedport/text: lightedport
					toledlvl/text: ledlvl
				]
				
; save prefs
saveprefs: does [filename: probe to-file "jresources/jDMX.conf"
;jDMX prefs
				delete filename	
				lightedip: tolightedip/text
				lightedport: tolightedport/text
				write/lines filename "Preferences jDMX"
				write/append filename reduce [form lightedip]   
				write/append filename "^/"
				write/append filename reduce [form toledlvl/text]   
				write/append filename "^/"

;lighted prefs
				filename: probe to-file "jresources/lighted/lighted.conf"
				delete filename	
				write/lines filename "[lighted]"
				write/append filename reduce ["serialport = " lightedserial/text]
				write/append filename "^/"
				write/append filename reduce ["controller = " dmxcontroller/text]
				write/append filename "^/"
				write/append filename reduce ["dmxdevices = " dmxdevices/text]
				write/append filename "^/"
				write/append filename reduce ["tcpport    = " lightedport]
				readprefs
				]
				
;

Get_OS
readprefs
;check TGC server ?
checktgc: does [testtgc:open/binary/no-wait tcp://localhost:13854
				if error? try [insert testlighted "read"] [status/text: "TGC connexion error"
														  show status]
				]
;check DMX devices driver mounted ?
checkdevdmx: does [errstr: copy ""
				   outstr: copy ""
					call/output/error "ls /dev/tty.usbserial*" outstr errstr
					;if errstr <> "" [print "No local DMX interface"
					;				 quit]
					]
									 
;check DMX server ?
checkdmx: does [testlighted: do reduce ajoin ["open/direct/no-wait tcp://" lightedip ":" lightedport]
				print testlighted
				if error? try [insert testlighted "GET index.html"] [print "erreur connexion lighted"
															pyoutstr: copy ""
				 											pyerrstr: copy ""
															;call  "python jresources/lighted/lighted.py"
															call/output/error "python jresources/lighted/lighted.py" pyoutstr pyerrstr
															print pyerrstr
															print pyoutstr
															]
				]
;
; VP User Interface
;				
vpui: layout [
		backdrop black
		bigbox: box 800x600 black
		at 290x300 instruc: txt red font [name: font-serif size: 30] "MIND PROCESSING" 
	    at 300x290 lvlbox1: box 50x100 
	    at 370x260 lvlbox2: box 50x130 
	    at 440x220 lvlbox3: box 50x170 
	    at 510x170 lvlbox4: box 50x220 
		]

;;
;; Start UIs
;;

if os = "Windows" [outstr: copy ""
				  errstr: copy ""
				  ;call  "python jresources/lighted/lighted.py"
				  call/output/error "python jresources/lighted/lighted.py" outstr errstr
				  print [errstr]]
;instruc/font/size: 40
view/new vpui		
controllers/offset: vpui/offset + (vpui/size * 1x0) - 20x0		  
view/new controllers
do-events

