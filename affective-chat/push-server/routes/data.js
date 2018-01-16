const express = require('express');
const router = express.Router();
const ObjectId = require('mongoose').Types.ObjectId;

const database = require('../components/database');
const store = require('../components/store');


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


module.exports = router;