const express = require('express');
const router = express.Router();
const ObjectId = require('mongoose').Types.ObjectId;
const PythonShell = require('python-shell');
const zlib = require('zlib');

const pushService = require('../components/pushService');
const database = require('../components/database');
const store = require('../components/store');

const sampleData = require('../components/test-data.json');

PythonShell.defaultOptions = { scriptPath: './python-backend' };

const pyshell = new PythonShell('calc_receptivity.py', {
    mode: 'text',
    pythonPath: '/usr/local/bin/python3'
});

/*
router.post('/recep', function(req, res, next) {
            console.log(req.body.data)

    if (req.body.data && req.body.message && req.body.id) {
        console.log(req.body.data)
        database.Phone.findOne({ '_id': new ObjectId(req.body.id) }, function(err, phone) {
            if(phone) {
                receptivity(phone, req.body.data);
            } else {
                return res.sendStatus(422);
            }
        });

    } else {
        console.log('New data: parameters not provided');
        return res.sendStatus(422);
    }
});


router.post('/new', store.multerUpload.single('watch_data'), function(req, res, next) {
    if (req.query.id) {
        database.Phone.findOne({ '_id': new ObjectId(req.query.id) }, function(err, phone) {
            if (phone) {

                store.uploadFile(phone._id, req.file, function(err) {
                    if (err) {
                        return res.status(422).send('something went rong, check logs');
                    } else {
                        //Log in DB
                        const log = new database.Log({
                            id: phone._id,
                            content: database.MESSAGES.NEW_DATA,
                            createdAt: new Date()
                        });

                        log.save(function(err, data) {
                            if (err) {
                                console.log(err);
                            } else {
                                console.log(new Date + ' -- new data from phone with id: ' + phone._id);
                            }
                        });

                        return res.status(200).send('done');
                    }
                })


            } else {
                return res.status(422).send('Phone not found');
            }
        });

    } else {
        console.log('New data: parameters not provided');
        return res.sendStatus(422);
    }

});
*/

router.post('/new', store.multerUpload.single('watch_data'), function(req, res, next) {
    if (req.query.id) {
        database.Phone.findOne({ '_id': new ObjectId(req.query.id) }, function(err, phone) {
            if (phone) {
                receptivity(phone, {},req.body.message);

                store.uploadFile(phone._id, req.file, function(err) {
                    if (err) {
                        return res.status(422).send('something went rong, check logs');
                    } else {
                        //Log in DB
                        const log = new database.Log({
                            id: phone._id,
                            content: database.MESSAGES.NEW_DATA,
                            createdAt: new Date()
                        });

                        log.save(function(err, data) {
                            if (err) {
                                console.log(err);
                            } else {
                                console.log(new Date + ' -- new data from phone with id: ' + phone._id);
                            }
                        });

                        return res.status(200).send('done');
                    }
                })


            } else {
                return res.status(422).send('Phone not found');
            }
        });

    } else {
        console.log('New data: parameters not provided');
        return res.sendStatus(422);
    }

});

function receptivity(phone, raw_data, chat_message) {
    // sends a message to the Python script via stdin
    pyshell.send(JSON.stringify(sampleData));

    pyshell.on('message', function(message) {
        // received a message sent from the Python script (a simple "print" statement)
        if (message === 'True') {
            pushService.init();
            pushService.newPush(phone._id, phone.token, { 'message': chat_message }, false);
            console.log(phone._id + ' was receptive');

        }
    });

    // end the input stream and allow the process to exit
    pyshell.end(function(err) {
        if (err) {
            throw err;
        };

        console.log('finished');
    });
}
module.exports = router;