# Open a socket to the node server
socket = io.connect 'http://localhost:8888'

# On document ready
$ ->



    # Servo function
    servo =
        sweep: (state = stop) ->
            socket.emit 'sweep',
                'state': state
            return
        pan: (direction = right) ->
            socket.emit 'pan',
                'direction': direction
            return
        position: (position = 0) ->
            socket.emit 'position',
                'position': position
            return



    # Do stuff with the radar response object
    socket.on 'radar', (obj) ->
        console.log obj



    # Start radar sweep
    $('body').on 'click', '.start', ->
        servo.sweep 'start'
        $('.start, .left, .right, .reset').attr 'disabled', 'disabled'

    # Stop radar sweep
    $('body').on 'click', '.stop', ->
        servo.sweep 'stop'
        $('.start, .left, .right, .reset').removeAttr 'disabled'

    # Pan radar left
    $('body').on 'click', '.left', ->
        servo.pan 'left'

    # Pan radar right
    $('body').on 'click', '.right', ->
        servo.pan 'right'

    # Reset radar position
    $('body').on 'click', '.reset', ->
        servo.position 0

    $('.proximity').change () ->
        if $(this).is ':checked'
            socket.emit 'ir', true
            $('.start, .stop, .left, .right, .reset').attr 'disabled', 'disabled'
        else
            socket.emit 'ir', false
            $('.start, .stop, .left, .right, .reset').removeAttr 'disabled'

    socket.on 'irReady', () ->
        $('.proximity').removeAttr 'disabled'