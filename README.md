# Nextion  
NSPanel Nextion - Tasmota - MQTT - ESP32 - custom HMI

Soon here will be my Solution for the EU NSPanel (and other Nextions) with tasmota and data through MQTT to a selfmade HMI  
hint.. ;-) - works with ALL Nextion https://nextion.tech/ displays!

* Custom Berry-Script (https://github.com/eokgnah/NSPanel-Nextion/blob/main/testnextion.be)
* Example MQTT (down below)
* Example HMI (https://github.com/eokgnah/NSPanel-Nextion/blob/main/testnextion.HMI)
* Nextion Editor (https://nextion.tech/nextion-editor/)

<table border=1>
<tr><th>ESP32</th><th></th><th>Nextion</th></tr>
<tr><td>5V</td><td>--------</th><th>+5v (red)</td></tr>
<tr><td>GND</td><td>--------</th><th>GND (black)</td></tr>
<tr><td>IO16 (RX2)</td><td>--------</th><th>TX (yellow)</td></tr>
<tr><td>IO17 (TX2)</td><td>--------</th><th>RX (blue)</td></tr>
</table>

Baseinstall for ESP32:  
https://templates.blakadder.com/sonoff_NSPanel.html  

CheatSheet:  
https://nextion.tech/instruction-set/

Examples:  
mosquitto_pub -h your.mqtt.server -u your.user -P your.pass -t "testnextion/cmnd/Nextion" -m "dim=1"  
mosquitto_pub -h your.mqtt.server -u your.user -P your.pass -t "testnextion/cmnd/Nextion" -m "dim=100"  

mosquitto_pub -h your.mqtt.server -u your.user -P your.pass -t "testnextion/cmnd/Nextion" -m "main.t0.txt=\"bla\""  
mosquitto_pub -h your.mqtt.server -u your.user -P your.pass -t "testnextion/cmnd/Nextion" -m "main.g0.txt=\"blubb\""  

mosquitto_pub -h your.mqtt.server -u your.user -P your.pass -t "testnextion/cmnd/Nextion" -m "picq 135,85,30,30,1"  
mosquitto_pub -h your.mqtt.server -u your.user -P your.pass -t "testnextion/cmnd/Nextion" -m "picq 135,85,30,30,0"  

![image](https://user-images.githubusercontent.com/21226978/185434431-9192ea8d-8c09-4be8-899a-f831520f326d.png)
