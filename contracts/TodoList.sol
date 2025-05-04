// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
/* this contract lists all tasks that user needs to complete
the user can add,update and delete tasks
*/
contract TodoList {
    // shows the status a task can exist
    enum Status { Pending, InProgress, Completed }

    //struct to rpresent task
    struct Todo {
        uint id;
        string content;
        Status status;
    }
    // this mapping stores todos by ID
    mapping(uint => Todo) public todos;
    uint[] public todoIds;
    uint public nextId = 1;

    event TodoAdded(uint id, string content);//emmited when a new todo is added

   //this function adds new task to the TodoList
    function addTodo(string memory _content) public {
        todos[nextId] = Todo(nextId, _content, Status.Pending);
        todoIds.push(nextId);
        emit TodoAdded(nextId, _content);
        nextId++;
    }

     //updates a todo's status
    function updateStatus(uint _id, Status _status) public {
        require(_id < nextId, "Todo does not exist");
        todos[_id].status = _status;
    }
      
    //this function gets a specific todo item
    function getTodo(uint _id) public view returns (uint, string memory, Status) {
        require(_id < nextId, "Todo does not exist");
        Todo storage todo = todos[_id];
        return (todo.id, todo.content, todo.status);
    }
}
