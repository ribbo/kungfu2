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
        pin: 4,
        range: [0, 180],    // Default: 0-180
        type: "standard",   // Default: "standard". Use "continuous" for continuous rotation servos
        startAt: 0,         // if you would like the servo to immediately move to a degree
        center: false       // overrides startAt if true and moves the servo to the center of the range
    });

    // Ping
    ping = new five.Ping(2);

    // IR motion
    motion = new five.IR.Motion(7);

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
        // Set IR flag to ready
        irReady = true;
    });

    // On socket connection
    io.sockets.on('connection', function (socket) {
        // IR detection calibrated
        if (irReady) {
            // Emit IR ready
            socket.emit('irReady');
        } else {
            console.log('IR motion was not calibrated');
        }

        // On socket key 'sweep'
        socket.on('sweep', function (obj) {
            // Servo sweep state
            switch (obj.state) {
                case 'start':
                    // Start sweeping
                    servo.sweep();
                    // Set servo flag to moving
                    isMoving = true;
                break;
                case 'stop':
                    // Stop servo
                    servo.stop();
                    // Set servo flag to not moving
                    isMoving = false;
                break;
            }
        });

        // On socket key 'pan'
        socket.on('pan', function (obj) {
            // Position request is left and servo position is above servo minumum range
            if (obj.direction === 'left' && servo.position >= (servo.range[0] + deg)) {
                // Pan left
                servo.to(servo.position - deg);
            // Position request is right and servo position is below servo maximum range
            } else if (obj.direction === 'right' && servo.position <= (servo.range[1] - deg)) {
                // Pan right
                servo.to(servo.position + deg);
            }
        });

        // On socket key 'position'
        socket.on('position', function (obj) {
            // Position is a number
            if (typeof obj.position === 'number') {
                // Set servo position
                servo.to(obj.position);
            }
        });

        // On socket key 'ir'
        socket.on('ir', function (bool) {
            // Set IR detection mode
            ir = bool;
            // IR detection is off
            if (!ir) {
                // Stop servo
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
            // Emit motion detected
            socket.emit('motion', true);
            // Clear motion interval
            clearInterval(motionTimer);
            // IR detection is on and servo is not moving
            if (ir && !isMoving) {
                // Start sweeping
                servo.sweep();
                // Set servo flag to moving
                isMoving = true;
            }
        });

        // Movement ended
        motion.on('motionend', function (err, ts) {
            // Emit motion stopped
            socket.emit('motion', false);
            // IR detection is on and servo is moving
            if (ir && isMoving) {
                // Tigger motion interval
                motionInterval();
            }
        });

    });

});

app.listen(port);
console.log('listening on port ', port);