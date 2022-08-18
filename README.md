# Nextion  
NSPanel Nextion - Tasmota - MQTT - custom HMI

Soon here will be my Solution for the EU NSPanel with tasmota and data through MQTT to a selfmade HMI

* Custom Berry-Script
* Example MQTT
* Example HMI

ESP32 ........ Nextion  
5V ----------- +5v  (red)  
GND ---------- GND  (black)  
IO16 --------- TX   (yellow)  
IO17 --------- RX   (blue)  

CheatSheet:  
https://nextion.tech/instruction-set/

Examples:  
mosquitto_pub -h mqtt.server -u admin -P pass -t "testnextion/cmnd/Nextion" -m "dim=1"  
mosquitto_pub -h mqtt.server -u admin -P pass -t "testnextion/cmnd/Nextion" -m "dim=100"  

mosquitto_pub -h mqtt.server -u admin -P pass -t "testnextion/cmnd/Nextion" -m "main.t0.txt=\"bla\""  
mosquitto_pub -h mqtt.server -u admin -P pass -t "testnextion/cmnd/Nextion" -m "main.g0.txt=\"blubb\""  

mosquitto_pub -h mqtt.server -u admin -P pass -t "testnextion/cmnd/Nextion" -m "picq 135,85,30,30,1"  
mosquitto_pub -h mqtt.server -u admin -P pass -t "testnextion/cmnd/Nextion" -m "picq 135,85,30,30,0"  

![image](https://user-images.githubusercontent.com/21226978/185434431-9192ea8d-8c09-4be8-899a-f831520f326d.png)
