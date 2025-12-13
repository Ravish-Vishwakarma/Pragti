import threading,requests,time,json,random
BASEURL = "http://127.0.0.1:8000"

# ----------------------- Blocked Apps ----------------------- #
ba = {}
def get_blocked_instances():
    global ba
    blocked_apps = requests.get(BASEURL+'/task_manager/read').json()
    ba = blocked_apps

def check_blocked_apps():
    if ba:
        process = set(requests.get(BASEURL+'/task_manager/processes').json())
        for i in ba:
            if i["process"] in process:
                body = json.dumps({"title": f"You are using a blocked app, {i["process"]}","message": f"{i["message"]}"})
                header = {'Content-Type': 'application/json'}
                requests.post(BASEURL+"/show_notification",headers=header,data=body)
                print(ba[0])
                ba.pop(0)
                break



# ----------------------- Revision ----------------------- #
rq = [] #revision questions
def get_revision_question():
    global rq
    questions = requests.get(BASEURL+"/revision/recent_questions").json()
    rq=questions

def send_revision_questions():
    if rq:
        probablity = 1 != random.randint(1,len(rq))
        print(probablity)
        if probablity:
            header = {'Content-Type': 'application/json'}
            question = rq[0]
            body = json.dumps({"title": f"{question["question"]}","message": f"{question["answer"]}"})
            requests.post(BASEURL+"/show_notification",headers=header,data=body)
            print(body)
            rq.pop(0)
        else:
            rq.pop(0)
            send_revision_questions()
    else:
        get_revision_question()



# ----------------------- Loops ----------------------- #

def dataloop():
    while True:
        get_blocked_instances()
        get_revision_question()
        time.sleep(10*60)

def blockedapps():
    while True:
        check_blocked_apps()
        time.sleep(5*60)

def revisionloop():
    while True:
        send_revision_questions()
        time.sleep(16*60)


threading.Thread(target=dataloop, daemon=True).start()
threading.Thread(target=blockedapps, daemon=True).start()
threading.Thread(target=revisionloop, daemon=True).start()

while True:
    pass