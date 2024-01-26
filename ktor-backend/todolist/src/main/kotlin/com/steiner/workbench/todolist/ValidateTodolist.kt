package com.steiner.workbench.todolist

import com.steiner.workbench.todolist.request.*
import io.ktor.server.plugins.requestvalidation.*

fun RequestValidationConfig.validateTodolist() {
    validate<PostSubTaskRequest> {
        it.validate()
    }

    validate<PostTagRequest> {
        it.validate()
    }

    validate<PostTaskGroupRequest> {
        it.validate()
    }

    validate<PostTaskProjectRequest> {
        it.validate()
    }

    validate<PostTaskRequest> {
        it.validate()
    }

    validate<UpdateSubTaskRequest> {
        it.validate()
    }

    validate<UpdateTagRequest> {
        it.validate()
    }

    validate<UpdateTaskGroupRequest> {
        it.validate()
    }

    validate<UpdateTaskProjectRequest> {
        it.validate()
    }

    validate<UpdateTaskRequest> {
        it.validate()
    }

    validate<ReorderRequest> {
        it.validate()
    }

    validate<PostPriorityRequest> {
        it.validate()
    }

    validate<UpdatePriorityRequest> {
        it.validate()
    }
}