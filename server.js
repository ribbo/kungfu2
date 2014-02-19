var app = require('http').createServer(),
    io  = require('socket.io').listen(app),
    five = require('johnny-five'),
    port = 8888,
    board, red, yellow, green;

// Johnny-Five board instance
board = new five.Board();

// When the board is ready
board.on('ready', function() {

    // Red LED setup
    red = new five.Led({
        pin: 12
    });
    // Yellow LED setup
    yellow = new five.Led({
        pin: 4
    });
    // Green LED setup
    green = new five.Led({
        pin: 2
    });

    // Create a new potentiometer hardware instance.
    potentiometer = new five.Sensor({
        pin: 'A1',
        freq: 250
    });

    // Inject the potentiometer hardware into
    // the Repl instance's context;
    // allows direct command line access
    board.repl.inject({
        pot: potentiometer
    });

    // On socket connection
    io.sockets.on('connection', function (socket) {

        // On socket key 'pot'
        socket.on('pot', function (bool) {
            // Get the current reading from the potentiometer
            potentiometer.on('data', function () {
                if (bool) {
                    socket.emit('potentiometer', this.value);
                } else {
                    socket.emit('potentiometer', 0);
                }
            });
        });

        // On socket key 'toggle'
        socket.on('toggle', function (obj) {
            // Toggle LED's on/off
            switch (obj.color) {
                case 'red':
                    if (obj.state) {
                        red.off();
                    } else {
                        red.on();
                    }
                break;
                case 'yellow':
                    if (obj.state) {
                        yellow.off();
                    } else {
                        yellow.on();
                    }
                break;
                case 'green':
                    if (obj.state) {
                        green.off();
                    } else {
                        green.on();
                    }
                break
                default:
                    red.off();
                    yellow.off();
                    green.off();
            }
        });

    });

});

app.listen(port);
console.log('listening on port ', port);