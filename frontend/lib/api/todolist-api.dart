import 'package:dio/dio.dart';
import 'package:frontend/api/api.dart';
import 'package:frontend/api/interceptor.dart';
import 'package:frontend/model/todolist.dart';
import 'package:frontend/request/todolist.dart';
import 'package:frontend/utils.dart';

class TodoListApi extends Api {
  static const String contentType = "application/json; charset=utf-8";
  static const ResponseType responseType = ResponseType.json;
  static BaseOptions defaultOptions = BaseOptions(contentType: contentType, responseType: responseType);

  late final Dio instance;
  String todolistUrl;
  void Function(DioException) errorHandler;

  TodoListApi({required this.todolistUrl, required this.errorHandler}): assert(!todolistUrl.endsWith("/")) {
    instance = Dio(defaultOptions);
    instance.interceptors.add(CustomInterceptors(errorHandler: errorHandler));
  }

  @override
  void setToken(String token) {
    late String token1;
    if (token.startsWith("Bearer")) {
      token1 = token;
    } else {
      token1 = "Bearer $token";
    }

    instance.options.headers["Authorization"] = token1;
  }


  Future<ImageItem> uploadImage(MultipartFile file) async {
    FormData data = FormData.fromMap({
      "file": file
    });

    Response<Map<String, dynamic>> response = await instance.post("$todolistUrl/image/upload", data: data);
    return ImageItem.fromJson(response.data!["data"]);
  }

  Future<ImageItem> defaultTodoListImage() async {
    Response<Map<String, dynamic>> response = await instance.get("$todolistUrl/image/download/default");
    return ImageItem.fromJson(response.data!["data"]);
  }

  Future<Tag> insertTag(PostTagRequest request) async {
    Response<Map<String, dynamic>> response = await instance.post("$todolistUrl/tag", data: request.toJson());
    return Tag.fromJson(response.data!["data"]);
  }

  Future<Tag> updateTag(UpdateTagRequest request) async {
    Response<Map<String, dynamic>> response = await instance.put("$todolistUrl/tag", data: request.toJson());
    return Tag.fromJson(response.data!["data"]);
  }

  Future<List<Tag>> findAllTags(int projectid) async {
    Response<Map<String, dynamic>> response = await instance.get("$todolistUrl/tag?projectid=$projectid");
    return response.data!["data"].map<Tag>((e) => Tag.fromJson(e)).toList();
  }

  Future<Task> insertTask(PostTaskRequest request) async {
    Response<Map<String, dynamic>> response = await instance.post("$todolistUrl/task", data: request.toJson());
    return Task.fromJson(response.data!["data"]);
  }

  Future<void> insertTaskTag(PostTaskTagRequest request) async {
    await instance.post("$todolistUrl/task/tag", data: request.toJson());
  }

  Future<void> deleteTask(int id) async {
    await instance.delete("$todolistUrl/task/$id");
  }

  Future<Task> updateTask(UpdateTaskRequest request) async {
    Response<Map<String, dynamic>> response = await instance.put("$todolistUrl/task", data: request.toJson());
    return Task.fromJson(response.data!["data"]);
  }

  Future<void> removeDeadline(int id) async {
    await instance.delete("$todolistUrl/task/deadline/$id");
  }

  Future<void> removeNotifyTime(int id) async {
    await instance.delete("$todolistUrl/task/notifyTime/$id");
  }

  Future<void> removeTag(int taskid, int tagid) async {
    await instance.delete("$todolistUrl/task/tag?taskid=$taskid&tagid=$tagid");
  }

  Future<TaskGroup> insertTaskGroup(PostTaskGroupRequest request) async {
    Response<Map<String, dynamic>> response = await instance.post("$todolistUrl/taskgroup", data: request.toJson());
    return TaskGroup.fromJson(response.data!["data"]);
  }

  Future<TaskGroup> insertTaskGroupAfter(PostTaskGroupRequest request, int after) async {
    Response<Map<String, dynamic>> response = await instance.post("$todolistUrl/taskgroup?after=$after", data: request.toJson());
    return TaskGroup.fromJson(response.data!["data"]);
  }

  Future<void> deleteTaskGroup(int id) async {
    await instance.delete("$todolistUrl/taskgroup/$id");
  }

  Future<TaskGroup> updateTaskGroup(UpdateTaskGroupRequest request) async {
    Response<Map<String, dynamic>> response = await instance.put("$todolistUrl/taskgroup", data: request.toJson());
    return TaskGroup.fromJson(response.data!["data"]);
  }

  Future<List<TaskGroup>> findAllTaskGroups(int projectid) async {
    Response<Map<String, dynamic>> response = await instance.get("$todolistUrl/taskgroup?projectid=$projectid");
    return response.data!["data"].map<TaskGroup>((e) => TaskGroup.fromJson(e)).toList();
  }

  Future<TaskProject> insertTaskProject(PostTaskProjectRequest request) async {
    Response<Map<String, dynamic>> response = await instance.post("$todolistUrl/taskproject", data: request.toJson());
    return TaskProject.fromJson(response.data!["data"]);
  }

  Future<void> deleteTaskProject(int id) async {
    await instance.delete("$todolistUrl/taskproject/$id");
  }

  Future<TaskProject> updateTaskProject(UpdateTaskProjectRequest request) async {
    Response<Map<String, dynamic>> response = await instance.put("$todolistUrl/taskproject", data: request.toJson());
    return TaskProject.fromJson(response.data!["data"]);
  }

  Future<List<TaskProject>> findAllTaskProjects() async {
    Response<Map<String, dynamic>> response = await instance.get("$todolistUrl/taskproject");
    return response.data!["data"].map<TaskProject>((e) => TaskProject.fromJson(e)).toList();
  }

  Future<PageContainer<TaskProject>> findAllTaskProjectsPagination(int page, int size) async {
    Response<Map<String, dynamic>> response = await instance.get("$todolistUrl/taskproject?page=$page&size=$size");

    Map<String, dynamic> data = response.data!["data"];
    List<TaskProject> content = data["content"].map<TaskProject>((e) => TaskProject.fromJson(e)).toList();
    int totalPages = data["totalPages"];

    return PageContainer(content: content, totalPages: totalPages);
  }

  Future<SubTask> insertSubTask(PostSubTaskRequest request) async {
    Response<Map<String, dynamic>> response = await instance.post("$todolistUrl/subtask", data: request.toJson());
    Map<String, dynamic> data = response.data!["data"];
    return SubTask.fromJson(data);
  }

  Future<void> deleteSubTask(int id) async {
    await instance.delete("$todolistUrl/subtask/$id");
  }

  Future<SubTask> updateSubTask(UpdateSubTaskRequest request) async {
    Response<Map<String, dynamic>> response = await instance.put("$todolistUrl/subtask", data: request.toJson());
    return SubTask.fromJson(response.data!["data"]);
  }

  Future<String> test() async {
    Response<Map<String, dynamic>> response = await instance.get("$todolistUrl/test");
    return response.data!["data"];
  }
}