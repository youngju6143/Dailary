const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const cors = require('cors');

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

let dates = [];

let diaries = [
    { date: '2024-05-28', emotion: '화나요', weather: '비' },
    { date: '2024-05-07', emotion: '슬퍼요', weather: '맑음' },
    { date: '2024-05-07', emotion: '행복해요', weather: '맑음' },
    { date: '2024-05-07', emotion: '행복해요', weather: '흐림' } // dummy data
];
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

app.get('/count_emotions', (req, res) => {
    const emotionCounts = {};
    diaries.forEach(diary => {
        const emotion = diary.emotion;
        console.log("Emotion: ", emotion);
        if (emotionCounts[emotion]) {
            emotionCounts[emotion]++;
        } else {
            emotionCounts[emotion] = 1;
        }
        });
    
        // JSON.stringify()를 사용하여 객체를 JSON 문자열로 변환하여 보냄
    res.send(JSON.stringify(emotionCounts));
    console.log(emotionCounts);
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
