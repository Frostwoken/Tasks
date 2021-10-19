pragma ton-solidity >= 0.35.0;
pragma AbiHeader expire;

contract TaskList {
    struct Task {
        string name;
        uint32 timestamp;
        bool isCompleted;
    }
    mapping (int8 => Task) tasks;
    int8 taskCount = 0;
    int8 openTaskCount = 0;

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

    function addTask(string name) public checkOwnerAndAccept {
        Task task = Task(name, now, false);
        tasks[taskCount] = task;
        taskCount++;
        openTaskCount++;
    }

    function getNumberOfTasks() public view returns (int8) {
        return openTaskCount;
    }
    
    function getListOfTasks() public checkOwnerAndAccept returns (mapping (int8 => Task)) {
        require(openTaskCount != 0, 100, "No tasks found.");
        mapping (int8 => Task) openTasks;
        for (int8 i = 0; i < taskCount; ++i)
            if (tasks.exists(i) && tasks[i].isCompleted == false)
                openTasks[i] = tasks[i];
        return openTasks;
    }

    function getTaskDescriptionByKey(int8 key) public view returns (Task) {
        require(tasks.exists(key), 100, "Key not found.");
        return tasks[key];
    }

    function deleteTaskByKey(int8 key) public checkOwnerAndAccept {
        require(tasks.exists(key), 100, "Key not found.");
        if (tasks[key].isCompleted == false)
            openTaskCount--;
        delete tasks[key];
    }

    function completeTask(int8 key) public checkOwnerAndAccept {
        require(tasks.exists(key), 100, "Key not found.");
        tasks[key].isCompleted = true;
        openTaskCount--;
    }
}