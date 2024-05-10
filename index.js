const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');
const { HttpStatusCode } = require('axios');
require("dotenv").config();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

const users = [];
let diaries = [
    { diaryId: 1, userId: 1, date: '2024-05-28', emotion: '화나요', weather: '비', content: '오늘은 정말 기쁜 하루였다. 왜냐하면 기뻤기 때문이다 ㅎㅎ 야호야호 테스트 중입니당~!\n 안녕하세요~!'},
    { diaryId: 2, userId: 3, date: '2024-05-07', emotion: '슬퍼요', weather: '맑음', content: '오늘은 정말 기쁜 하루'},
    { diaryId: 3, userId: 1, date: '2024-05-07', emotion: '행복해요', weather: '맑음', content: '오늘은 정말 안 좋은 하루' },
    { diaryId: 4, userId: 2, date: '2024-05-07', emotion: '행복해요', weather: '흐림', content: '오늘은 정말 좋은 하루' } // dummy data
];

let calendars = [
    {calendarId: 1, userId: 1, date: '2024-05-06', startTime: '00:00', endTime: '16:00', text: '테스트1'},
    {calendarId: 2, userId: 2, date: '2024-05-09', startTime: '00:00', endTime: '16:00', text: '테스트2'},
    {calendarId: 3, userId: 2, date: '2024-05-09', startTime: '05:00', endTime: '16:40', text: '테스트2'},
    {calendarId: 4, userId: 3, date: '2024-05-09', startTime: '01:00', endTime: '23:59', text: '테스트2'},
    {calendarId: 5, userId: 4, date: '2024-05-09', startTime: '07:30', endTime: '21:00', text: '테스트2'},
    {calendarId: 6, userId: 2, date: '2024-05-07', startTime: '00:30', endTime: '18:00', text: '테스트3'},
    {calendarId: 7, userId: 1, date: '2024-05-07', startTime: '00:00', endTime: '16:00', text: '테스트3'},
]

app.get('/', (req, res) => {
    res.send('Hello, server!');
});

// 회원가입 엔드포인트
app.post('/signup', (req, res) => {
    const userId = uuidv4();
  const { userName, password } = req.body;
  const existingUser = users.find(user => user.userName === userName);
  if (existingUser) {
    res.status(400).json({ 
        success: false,
        code: 400,
        error: '이미 존재하는 사용자 이름입니다.' 
    });
  } else {
    // 새로운 사용자 정보를 배열에 추가
    const newUser = { 
        userId: userId, 
        userName: userName, 
        password: password 
    };
    users.push(newUser);
    res.status(201).json({
        success: true,
        code: 201,
        message: '회원가입이 성공적으로 완료되었습니다.' });
  }
});

// 로그인 엔드포인트
app.post('/login', (req, res) => {
    console.log(users);
    const { userName, password } = req.body;
    const user = users.find(user => user.userName === userName && user.password === password);
    if (user) {
        res.status(200).json({
        success: true,
        code: 200,
        message: '로그인에 성공하였습니다.',
        userId: user.userId,
        // 로그인한 사용자의 userId도 반환
        });
    } else {
        res.status(401).json({
        success: false,
        code: 401,
        error: '존재하지 않는 유저이거나 비밀번호가 일치하지 않습니다.'
        });
    }
});

// 일기 조회
app.get('/diary/:userId', (req, res) => {
    const userId = req.params.userId;
    const userDiaries = diaries.filter(diary => diary.userId === userId);
    if (userId.length !== 0) {
        if (userDiaries.size !== 0) {
            res.json({ 
                success: 'true',
                code: 200,
                message: '일기를 성공적으로 조회하였습니다.',
                data: userDiaries
            });
        } else {
            res.json({ 
                success: 'true',
                code: 200,
                message: '아직 일기를 쓰지 않았습니다.',
                data: []
            });
        }
        console.log('일기 조회 get API 연결 성공', userDiaries);
    } else {
        res.status(404).json({ 
            success: 'false',
            code: 404,
            message: 'userId가 전달되지 않았거나, 존재하지 않는 유저입니다.',
            data: []
        });
    }
});

app.get('/diary', (req, res) => {
    res.status(200).json({ 
        success: 'true',
        code: 200,
        message: '일기를 성공적으로 조회하였습니다.',
        data: diaries
    });
    console.log('일기 조회 get API 연결 성공', diaries);
});

// 사이드바 조회
app.get('/sidebar/:userId', (req, res) => {
    const userId = req.params.userId;
    if (userId.length !== 0) {
        const userDiaries = diaries.filter(diary => diary.userId === userId);
        const emotionCounts = {};
        userDiaries.forEach(diary => {
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
    } else {
        res.status(404).json({ 
            success: 'false',
            code: 404,
            message: 'userId가 전달되지 않았거나, 존재하지 않는 유저입니다.',
        });

    }
});

// 일기 작성
app.post('/diary_write', (req, res) => {
    const diaryId = uuidv4();
    const userId = req.body.userId;
    const date = req.body.date;
    const emotion = req.body.emotion;
    const weather = req.body.weather;
    const content = req.body.content;
    
    const parsedDate = date.slice(0, 10);

    if (userId.length !== 0) {
        const newData = {
            diaryId: diaryId,
            userId: userId,
            date: parsedDate,
            emotion: emotion,
            weather: weather,
            content: content
        };
        diaries.push(newData);
        res.status(200).json({ 
            success: 'true',
            code: 200,
            message: '일기를 성공적으로 작성하였습니다.',
            diaryId: diaryId
        });
        console.log('일기 조회 get API 연결 성공', diaries);
    } else {
        res.status(404).json({ 
            success: 'false',
            code: 404,
            message: '존재하지 않는 유저입니다.',
        });
    }
});

// 일기 수정
app.put('/diary/:diaryId', (req, res) => {
    const diaryId = req.params.diaryId; // 수정할 일기의 ID
    const { userId, date, emotion, weather, content } = req.body; // 수정할 내용
    const parsedDate = date.slice(0, 10);

    // 일기를 찾아서 수정
    const index= diaries.findIndex(diary => diary.diaryId === diaryId);
    if (index !== -1) {
        // 수정된 내용으로 일기 업데이트
        diaries[index] = {
            diaryId: diaryId,
            userId: userId,
            date: parsedDate,
            emotion: emotion,
            weather: weather,
            content: content
        };
        console.log('일기 수정 put API 연결 성공', req.body);
        res.send({ 
            success: true,
            code: 200,
            message: '일기가 수정되었습니다.', 
            data: diaries[index] 
        });
    } else {
        res.status(404).json({ 
            success: true,
            code: 404,
            message: '일기를 찾을 수 없습니다.',
        });
    }
});

// 일기 삭제
app.delete('/diary/:diaryId', (req, res) => {
    const diaryId = req.params.diaryId; // 삭제할 일기의 ID

    const index = diaries.findIndex(diary => diary.diaryId === diaryId);
    if (index !== -1) {
        diaries.splice(index, 1); // 배열에서 해당 일기를 삭제
        console.log('일기 삭제 delete API 연결 성공', diaries);
        res.status(200).json({ 
            success: true,
            code: 200,
            message: '일기가 삭제되었습니다.' 
        });
    } else {
        res.status(404).json({ 
            success: false,
            code: 404,
            message: '해당 ID를 가진 일기를 찾을 수 없습니다.' 
        });
    }
});


//캘린더 일정 조회
app.get('/calendar/:date/:userId', (req, res) => {
    const requestedDate = req.params.date;
    const userId = req.params.userId;
    const filteredCalendars = calendars.filter(calendar => calendar.date === requestedDate && calendar.userId === userId);
    if (userId.length !== 0) {
        if (filteredCalendars.length > 0) {
            res.status(200).json({ 
                success: true,
                code: 200,
                message: '일정을 성공적으로 조회하였습니다.',
                data: filteredCalendars
            });
            console.log('일정 조회 get API 연결 성공', req.body);
        } else {
            res.status(200).json({ 
                success: true,
                code: 200,
                message: '일정이 없습니다.',
                data: []
            });
        }
    } else {
        res.status(404).json({ 
            success: false,
            code: 404,
            message: '존재하지 않는 유저입니다.',
        });
    }


});

// 캘린더 일정 추가
app.post('/calendar', (req, res) => {
    const calendarId = uuidv4();
    const {userId, date, startTime, endTime, text} = req.body;
    if (userId.length !== 0) {
        const newData = {
            calendarId: calendarId,
            userId: userId,
            date: date, 
            startTime: startTime, 
            endTime: endTime, 
            text: text
        }
        console.log(calendarId);
        calendars.push(newData);
        res.status(200).json({ 
            success: true,
            code: 200,
            message: '일정을 성공적으로 추가하였습니다.',
            calendarId: calendarId,
        });
        console.log('일정 작성 post API 연결 성공', req.body);
    } else {
        res.status(404).json({ 
            success: false,
            code: 404,
            message: '존재하지 않는 유저입니다.',
        });
    }

})

// 일정 수정
app.put('/calendar/:calendarId', (req, res) => {
    const calendarId = req.params.calendarId;
    const {userId, date, startTime, endTime, text} = req.body;
    
    const index = calendars.findIndex(calendar => calendar.calendarId === calendarId);
    if (index !== -1) {
        calendars[index] = {
            calendarId: calendarId,
            userId: userId,
            date: date,
            startTime: startTime,
            endTime: endTime, 
            text: text
        }
        console.log('일정 수정 put API 연결 성공', req.body);
        res.status(200).json({ 
            success: true,
            code: 200,
            message: '일정이 수정되었습니다',
            data: calendars[index]
        });
    } else {
        res.status(404).json({
            success: false,
            code: 404,
            message: '일정을 찾을 수 없습니다.' 
        });
    }
})

//일정 삭제
app.delete('/calendar/:calendarId', (req, res) => {
    const calendarId = req.params.calendarId;

    const index = calendars.findIndex(calendar => calendar.calendarId === calendarId);
    if (index !== -1) {
        res.json({ 
            success: 'true',
            code: 200,
            message: '일정이 성공적으로 삭제되었습니다',
        });
        calendars.splice(index, 1); // 배열에서 해당 일기를 삭제
        console.log('일정 삭제 delete API 연결 성공', diaries);
    } else {
        res.status(404).json({ 
            success: 'false',
            code: 404,
            message: '해당 ID를 가진 일정을 찾을 수 없습니다.' 
        });
    }
});

app.listen(8080, function () {
 console.log('listening on 8080')
}); 
