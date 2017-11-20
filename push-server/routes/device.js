const express = require('express');
const router = express.Router();

const database = require('../components/database');

router.post('/new', function(req, res, next) {
    if (req.body.username && req.body.token) {
        const date = new Date();

        database.Phone.findOne({ token: req.body.token }, function(err, phone) {
            if (!phone) {
                const newPhone = new database.Phone({
                    username: req.body.username,
                    token: req.body.token,
                    createdAt: date
                });

                newPhone.save(function(err, data) {
                    if (err) {
                        console.log(err);
                        return res.status(500).send(err);
                    } else {
                        console.log(date + ' -- Registered phone of ' + data.username + ' with token: ' + data.token);

                        res.status(200).send(data.id);
                    }
                });
            } else {
                res.status(200).send(phone.id)
            }
        });

    } else {
        console.log('New device: parameters not provided');
        return res.sendStatus(422);
    }

});

module.exports = router;