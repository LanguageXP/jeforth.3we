\ alarmOff alarmStart alarmReset
\ dictate('char r to reset/clear alarmReset');
\ doTimeTick 
\ doTimeout
\ [ ] click reset doesn't work well now


	s" alarm.f" source-code-header

	js> kvm.appname char jeforth.3nw = [if] .( Node-Webkit does not support HTML5 <audio> element, sorry!) cr \s [then]

    <o>
    <style>
        .alarm, .alarm input { 
            border-collapse: collapse;
            font-family: Arial;
            text-align: center;
            background-color: #D0D0FF; 
            font-size: 42px;
        }
        .alarm td { /* 只針對在 .alarm tree 下的 td */
            border: 10px solid #f0f0f0;
        }
        .alarm .nobg { /* no background color */
            background-color: #F0F0F0;
        }
        .alarm .bigchar { 
            font-size: 90px;
        }
        .alarm .control:hover {
            background-color: #FFD0D0;
			/* 以下稱為 no-select 的設定避免點擊幾下 control 變成 mark 文字。但本設定 HTA 無效 */
            -webkit-touch-callout: none; 
            -webkit-user-select: none;
            -khtml-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
        }
    </style>
    <table class=alarm>
		<tr>
			<td colspan=7>
			<input id=alarm_message type=text class=control size=36 value='小計時器 ─ 提醒事項' style="text-align:center;font-family:DFKai-SB;font-size:48px;text-shadow: 2px 2px 3px #505050;"/>
			</td>
		</tr>
		<tr>
			<td id=alarmreset class=control rowspan=3><div id=almReset><span id=reset_button style="color:black">RESET<span><br><span id=clear_button style="color:gray">CLEAR</span></div></td>
			<td id='alarmHour10' class=control>+</td>
			<td class=nobg></td>
			<td id='alarmMinute10' class=control>+</td>
			<td class=nobg></td>
			<td id='alarmSecond10' class=control>+</td>
			<td id=btnStart class=control rowspan=3><div id=almStart><span id=start_button style="color:black">START<span><br><span id=pause_button style="color:gray">PAUSE</span></div></td>
		</tr>
		<tr class=bigchar>
			<td><b><div id=almHour>00</div></b></td>
			<td class=nobg>:</td>
			<td><b><div id=almMinute>00</div></b></td>
			<td class=nobg>:</td>
			<td><b><div id=almSecond>00</div></b></td>
		</tr>
		<tr>
			<td id='alarmHour1' class=control>+</td>
			<td class=nobg></td>
			<td id='alarmMinute1' class=control>+</td>
			<td class=nobg></td>
			<td id='alarmSecond1' class=control>+</td>
		</tr>
		<tr>
			<td colspan=7>
			<span style="font-size:20px;">MP3 : <input 
				type=text 
				class=control
				id=mp3path 
				style="margin:0 0 8px;font-size:20px;" 
				size=70
				value="e.g. 'demo/filename.mp3' on server w/o the quote"
			/></span>
			<br><audio controls id=mp3player>
			  <source type="audio/mpeg" src="demo/228.mp3">
				Your browser does not support the audio element.
			</audio>
			</td>
		</tr>
    </table>
    </o> drop
	<o> <style> .alarm { border: 12px solid #f0f0f0; }</style></o> constant alarm-border // ( -- element ) use this to change color.
	
    0 value intervalId // ( -- id ) The id of setInterval() 
    true value alarmPause // ( -- flag ) True if the count down is paused, clock is not ticking.
	char 00 value setting.sec // ( -- 'dd' ) Keet the user setting of second for reset.
	char 00 value setting.min // ( -- 'dd' ) Keet the user setting of minute for reset.
	char 00 value setting.hur // ( -- 'dd' ) Keet the user setting of hour   for reset.
	false   value repeating // ( -- boolean ) The repeating flag
	
	\ <title></title> 不 support style 故無法改醒目顏色，只好多費點功夫用以下 blinking 程式也許更好。
	0 value blink.intervalId // ( -- id ) The id of setInterval() 
	: blink ( -- ) \ Blinking the browser tab title indicates who alarms.
		blink.intervalId if else js> vm.g.setInterval(function(){execute('blink')},500) to blink.intervalId then
		js> document.title!="!!時間到!!" if js: document.title="!!時間到!!"
		else js: document.title=alarm_message.value then ;
	: stopBlinking ( -- ) \ Stop the blinking browser tab title.
		blink.intervalId js: clearInterval(pop())
		0 to blink.intervalId ;
		
    : alarmOff ( -- ) \ Stop playing the alarm and rewind to beginning
		js: if(mp3player.readyState){mp3player.currentTime=0;mp3player.pause()}
		alarm-border <js> pop().innerHTML=".alarm { border: 12px solid #f0f0f0; }"</js>
		stopBlinking
		js: document.title='小計時器-jeforth.3we' 
		; 
	: saveSetting ( -- ) \ Save recent count down settings for reset to recall the setting.
		js> almSecond.innerHTML to setting.sec \ save the recent setting for reset
		js> almMinute.innerHTML to setting.min
		js> almHour.innerHTML   to setting.hur ;

	: h:m:s ( -- h m s ) \ Remaining time in h:m:s
		js> almHour.innerHTML int
		js> almMinute.innerHTML int
        js> almSecond.innerHTML int ;
		
	: remaining ( -- sec ) \ Remaining time in seconds
		h:m:s ( h m s )
		swap 60 * ( h s-1 m*60 )
		rot 3600 * ( s-1 m*60 h*3600 ) 
		+ + ;
		
    : alarmStart
		repeating if else alarmOff then \ stop the alarm if not repeating
        remaining alarmPause and if 
			\ start counting down 
            intervalId if else js> vm.g.setInterval(function(){execute('doTimeTick')},1000) to intervalId then
            false to alarmPause
            \ js: alarmStart.innerHTML="PAUSE";
			js> pause_button :: setAttribute('style','color:black')
			js> start_button :: setAttribute('style','color:gray')
        else 
			\ pause counting	
            true to alarmPause \ this pauses the doTimeTick 
            \ js: alarmStart.innerHTML="START";
			js> pause_button :: setAttribute('style','color:gray')
			js> start_button :: setAttribute('style','color:black')
        then
        ;
	char r value reset/clear // ( -- 'r'/'c' ) Toggle state of the reset/clear button
	
	code _clear ( -- ) \ Clear the alarm count down time
		almSecond.innerHTML = '00';
		almMinute.innerHTML = '00';
		almHour.innerHTML   = '00';
		dictate('char r to reset/clear');
		reset_button.setAttribute('style','color:black')
		clear_button.setAttribute('style','color:gray')
		end-code

	: _reset ( -- ) \ Reset the alarm count down time
		setting.sec js: almSecond.innerHTML=pop()
		setting.min js: almMinute.innerHTML=pop()
		setting.hur js: almHour.innerHTML=pop() 
		char c to reset/clear
		js: reset_button.setAttribute('style','color:gray')
		js: clear_button.setAttribute('style','color:black')
		;
	
    : alarmReset
        intervalId js: clearInterval(pop())
		alarmOff 0 to intervalId false to alarmPause alarmStart
		reset/clear char c == if _clear else _reset then ;
    code alarmHour10
        var h = parseInt(almHour.innerHTML) + 10;
        h = h > 59 ? 0 : h ;
        almHour.innerHTML   = ('0'+h.toString()).slice(-2);
		execute('alarmOff');execute('saveSetting') end-code
    code alarmMinute10
        var m = parseInt(almMinute.innerHTML) + 10;
        m = m > 59 ? 0 : m ;
        almMinute.innerHTML = ('0'+m.toString()).slice(-2);
		execute('alarmOff');execute('saveSetting') end-code
    code alarmSecond10
        var s = parseInt(almSecond.innerHTML) + 10;
        s = s > 59 ? 0 : s ;
        almSecond.innerHTML = ('0'+s.toString()).slice(-2);
		execute('alarmOff');execute('saveSetting') end-code
    code alarmHour1
        var h = parseInt(almHour.innerHTML) + 1;
        h = h > 59 ? 0 : h ;
        almHour.innerHTML   = ('0'+h.toString()).slice(-2);
		execute('alarmOff');execute('saveSetting') end-code
    code alarmMinute1
        var m = parseInt(almMinute.innerHTML) + 1;
        m = m > 59 ? 0 : m ;
        almMinute.innerHTML = ('0'+m.toString()).slice(-2);
		execute('alarmOff');execute('saveSetting') end-code
    code alarmSecond1
        var s = parseInt(almSecond.innerHTML) + 1;
        s = s > 59 ? 0 : s ;
        almSecond.innerHTML = ('0'+s.toString()).slice(-2);
		execute('alarmOff');execute('saveSetting') end-code

    code doTimeTick ( -- ) \ Count down the timer.
        execute('alarmPause'); var pause = pop();
        if(!pause) {
			execute('remaining');
			debugger;
            var t = pop() - 1;
            var s = t % 60; 
            var m = parseInt(t/60);
            var h = parseInt(m/60);
			m = m % 60;
            if(t<=0){execute("doTimeout");s=m=h=0}
            almSecond.innerHTML = ('   0'+s.toString()).slice(-2);
            almMinute.innerHTML = ('   0'+m.toString()).slice(-2);
            almHour.innerHTML   = ('   0'+h.toString()).slice(-2);
        }
        end-code
		
	: doTimeout ( -- ) \ The timer count down to 00:00:00 then do thhis.
		repeating if 
			char r to reset/clear alarmReset alarmStart
		else
			char c to reset/clear alarmReset
		then
		alarm-border <js> pop().innerHTML=".alarm { border: 12px solid pink; }"</js>
		blink
		<js> if (mp3player.readyState) {
			mp3player.currentTime=0;
			mp3player.play();
		} </js>
	;

	\ jeforth.3ce and 3ca, Chrome Extension and Chrome App, do not allow inline event handler.
	\ the workaround is as easy as the following section:
	<js>
		window.alarmreset.onmousedown=function(){kvm.execute("alarmReset")};
		window.alarmHour10.onmousedown=function(){kvm.execute("alarmHour10")};
		window.alarmMinute10.onmousedown=function(){kvm.execute("alarmMinute10")};
		window.alarmSecond10.onmousedown=function(){kvm.execute("alarmSecond10")};
		window.btnStart.onmousedown=function(){kvm.execute("alarmStart")};
		window.alarmHour1.onmousedown=function(){kvm.execute("alarmHour1")};
		window.alarmMinute1.onmousedown=function(){kvm.execute("alarmMinute1")};
		window.alarmSecond1.onmousedown=function(){kvm.execute("alarmSecond1")};
		window.mp3path.onchange=function(){mp3player.src=mp3path.value};
	</js>
	alarmOff \ initial state

	( ----- the end ----- )






