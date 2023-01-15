// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Todos {
    struct Todo {
        string task;
        bool isDone;
    }

    Todo[] private todos;

    function addTodo(string calldata _task) external {
        Todo memory todo = Todo({
            task: _task,
            isDone: false
        });
        todos.push(todo);
    }

    function updateTaskContent(string calldata _task, uint _id) external {
        todos[_id].task = _task;
    }

    function updateTaskStatus(uint _id) external {
        todos[_id].isDone = !todos[_id].isDone;
    }

    function removeTask(uint _id) external {
        for (uint i= _id; i < todos.length - 1; i++) {
            todos[i] = todos[i + 1];
        }
        todos.pop();
    }


    function getTodoAtIndex(uint _id) external view  returns(Todo memory) {
        return todos[_id];
    }

    function getTodos() external view returns(Todo[] memory) {
        return todos;
    }

}
