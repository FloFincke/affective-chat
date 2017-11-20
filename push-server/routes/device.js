const express = require('express');
const router = express.Router();

const database = require('../components/database');

router.post('/new', function(req, res, next) {
    if (req.body.username && req.body.token) {
        const date = new Date();
        const phone = new database.Phone({
            username: req.body.username,
            token: req.body.token,
            createdAt: date
        });

        phone.save(function(err, data) {
            if (err) {
                console.log(err);
                return res.status(500).send(err);
            } else {
                console.log(date + ' -- Registered phone of ' + phone.username + ' with token: ' + phone.token);

                res.status(200).send(data.id);
            }
        });

    } else {
        console.log('New device: parameters not provided');
        return res.sendStatus(422);
    }

});

module.exports = router;