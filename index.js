const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const cors = require('cors');

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

let dates = [];

let diaries = [];
/*
    date: '2024-05-05',
    weather : '',
    emotion: '',
    content: ''.
*/

app.get('/', (req, res) => {
    print('hello server!!')
});

app.get('/diary', (req, res) => {
    res.send(diaries);
    console.log('success to get')
});

app.post('/write', (req, res) => {
    const date = req.body.date;
    const emotion = req.body.emotion;
    const weather = req.body.weather;
    const parsedDate = date.slice(0, 10);

    const newData = {
        date: parsedDate,
        emotion: emotion,
        weather: weather
    };
    diaries.push(newData);
    console.log(diaries);
    res.json(diaries);
});

app.listen(8080, function () {
 console.log('listening on 8080')
}); 
