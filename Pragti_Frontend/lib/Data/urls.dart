class Urls {
  static const baseUrl = 'http://127.0.0.1:8000';
  static final expenses = '$baseUrl/expenses';
  static const remember = "$baseUrl/remember";

  // ---------------- Schedule ---------------- //
  static final getschedule = '$baseUrl/scheduling/get';
  static final createschedule = '$baseUrl/scheduling/create';
  static final deleteschedule = '$baseUrl/scheduling/delete';
  static final updateschedule = '$baseUrl/scheduling/update';

  // ---------------- Todo ---------------- //
  static final todo = '$baseUrl/todos';
  static final deletetodo = '$baseUrl/todos/';
  static final toggletodo = '$baseUrl/todos/toggle'; //?todo_id=1&status=pending

  // ---------------- HABIT ---------------- //
  static const gethabit = "$baseUrl/habit_tracker";
  static const updatehabitscore = "$baseUrl/update_habit_score";
  static const createcompletehabitable = "$baseUrl/create_complete_habit_table";

  // Habit Types & Table //
  static const addhabittypetotable = "$baseUrl/habit/add_habit_type_to_table";
  static const deletehabittypefromtable =
      "$baseUrl/habit/delete_habit_type_from_table";

  // Habit Types //
  static const gethabittypes = "$baseUrl/habit/get_habits_types";
  static const deletehabittypes = "$baseUrl/habit/delete_habit_type";
  static const addhabittypes = "$baseUrl/habit/add_habit_type";

  // ---------------- CLOCK ---------------- //
  static const gettimer = "$baseUrl/clock/timer";
  static const deletetimer = "$baseUrl/clock/timer/delete";
  static const addtimer = "$baseUrl/clock/timer/create";
  static const getalarm = "$baseUrl/clock/alarm";
  static const deletealarm = "$baseUrl/clock/alarm/delete";
  static const addalarm = "$baseUrl/clock/alarm/create";

  // ---------------- QUESTIONS ---------------- //
  static const getquestions = "$baseUrl/revision/questions";
  static const updatequestionstatusbyid =
      "$baseUrl/revision/questions/update_status";
  static const deletequestionbyid = "$baseUrl/revision/questions/delete";
  static const addquestion = "$baseUrl/revision/questions/create";

  // ---------------- TOPIC ---------------- //
  static const addtopic = "$baseUrl/revision/topic/create";

  // ---------------- Task Manager ---------------- //
  static const getprocesses = "$baseUrl/task_manager/processes";
  static const getblockprocesses = "$baseUrl/task_manager/read";
  static const addblockedapp = "$baseUrl/task_manager/add";

  // ---------------- Notification ---------------- //
  static const shownotification = "$baseUrl/show_notification";

  // ---------------- Notification ---------------- //
  static const sendaiprompt = "$baseUrl/send_ai_request?api_no=0";
}
