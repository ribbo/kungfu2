# Open a socket to the node server
socket = io.connect('http://localhost:8888')

# On document ready
$ ->

    redState = false
    yellowState = false
    greenState = false

    # LED toggle function
    led =
        red: () ->
            # emit LED color and state to node server
            socket.emit 'toggle',
                'color': 'red'
                'state': redState
            if redState then redState = false else redState = true
            return
        yellow: () ->
            # emit LED color and state to node server
            socket.emit 'toggle',
                'color': 'yellow'
                'state': yellowState
            if yellowState then yellowState = false else yellowState = true
            return
        green: () ->
            # emit LED color and state to node server
            socket.emit 'toggle',
                'color': 'green'
                'state': greenState
            if greenState then greenState = false else greenState = true
            return

    # Swicth LED's off after 1 second of page load/refresh
    switchOff = setTimeout () ->
        led.red()
        led.yellow()
        led.green()
    , 1000

    $('body').on 'change', '#pot', () ->

        if this.checked
            socket.emit('pot', true)
        else
            socket.emit('pot', false)

    socket.on 'potentiometer', (data) ->
        if data > 0 and data < 341
            led.green()
        else if data > 341 and data < 511
            led.yellow()
        else if data > 511
            led.red()


    # Toggle red LED on/off
    $('body').on 'click', '#red', ->
        # LED toggle function
        led.red()

    # Toggle yellow LED on/off
    $('body').on 'click', '#yellow', ->
        # LED toggle function
        led.yellow()

    # Toggle green LED on/off
    $('body').on 'click', '#green', ->
        # LED toggle function
        led.green()

