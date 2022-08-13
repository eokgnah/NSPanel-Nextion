# Nextion Serial Protocol driver by joBr99 + nextion upload protocol 1.2 (the fast one yay) implementation using http range and tcpclient
# based on;
# Sonoff NSPanel Tasmota driver v0.47 | code by blakadder and s-hadinger
# based on;
# https://github.com/carlosperezc/nspanel
#
# no tft uploader 
#


import persist
var devicename = tasmota.cmd("DeviceName")["DeviceName"]
persist.tempunit = tasmota.get_option(8) == 1 ? "F" : "C"
if persist.has("dim") else persist.dim = "1"  end
persist.save() # save persist file until serial bug fixed


class Nextion : Driver
  var ser
  var flash_mode
  static header = bytes('55BB')


  def init()
    log("NSP: Initializing Driver")
    self.ser = serial(17, 16, 115200, serial.SERIAL_8N1)
    self.flash_mode = 0
    tasmota.add_driver(self)
  end #init


  def crc16(data, poly)
    if !poly  poly = 0xA001 end
    # CRC-16 MODBUS HASHING ALGORITHM
    var crc = 0xFFFF
    for i:0..size(data)-1
      crc = crc ^ data[i]
      for j:0..7
        if crc & 1
          crc = (crc >> 1) ^ poly
        else
          crc = crc >> 1
        end
      end
    end
    return crc
  end #crc16


  def split_55(b)
    var ret = []
    var s = size(b)
    var i = s-1   # start from last
    while i > 0
      if b[i] == 0x55 && b[i+1] == 0xBB
        ret.push(b[i..s-1]) # push last msg to list
        b = b[(0..i-1)]   # write the rest back to b
      end
      i -= 1
    end
    ret.push(b)
    return ret
  end #split_55


  # encode using custom protocol 55 BB [payload length] [payload] [crc] [crc]
  def encode(payload)
    var b = bytes()
    b += self.header
    b.add(size(payload), 1)   # add size as 1 byte
    b += bytes().fromstring(payload)
    var msg_crc = self.crc16(b)
    b.add(msg_crc, 2)       # crc 2 bytes, little endian
    return b
  end #encode


  # send a nextion payload
  def encodenx(payload)
    var b = bytes().fromstring(payload)
    b += bytes('FFFFFF')
    return b
  end # encodenx


  def sendnx(payload)
    var payload_bin = self.encodenx(payload)
    self.ser.write(payload_bin)
    print("NSP: Sent =", payload_bin)
    log("NSP: Nextion command sent = " + str(payload), 3)
  end #sendnx


  def send(payload)
    var payload_bin = self.encode(payload)
    if self.flash_mode==1
      log("NSP: skipped command becuase still flashing", 3)
    else
      self.ser.write(payload_bin)
      log("NSP: payload sent = " + str(payload_bin), 3)
    end
  end #send


  # commands to populate an empty screen, should be executed when screen initializes
  def screeninit()
    # self.send('{"queryInfo":"version"}')
    self.set_clock()
    tasmota.cmd("State")
    tasmota.cmd("TelePeriod")
  end # screeninit


  # sets time and date according to Tasmota local time
  def set_clock()
    import json
      var weekday = {
        0: "So",
        1: "Mo",
        2: "Di",
        3: "Mi",
        4: "Do",
        5: "Fr",
        6: "Sa"
      }
    var now = tasmota.rtc()
    var time_raw = now['local']
    var nsp_time = tasmota.time_dump(time_raw)
    var hourampm = nsp_time['hour']
    var ampm = "AM"
    if hourampm >= 12
      ampm = "PM"
      hourampm -= 12
    end
    var minute = "0"
    var month = "0"
    var day = "0"

    if nsp_time['min'] > 9
      minute = str(nsp_time['min'])
    else
      minute += str(nsp_time['min'])
    end
    if nsp_time['day'] > 9
      day = str(nsp_time['day'])
    else
      day += str(nsp_time['day'])
    end
    if nsp_time['month'] > 9
      month = str(nsp_time['month'])
    else
      month += str(nsp_time['month'])
    end
    var time_payload = '{"year":' + str(nsp_time['year']) + ',"mon":' + str(nsp_time['month']) + ',"day":' + str(nsp_time['day']) + ',"hour":' + str(nsp_time['hour']) + ',"min":' + str(nsp_time['min']) + ',"week":' + str(nsp_time['weekday']) + '}'
    var time = str(hourampm) + ":" + minute
    var timef = str(nsp_time['hour']) + ":" + minute
    var cmd = 'main.TIME.txt="' + timef + '"'
    self.sendnx(cmd)
    cmd = 'main.DATE.txt="' + weekday[nsp_time['weekday']] + ' - ' + day + "." + month + "." + str(nsp_time['year'])  + '"'
    self.sendnx(cmd)
    tasmota.resp_cmnd_done()
  end # set_clock


  def every_100ms()
    import string
    if self.ser.available() > 0
      var msg = self.ser.read()
      if size(msg) > 0
        print("NSP: Received Raw =", msg)
        #### check button presses
        if (msg==bytes('65000B01FFFFFF'))
          tasmota.publish_result("Touch", "RESULT")
        end
        if (msg==bytes('65020200FFFFFF'))
          tasmota.publish_result("AllesAus", "RESULT")
        end
        if (msg==bytes('65020300FFFFFF'))
          tasmota.publish_result("StartRobot", "RESULT")
        end
        ####
        if (self.flash_mode==1)
	        ## Flashing - deactivated
        else
          # Recive messages using custom protocol 55 BB [payload length] [payload] [crc] [crc]
          if msg[0..1] == self.header
            var lst = self.split_55(msg)
            for i:0..size(lst)-1
              msg = lst[i]
              var j = msg[2]+2
              msg = msg[3..j]
              if size(msg) > 2
                var jm = string.format("{\"CustomRecv\":\"%s\"}",msg.asstring())
                tasmota.publish_result(msg.asstring(), "RESULT")
              end
            end
          elif msg == bytes('000000FFFFFF88FFFFFF')
            log("NSP: Screen Initialized")
          else
            var lst = self.split_55(msg)
            for i:0..size(lst)-1
              msg = lst[i]
              var j = msg[2]+2
              msg = msg[0..j]
              if size(msg) > 2
                var jm = string.format("{\"CustomRecv\":\"%s\"}",msg.asstring())
                tasmota.publish_result(msg.asstring(), "RESULT")
              end
            end
          end
        end
      end
    end
  end # every_100ms

end
var nextion = Nextion()


def send_cmd(cmd, idx, payload, payload_json)
    nextion.sendnx(payload)
    tasmota.resp_cmnd_done()
end
tasmota.add_cmd('Nextion', send_cmd)


def send_cmd2(cmd, idx, payload, payload_json)
    nextion.send(payload)
    print payload
    tasmota.resp_cmnd_done()
end
tasmota.add_cmd('CustomSend', send_cmd2)

#### MQTT Test # start
#### MQTT Test # end

###########################################################
#
tasmota.cmd("Rule3 1") # needed until Berry bug fixed
tasmota.cmd("State")
#
nextion.sendnx('main.temp.txt="-"') # Temperatur 
nextion.sendnx('main.hum.txt="-"') # Luftfeuchte 
nextion.sendnx('main.druck.txt="-"') # Luftdruck 
#
nextion.sendnx('main.PO.txt="O"') 
nextion.sendnx('main.GA.txt="O"') 
nextion.sendnx('main.WT.txt="O"') 
nextion.sendnx('main.SZ.txt="O"') 
nextion.sendnx('main.WZ.txt="O"') 
#
tasmota.add_rule("Time#Minute", /-> nextion.set_clock()) # set rule to update clock every minute
tasmota.add_rule("system#boot", /-> nextion.screeninit())
tasmota.cmd("TelePeriod")
print ('initialization finished')
log("########## STARTED - EOK ##########")
