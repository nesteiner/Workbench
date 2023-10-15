package com.steiner.workbench.todolist.model

import com.fasterxml.jackson.annotation.JsonIgnore

class ImageItem(
        val id: Int,
        val name: String,
        @JsonIgnore
        val path: String,
)