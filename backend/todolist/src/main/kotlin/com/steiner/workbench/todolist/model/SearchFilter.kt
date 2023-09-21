package com.steiner.workbench.todolist.model

sealed class SearchFilter {
    class ByTag(val tag: Tag): SearchFilter()
    class ByIsdone(val isdone: Boolean): SearchFilter()

}