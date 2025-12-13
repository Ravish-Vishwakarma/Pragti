import json
import os
import random
from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
import sqlite3
import calendar
import requests
import logging
import uvicorn
import fetch_apps
import send_noti
from pathlib import Path
from paths import BASE_DIR
import sys
from datetime import datetime
app = FastAPI()

if getattr(sys, 'frozen', False):
    BASE_DIR = Path(sys.executable).parent
else:
    BASE_DIR = Path(__file__).resolve().parent

DB_DIR = BASE_DIR.parent / "database"

PRAGTI_DB = DB_DIR / "pragti.db"
HABIT_DB  = DB_DIR / "habit_tracker.db"


def get_pragti_db():
    return sqlite3.connect(PRAGTI_DB, check_same_thread=False)

def get_habit_db():
    return sqlite3.connect(HABIT_DB, check_same_thread=False)


# --------------------------- SCHEDULING --------------------------- #



@app.get("/scheduling/get")
def get_schedules():
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM calendar")
    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "id" : r[0],
            "title" : r[1],
            "description" : r[2],
            "start_date" : r[3],
            "start_time" : r[4],
            "end_date" : r[5],
            "end_time" : r[6],
            "repetition" : r[7],
            "allday" : r[8],
            "status" : r[9],
            "color" : r[10],
        } for r in rows
    ]

class SchedulingDataModel(BaseModel):
    title: str
    description: str
    start_date: str
    start_time: str
    end_date: str
    end_time: str
    repetition: str
    allday: int
    status: int
    color: str

@app.post("/scheduling/create")
def create_schedule(data:SchedulingDataModel):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO calendar (title,description,start_date,start_time,end_date,end_time,repetition,allday,status,color) VALUES (?,?,?,?,?,?,?,?,?,?)",(data.title,data.description,data.start_date,data.start_time,data.end_date,data.end_time,data.repetition,data.allday,data.status,data.color))
    conn.commit()
    conn.close()
    return {"message":"Created Successfully"}


class UpdateSchedulingDataModel(BaseModel):
    id: str
    title: str
    description: str
    start_date: str
    start_time: str
    end_date: str
    end_time: str
    repetition: str
    allday: int
    status: int
    color: str
@app.put("/scheduling/update")
def update_schedule(data:UpdateSchedulingDataModel):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE calendar
        SET title = ?,description = ?,start_date = ?,start_time = ?,end_date = ?,end_time = ?,repetition = ?,allday = ?,status = ?,color = ?
        WHERE id = ?;
    """, (data.title,data.description,data.start_date,data.start_time,data.end_date,data.end_time,data.repetition,data.allday,data.status,data.color,data.id))
    conn.commit()
    conn.close()
    return {"message": f"Record with id {data.id} updated successfully."}


@app.delete("/scheduling/delete")
def delete_schedule(id):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM calendar WHERE id=?",(id,))
    conn.commit()
    conn.close()
    return {"message":"Deleted Successfully"}



# --------------------------- REVISION --------------------------- #
# Topic
@app.get("/revision/topic")
def read_revision():
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM revision")
    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "id": r[0],
            "content": r[1],
            "end_date": r[2],
            "created_date": r[3],
            "frequency": r[4],
            "question_count": r[5]
        } for r in rows
    ]

@app.delete("/revision/topic/delete")
def delete_topic(iid):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM revision WHERE id = ?", (iid,))
    conn.commit()
    conn.close()
    delete_question_by_topic_id(iid)
    return {"message": f"Topic with id {iid} deleted with all its related questions"}


def create_questions_for_topic(content,no_question):
    prompt = API_Model(
        prompt=f"""You are a question and answer generator for any given topic or content.
    You MUST generate exactly {no_question} questions with answer based on the provided content.
    Answers should be a single line.
    You MUST only provide the questions and answers in the specified JSON format and include absolutely no other text,
    explanation, or conversational filler before, within, or after the JSON block.

    JSON Format:
    {{'questions':[['question 1 here','answer 1'],['question 2 here','answer 2'][etc..]]}}

    Content: {content}"""
    )
    text_output = send_ai_request(0,prompt)['candidates'][0]['content']['parts'][0]['text']
    return text_output

class TopicItem(BaseModel):
    content: str
    end_date: str
    created_date: str
    frequency: str
    question_count: str
@app.post("/revision/topic/create")
def create_topic(topic:TopicItem):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("""
    INSERT INTO revision (content, end_date, created_date, frequency, question_count)
    VALUES (?, ?, ?, ?, ?)
""", (topic.content,topic.end_date,topic.created_date,topic.frequency,topic.question_count))
    topic_id = cursor.lastrowid
    conn.commit()
    conn.close()
    questions_list = create_questions_for_topic(f"{topic.content}",f"{topic.question_count}")
    question_cleaned = questions_list.strip("```json").strip("```").strip()
    questions_json = json.loads(question_cleaned)
    for i in range(int(topic.question_count)):
        model = QuestionItem(question=str(questions_json["questions"][i][0]),answer=str(questions_json["questions"][i][1]),end_date=str(topic.end_date),repetition=str(topic.frequency),status='active',topic_id=str(topic_id))
        create_question(model)

    return {"message":f"One row added", "data":{
        "id": topic_id,
        "content" : topic.content,
        "end_date" : topic.end_date,
        "created_date" : topic.created_date,
        "frequency" : topic.frequency,
        "question_count" : topic.question_count,
        "questions": questions_json
    }}



# Questions
@app.get("/revision/questions")
def read_questions():
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id, question, answer, end_date, repetition, status, topic_id FROM questions")
    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "id": r[0],
            "question": r[1],
            "answer": r[2],
            "end_date": r[3],
            "repetition": r[4],
            "status": r[5],
            "topic_id": r[6],
        } for r in rows
    ]

@app.get("/revision/recent_questions")
def read_recent_questions():
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM questions WHERE status='active' ORDER BY end_date ASC ")
    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "id": r[0],
            "question": r[1],
            "answer": r[2],
            "end_date": r[3],
            "repetition": r[4],
            "status": r[5],
            "topic_id": r[6],
        } for r in rows
    ]

@app.get("/revision/questions/topic_id")
def read_questions_by_id(topic_id):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute(f"SELECT * FROM questions WHERE topic_id={topic_id}")
    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "id": r[0],
            "question": r[1],
            "answer": r[2],
            "end_date": r[3],
            "repetition": r[4],
            "status": r[5],
            "topic_id": r[6],
        } for r in rows
    ]

@app.delete("/revision/questions/delete")
def delete_question(iid):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM questions WHERE id = ?", (iid,))
    conn.commit() 
    conn.close()
    return {"message": f"Questions with id {iid} deleted"}

@app.delete("/revision/questions/delete/topic_id")
def delete_question_by_topic_id(topic_id):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM questions WHERE topic_id = ?", (topic_id,))
    conn.commit() 
    conn.close()
    return {"message": f"Questions with id {topic_id} deleted"}

class QuestionItem(BaseModel):
    question: str
    answer: str
    end_date: str
    repetition: str
    status: str
    topic_id: str
@app.post("/revision/questions/create")
def create_question(question:QuestionItem ):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("""
    INSERT INTO questions (question, answer, end_date, repetition, status, topic_id)
    VALUES (?, ?, ?, ?, ?, ?)
""", (question.question,question.answer,question.end_date,question.repetition,question.status,question.topic_id))
    conn.commit()
    conn.close()
    return {"message":f"One row added", "data":{
        "question" : question.question,
        "answer" : question.answer,
        "end_date" : question.end_date,
        "repetition" : question.repetition,
        "status" : question.status,
        "topic_id" : question.topic_id
    }}

class UpdateQuestionStatus(BaseModel):
    question_id: int
    status: str
@app.put("/revision/questions/update_status")
def update_question_status(data:UpdateQuestionStatus):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE questions
        SET status = ?
        WHERE id = ?;
    """, (data.status,data.question_id))
    conn.commit()
    conn.close()
    return {"message": f"Record with id {data.question_id} updated successfully."}

@app.get("/revision/questions/update_no_repeat_question_status")
def update_no_repeat_question_status():
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE questions
        SET status = 'off'
        WHERE repetition = 0;
    """)
    conn.commit()
    conn.close()
    return {"message": "updated successfully."}

class UpdateQuestionRepetition(BaseModel):
    question_id: int
    repetition: int
@app.put("/revision/questions/update_question_repetition")
def update_question_repetition(data:UpdateQuestionRepetition):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE questions
        SET repetition = ?
        WHERE id = ?;
    """, (data.repetition,data.question_id))
    conn.commit()
    conn.close()
    return {"message": f"Record with id {data.question_id} updated successfully."}


class UpdateQuestionStatusByTopicID(BaseModel):
    topic_id: int
    status: str
@app.put("/revision/questions/update_status/topic_id")
def update_question_status_bu_topic_id(data:UpdateQuestionStatusByTopicID):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE questions
        SET status = ?
        WHERE topic_id = ?;
    """, (data.status,data.topic_id))
    conn.commit()
    conn.close()
    return {"message": f"Record with id {data.topic_id} updated successfully."}



# --------------------------- TASK MANAGER --------------------------- #

@app.get("/task_manager/read")
def get_blocked_apps():
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * from disabledapps")
    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "id":r[0],
            "process":r[1],
            "time":r[2],
            "message":r[3],
        }for r in rows
    ]

class AddProcesses(BaseModel):
    process : str
    time : str
    message :str

@app.post("/task_manager/add")
def add_blocked_apps(data:AddProcesses):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO disabledapps (process,time,message) VALUES (?,?,?)", (data.process,data.time,data.message))
    conn.commit()
    conn.close()
    return {"message":"New App Added"}


@app.delete("/task_manager/delete")
def delete_blocked_app(aid):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM disabledapps WHERE id = ?",(aid))
    conn.commit()
    conn.close()
    return {"message":f"App with id: {aid} deleted."}

@app.get("/task_manager/processes")
def get_processes():
    return fetch_apps.get_windows_processes()

 
# --------------------------- NOTIFICATION --------------------------- #

@app.post("/register_notification")
def register_notification():
    send_noti.register_app_icon_call()
    return send_noti.show_notification("Notification Registred","Now You Will See The Correct Notification")

class ShowNotification(BaseModel):
    title: str
    message: str

@app.post("/show_notification")
def show_notification(data:ShowNotification):
    send_noti.show_notification(title=data.title, content=data.message)

@app.post("/send_ai_notification")
def send_notification():
    url = "http://127.0.0.1:8000/send_ai_request"
    params = {
        "api_no": 0 
    }
    json_data = {
        "prompt": "Roast me cause I am not working, and being lazy, be hard and hash (be extremely short, like a single or two line roast)"
    }

    response = requests.post(url, params=params, json=json_data)
    response_json = response.json()
    text_output = response_json['candidates'][0]['content']['parts'][0]['text']
    send_noti.show_ai_notification("You wasting your time again!",text_output)
    return "A rosting notification sent!"

@app.get("/dismiss_notification")
def dismiss_notification():
    url = "http://127.0.0.1:8000/send_ai_request"
    params = {
        "api_no": 0 
    }
    json_data = {
        "prompt": "Roast me cause I am not working, and being lazy, be hard and hash (be extremely short, like a single or two line roast), and I have dismissed your saying once before already."
    }

    response = requests.post(url, params=params, json=json_data)
    response_json = response.json()
    text_output = response_json['candidates'][0]['content']['parts'][0]['text']
    send_noti.dismiss_popup("You are dismissing your life!",text_output)
    roasts = [
        "Oh, clicking 'Dismiss' again? Productivity called, it wants its time back! 🙄",
        "Wow, another dismiss! You're speedrunning procrastination like it's an Olympic sport! 🏆",
        "Dismissed! At this rate, your to-do list will outlive you. 💀",
        "Really? Again? Even your keyboard is judging you right now. ⌨️😒",
        "Congrats! You've successfully avoided work... again. Your future self hates you. 🎉",
        "Dismiss button broken? Oh wait, that's just you avoiding responsibilities! 😂",
        "Another dismiss = Another missed opportunity. But hey, at least you're consistent! 🤷",
        "Plot twist: The notification was trying to help you. You just rejected success. 📉"
    ]
    
    roast = random.choice(roasts)
    
    html_content = f"""
    <html>
        <head>
            <title>Roasted! 🔥</title>
            <style>
                body {{
                    margin: 0;
                    padding: 0;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    min-height: 100vh;
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                }}
                .container {{
                    background: white;
                    padding: 50px;
                    border-radius: 20px;
                    box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                    text-align: center;
                    max-width: 600px;
                    animation: slideIn 0.3s ease-out;
                }}
                @keyframes slideIn {{
                    from {{
                        transform: translateY(-50px);
                        opacity: 0;
                    }}
                    to {{
                        transform: translateY(0);
                        opacity: 1;
                    }}
                }}
                h1 {{
                    color: #e74c3c;
                    font-size: 3.5em;
                    margin: 0 0 20px 0;
                    animation: shake 0.5s ease-in-out;
                }}
                @keyframes shake {{
                    0%, 100% {{ transform: translateX(0); }}
                    25% {{ transform: translateX(-10px); }}
                    75% {{ transform: translateX(10px); }}
                }}
                p {{
                    color: #333;
                    font-size: 1.4em;
                    line-height: 1.8;
                    margin: 30px 0;
                }}
                .emoji {{
                    font-size: 5em;
                    margin: 20px 0;
                    animation: bounce 1s infinite;
                }}
                @keyframes bounce {{
                    0%, 100% {{ transform: translateY(0); }}
                    50% {{ transform: translateY(-20px); }}
                }}
                .shame {{
                    background: #e74c3c;
                    color: white;
                    padding: 15px 30px;
                    border-radius: 50px;
                    font-size: 1.2em;
                    font-weight: bold;
                    margin-top: 30px;
                    display: inline-block;
                }}
                .footer {{
                    margin-top: 40px;
                    color: #666;
                    font-size: 0.9em;
                    font-style: italic;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="emoji">🔥</div>
                <h1>You Did A Great Job!</h1>
                <p>{roast}</p>
                <div class="shame">SHAME 🔔 SHAME 🔔 SHAME</div>
                <div class="footer">Now stare at this and think about what you've done... 😤</div>
            </div>
        </body>
    </html>
    """
    return HTMLResponse(content=html_content)


# --------------------------- API --------------------------- #

class API_Model(BaseModel):
    prompt: str

@app.post("/send_ai_request")
def send_ai_request(api_no:int,y_data:API_Model):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("SELECT key FROM api")
    rows = cursor.fetchall()
    conn.close()
    api = rows
    headers = {
        "Content-Type": "application/json",
        "X-goog-api-key": api[api_no][0]
    }
    data = {
        "contents": [
            {
                "parts": [
                    {
                        "text": y_data.prompt
                    }
                ]
            }
        ]
    }

    response = requests.post("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent", headers=headers, json=data)
    return response.json()

class Add_API_Model(BaseModel):
    api: str

@app.post("/add_api_key")
def add_api_key(api:Add_API_Model):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO api (key) VALUES (?)",(api.api,))
    conn.commit()
    conn.close()



    
# --------------------------- REMEMBER --------------------------- #
@app.get("/remember")
def read_remember():
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id, title, content FROM remember")
    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "id": r[0],
            "title": r[1],
            "content": r[2]
        } for r in rows
    ]

@app.delete("/remember/delete")
def delete_remember(rid):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM remember WHERE id = ?", (rid,))
    conn.commit() 
    conn.close()
    return {"message": f"Note with id {rid} deleted"}

class RememberItem(BaseModel):
    title: str
    content: str
@app.post("/remember/create")
def create_remember_note(remember: RememberItem):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("""
    INSERT INTO remember (title, content)
    VALUES (?, ?)
""", (remember.title,remember.content))
    conn.commit()
    conn.close()
    return {"message":f"One row added", "data":{
        "title": remember.title,
        "content":remember.content
    }}


class UpdateRememberItem(BaseModel):
    id: int
    title: str
    content: str
@app.put("/remember/update")
def update_remember(item:UpdateRememberItem):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE remember
        SET title = ?, content = ?
        WHERE id = ?;
    """, (item.title, item.content, item.id))
    conn.commit()
    conn.close()
    return {"message": f"Record with id {item.id} updated successfully."}

    

# --------------------------- CLOCK --------------------------- #
# Timer
@app.get("/clock/timer")
def read_timer():
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id, title, time, message FROM timer")
    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "id": r[0],
            "title": r[1],
            "time": r[2],
            "message": r[3],
        } for r in rows
    ]

@app.delete("/clock/timer/delete")
def delete_timer(tid: int):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM timer WHERE id = ?", (tid,))
    conn.commit() 
    conn.close()
    return {"message": f"Timer with id {tid} deleted"}

class TimerItem(BaseModel):
    title: str
    time: str
    message: str
@app.post("/clock/timer/create")
def create_timer(timer: TimerItem):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("""
    INSERT INTO timer (title, time, message)
    VALUES (?, ?, ?)
""", (timer.title,timer.time,timer.message))
    conn.commit()
    conn.close()
    return {"message":f"One row added", "data":{
        "title": timer.title,
        "time":timer.time,
        "message": timer.message
    }}


# Alarm
@app.get("/clock/alarm")
def read_alarm():
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("SELECT id, title, time, message FROM alarm")
    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "id": r[0],
            "title": r[1],
            "time": r[2],
            "message": r[3],
        } for r in rows
    ]

@app.delete("/clock/alarm/delete")
def delete_alarm(aid: int):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM alarm WHERE id = ?", (aid,))
    conn.commit() 
    conn.close()
    return {"message": f"Alarm with id {aid} deleted"}

class AlarmItem(BaseModel):
    title: str
    time: str
    message: str
@app.post("/clock/alarm/create")
def create_alarm(alarm: AlarmItem):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("""
    INSERT INTO alarm (title, time, message)
    VALUES (?, ?, ?)
""", (alarm.title,alarm.time,alarm.message))
    conn.commit()
    conn.close()
    return {"message":f"One row added", "data":{
        "title": alarm.title,
        "time":alarm.time,
        "message": alarm.message
    }}


# --------------------------- HABIT TRACKER --------------------------- #



class HabitTrackerModel(BaseModel):
    month: int
    year: int

@app.post("/create_complete_habit_table")
def create_complete_habits_table(data:HabitTrackerModel):
    create_habit_table(HabitTrackerModel(month=data.month,year=data.year))
    add_all_habit_type_to_table(AllHabitTypeToTable(month=data.month,year=data.year))
    return {
        "message": "Created a Complete Habit Table"
    }
    

@app.post("/habit_tracker")
def read_habits(data:HabitTrackerModel):
    conn = get_habit_db()
    cursor = conn.cursor()
    m = ['january', 'february', 'march', 'april', 'may', 'june','july', 'august', 'september', 'october', 'november', 'december'][data.month-1]
    cursor.execute(f"SELECT * FROM {m}{data.year}")
    rows = cursor.fetchall()
    cursor.execute(f"PRAGMA table_info({m}{data.year})")
    columns = cursor.fetchall()
    conn.close()
    data = [columns,rows]
    return data


class CreateHabitTable(BaseModel):
    month: int
    year : int
@app.post("/create_habit_table")
def create_habit_table(data:CreateHabitTable):
    conn = get_habit_db()
    cursor =conn.cursor()
    m = ['january', 'february', 'march', 'april', 'may', 'june','july', 'august', 'september', 'october', 'november', 'december'][data.month-1]
    cursor.execute(f"""
                    CREATE TABLE IF NOT EXISTS {m}{data.year} (
                        day INTEGER UNIQUE
                   );
                   """)
    days_in_month = calendar.monthrange(data.year, data.month)[1]
    for i in range(1,days_in_month + 1):
        cursor.execute(f"INSERT OR IGNORE INTO {m}{data.year} (day) VALUES (?)", (i,))

    conn.commit()
    conn.close()
    return f"Created table {m}{data.year} with {days_in_month} days"

class UpdateHabitScore(BaseModel):
    day: int
    month: int
    year: int
    habit: str
    score: int


@app.put("/update_habit_score")
def update_habit_score(data:UpdateHabitScore):
    conn = get_habit_db()
    cursor =conn.cursor()
    m = ['january', 'february', 'march', 'april', 'may', 'june','july', 'august', 'september', 'october', 'november', 'december'][data.month-1]
    table = f"{m}{data.year}"
    cursor.execute(f"""UPDATE {table}
                   SET {data.habit} = ?
                   WHERE day = ?;
                   """,(data.score,data.day))
    conn.commit()
    conn.close()
    return {"message": f"Updated day {data.day} in {table} with score {data.score} for habit: {data.habit}"}


# Habit Types
@app.get("/habit/get_habits_types")
def get_habit_types():
    conn = get_habit_db()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM habits")
    rows = cursor.fetchall()
    conn.close()
    return [
        {
         "id": row[0],
         "habit": row[1]
        } for row in rows
    ]

@app.delete("/habit/delete_habit_type")
def delete_habit_type(tid:int):
    conn = get_habit_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM habits WHERE id = ?",(tid,))
    conn.commit()
    conn.close()
    return f"DELETED HABIT WITH ID: {tid}"

@app.post("/habit/add_habit_type")
def add_habit_type(habitname):
    conn = get_habit_db()
    cursor = conn.cursor()
    cursor.execute("INSERT INTO habits (habit) VALUES (?)",(habitname,))
    conn.commit()
    conn.close()
    return f"Add {habitname} HABIT"



# Habit Type and Table
class HabitTypeToTable(BaseModel):
    month: int
    year: int
    habit: str

@app.post("/habit/add_habit_type_to_table")
def add_habit_type_to_table(data:HabitTypeToTable):
    conn = get_habit_db()
    cursor = conn.cursor()
    m = ['january', 'february', 'march', 'april', 'may', 'june','july', 'august', 'september', 'october', 'november', 'december'][data.month-1]
    table = f"{m}{data.year}"
    cursor.execute(f"ALTER TABLE {table} ADD COLUMN {data.habit} INTEGER;")
    cursor.execute(f"UPDATE {table} SET {data.habit} = 0;")
    conn.commit()
    conn.close()
    return {"message":f"Added {data.habit} to {table}"}
    

class AllHabitTypeToTable(BaseModel):
    month: int
    year: int

@app.post("/habit/add_all_habit_type_to_table")
def add_all_habit_type_to_table(data:AllHabitTypeToTable):
    conn = get_habit_db()
    cursor = conn.cursor()
    m = ['january', 'february', 'march', 'april', 'may', 'june','july', 'august', 'september', 'october', 'november', 'december'][data.month-1]
    table = f"{m}{data.year}"
    for i in get_habit_types():
        habit = i["habit"]
        cursor.execute(f"ALTER TABLE {table} ADD COLUMN {habit} INTEGER;")
        cursor.execute(f"UPDATE {table} SET {habit} = 0;")
    conn.commit()
    conn.close()
    return {"message":f"Added all Habits to {table}"}

class DeleteHabitTypeFromTable(BaseModel):
    month: int
    year: int
    habit: str

@app.delete("/habit/delete_habit_type_from_table")
def delete_habit_type_from_table(data:DeleteHabitTypeFromTable):
    conn = get_habit_db()
    cursor = conn.cursor()
    m = ['january', 'february', 'march', 'april', 'may', 'june','july', 'august', 'september', 'october', 'november', 'december'][data.month-1]
    table = f"{m}{data.year}"
    cursor.execute(f"ALTER TABLE {table} DROP COLUMN {data.habit};")
    conn.commit()
    conn.close()
    return {"message":f"Deleted {data.habit} From {table}"}


# --------------------------- TODO --------------------------- #
class TodoItem(BaseModel):
    status: str
    title: str
    description: str = ""
    note: str = ""
    priority: str = ""
    category: str = ""
    due_date: str = ""
    due_time: str = ""
@app.get("/todos")
def read_todos():
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("""
    SELECT * FROM todo
    ORDER BY 
        CASE 
            WHEN status = 'pending' THEN 0
            WHEN status = 'done' THEN 1
        END,
        id ASC
                   """)

    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "id": r[0],
            "status": r[1],
            "title": r[2],
            "description": r[3],
            "note": r[4],
            "priority": r[5],
            "category": r[6],
            "due_date": r[7],
            "due_time": r[8]
        }
        for r in rows
    ]

@app.post("/todos")
def create_todo(todo: TodoItem):
    conn = get_pragti_db()
    cursor = conn.cursor()
    
    # Insert everything except 'id'
    cursor.execute("""
        INSERT INTO todo (status, title, description, note, priority, category, due_date, due_time)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        todo.status, todo.title, todo.description, todo.note,
        todo.priority, todo.category, todo.due_date, todo.due_time
    ))
    conn.commit()
    
    new_id = cursor.lastrowid  # <-- Python reads the auto-generated id here
    conn.close()
    
    # Return the id along with the fields for the client
    return {"id": new_id, **todo.dict()}

@app.delete("/todos/{todo_id}")
def delete_todo(todo_id: int):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM todo WHERE id = ?", (todo_id,))
    conn.commit()
    affected = cursor.rowcount
    conn.close()

    if affected == 0:
        raise HTTPException(status_code=404, detail="Todo not found")
    return {"detail": f"Deleted todo with id {todo_id}"}


class TodoUpdate(BaseModel):
    status: str = None
    title: str = None
    description: str = None
    note: str = None
    priority: str = None
    category: str = None
    due_date: str = None
    due_time: str = None

@app.put("/todos/{todo_id}")
def update_todo(todo_id: int, todo: TodoUpdate):
    conn = get_pragti_db()
    cursor = conn.cursor()

    fields = []
    values = []

    for key, value in todo.dict().items():
        if value is not None:
            fields.append(f"{key} = ?")
            values.append(value)

    if not fields:
        conn.close()
        raise HTTPException(status_code=400, detail="No fields to update")

    values.append(todo_id)
    sql = f"UPDATE todo SET {', '.join(fields)} WHERE id = ?"
    cursor.execute(sql, values)
    conn.commit()
    affected = cursor.rowcount
    conn.close()

    if affected == 0:
        raise HTTPException(status_code=404, detail="Todo not found")

    return {"detail": f"Updated todo with id {todo_id}"}



@app.patch("/todos/toggle")
def toggle_todo_status(todo_id: int,status:str):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("UPDATE todo SET status = ? WHERE id = ?", (status, todo_id))
    conn.commit()
    conn.close()

    return {"id": todo_id, "status": status}


# --------------------------- Expenses --------------------------- #
class ExpenseItem(BaseModel):
    title: str
    description: str = ""
    money: float
    type: str  # e.g., "income" or "expense"
    category: str = ""
    date: str = ""
    time: str = ""


@app.get("/expenses")
def read_expenses():
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT id, title, description, money, type, category, date, time
        FROM expenses
    """)
    rows = cursor.fetchall()
    conn.close()
    return [
        {
            "id": r[0],
            "title": r[1],
            "description": r[2],
            "money": r[3],
            "type": r[4],
            "category": r[5],
            "date": r[6],
            "time": r[7],
        }
        for r in rows
    ]


@app.post("/expenses")
def create_expense(expense: ExpenseItem):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO expenses (title, description, money, type, category, date, time)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    """, (
        expense.title, expense.description, expense.money, expense.type,
        expense.category, expense.date, expense.time
    ))
    conn.commit()
    new_id = cursor.lastrowid
    conn.close()

    return {"id": new_id, **expense.dict()}


@app.delete("/expenses/{expense_id}")
def delete_expense(expense_id: int):
    conn = get_pragti_db()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM expenses WHERE id = ?", (expense_id,))
    conn.commit()
    affected = cursor.rowcount
    conn.close()

    if affected == 0:
        raise HTTPException(status_code=404, detail="Expense not found")
    return {"detail": f"Deleted expense with id {expense_id}"}


class ExpenseUpdate(BaseModel):
    title: str = None
    description: str = None
    money: float = None
    type: str = None
    category: str = None
    date: str = None
    time: str = None

@app.put("/expenses/{expense_id}")
def update_expense(expense_id: int, expense: ExpenseUpdate):
    conn = get_pragti_db()
    cursor = conn.cursor()

    fields = []
    values = []

    for key, value in expense.dict().items():
        if value is not None:
            fields.append(f"{key} = ?")
            values.append(value)

    if not fields:
        conn.close()
        raise HTTPException(status_code=400, detail="No fields to update")

    values.append(expense_id)
    sql = f"UPDATE expenses SET {', '.join(fields)} WHERE id = ?"
    cursor.execute(sql, values)
    conn.commit()
    affected = cursor.rowcount
    conn.close()

    if affected == 0:
        raise HTTPException(status_code=404, detail="Expense not found")

    return {"detail": f"Updated expense with id {expense_id}"}

logging.basicConfig(
    filename="backend.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

if __name__ == "__main__":
    uvicorn.run(
        app,
        host="127.0.0.1",
        port=8000,
        workers=1,
        log_config=None,
        access_log=False
    )