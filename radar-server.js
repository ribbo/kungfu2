var app = require('http').createServer(),
    io  = require('socket.io').listen(app),
    five = require('johnny-five'),
    port = 8888,
    deg = 10,
    ir = false,
    isMoving = false,
    irReady = false,
    board, servo, ping, motion, motionTimer;

    function stopServo () {
            console.log('Stop servo');
            servo.stop();
            servo.to(0);
            isMoving = false;
    }

    function motionInterval () {
        motionTimer = setInterval(function () {
            stopServo();
        }, 5000);
     }

// Johnny-Five board instance
board = new five.Board();

// When the board is ready
board.on('ready', function() {

    // Servo
    servo = new five.Servo({
        pin: 8,
        range: [0, 180],    // Default: 0-180
        type: "standard",   // Default: "standard". Use "continuous" for continuous rotation servos
        startAt: 0,         // if you would like the servo to immediately move to a degree
        center: false       // overrides startAt if true and moves the servo to the center of the range
    });

    // Ping
    ping = new five.Ping(7);

    // IR motion
    motion = new five.IR.Motion(4);

    // Inject the `servo and motion` hardware into
    // the Repl instance's context;
    // allows direct command line access
    board.repl.inject({
        servo: servo,
        motion: motion
    });

    // IR calibration
    motion.on('calibrated', function (err, ts) {

        console.log('IR Motion Calibrated');

        irReady = true;

    });

    // On socket connection
    io.sockets.on('connection', function (socket) {

        if (irReady) {
            socket.emit('irReady');
        } else {
            console.log('IR motion was not calibrated');
        }

        // On socket key 'sweep'
        socket.on('sweep', function (obj) {

            switch (obj.state) {
                case 'start':
                    // Start sweeping
                    servo.sweep();
                    isMoving = true;
                break;
                case 'stop':
                    // Stop servo
                    servo.stop();
                    isMoving = false;
                break;
            }

        });

        // On socket key 'pan'
        socket.on('pan', function (obj) {

            if (obj.direction === 'left' && servo.position >= (servo.range[0] + deg)) {
                // Pan left
                servo.to(servo.position - deg);

            } else if (obj.direction === 'right' && servo.position <= (servo.range[1] - deg)) {
                // Pan right
                servo.to(servo.position + deg);
            }

        });

        // On socket key 'position'
        socket.on('position', function (obj) {

            if (typeof obj.position === 'number') {
                // Go to position
                servo.to(obj.position);
            }

        });

        // On socket key 'ir'
        socket.on('ir', function (bool) {
            ir = bool;
            if (!ir) {
                stopServo();
            }
        });

        // Ping))) data
        ping.on('data', function (err, value) {
            // Emit radar data
            socket.emit('radar', {
                degrees: servo.position,
                distance: this.cm
            });

        });




        // Movement started
        motion.on('motionstart', function (err, ts) {

            console.log('Motion Detected');

            clearInterval(motionTimer);

            if (ir && !isMoving) {

                console.log('Scanning');

                servo.sweep();
                isMoving = true;
            }
        });

        // Movement ended
        motion.on('motionend', function (err, ts) {
            if (ir && isMoving) {
                motionInterval();

                console.log('Motion stopped');

            }
        });

    });

});

app.listen(port);
console.log('listening on port ', port);