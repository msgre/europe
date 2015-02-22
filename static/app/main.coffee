# Pomocne funkce.
#

# hlavni komunikacni kanal
window.main_channel = Backbone.Wreqr.radio.channel('main')

# odchytavani klaves (http://www.quirksmode.org/js/keys.html)
document['onkeypress'] = (e) ->
    evt = e || window.event
    if evt.keyCode == 113       # Q
        window.main_channel.commands.execute('main', 'key-up')
    else if evt.keyCode == 97   # A
        window.main_channel.commands.execute('main', 'key-down')
    else if evt.keyCode == 32   # mezera
        window.main_channel.commands.execute('main', 'key-fire')
    return

# http://stackoverflow.com/questions/6312993/javascript-seconds-to-time-string-with-format-hhmmss
elapsed = (tenth_seconds) ->
    tenth = Math.round(tenth_seconds % 10)
    sec_num = parseInt(Math.round(tenth_seconds / 10), 10)
    hours   = Math.floor(sec_num / 3600)
    minutes = Math.floor((sec_num - (hours * 3600)) / 60)
    seconds = sec_num - (hours * 3600) - (minutes * 60)

    if hours < 10
        hours = "0#{ hours }"
    if minutes < 10
        minutes = "0#{ minutes }"
    if seconds < 10
        seconds = "0#{ seconds }"

    "#{ minutes }:#{ seconds }.#{ tenth }"
