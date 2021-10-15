pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract TaskList {
    struct task {
        string taskName;
        uint32 timestamp;
        bool taskCompleted;
    }
    mapping (int8 => task) tasks;
    int8 index = 0;
    int8 taskCounter = 0;

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
    }
    
    modifier checkOwnerAndAccept {
	require(msg.pubkey() == tvm.pubkey(), 102);
	tvm.accept();
	_;
    }

    function addTask(string taskName) public checkOwnerAndAccept {
        task newTask = task(taskName, now, false);
        tasks[index] = newTask;
        index++;
        taskCounter++;
    }

    function getNumberOfTasks() public view returns (int8) {
        return taskCounter;
    }
    
    function getListOfTasks() public view returns (mapping (int8 => task)) {
        require(taskCounter != 0, 100, "No tasks found.");
        return tasks;
    }

    function getTaskDescriptionByKey(int8 key) public view returns (task) {
        require(tasks.exists(key), 100, "Key not found.");
        return tasks[key];
    }

    function deleteTaskByKey(int8 key) public checkOwnerAndAccept {
        require(tasks.exists(key), 100, "Key not found.");
        delete tasks[key];
        taskCounter--;
    }

    function completeTask(int8 key) public checkOwnerAndAccept {
        require(tasks.exists(key), 100, "Key not found.");
        tasks[key].taskCompleted = true;
    }
}