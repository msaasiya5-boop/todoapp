import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

enum FilterType { all, active, completed }
enum SortType { createdDate, dueDate, priority }

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  FilterType _filter = FilterType.all;
  SortType _sort = SortType.createdDate;

  List<Task> get tasks => _filteredAndSortedTasks();
  FilterType get filter => _filter;
  SortType get sort => _sort;

  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;

  TaskProvider() {
    _loadTasks();
  }

  List<Task> _filteredAndSortedTasks() {
    List<Task> result = List.from(_tasks);

    // Filter
    switch (_filter) {
      case FilterType.active:
        result = result.where((t) => !t.isCompleted).toList();
        break;
      case FilterType.completed:
        result = result.where((t) => t.isCompleted).toList();
        break;
      case FilterType.all:
        break;
    }

    // Sort
    switch (_sort) {
      case SortType.createdDate:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortType.dueDate:
        result.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case SortType.priority:
        result.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
    }

    // Completed tasks go to the bottom
    final pending = result.where((t) => !t.isCompleted).toList();
    final completed = result.where((t) => t.isCompleted).toList();
    return [...pending, ...completed];
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      _saveTasks();
      notifyListeners();
    }
  }

  void setFilter(FilterType filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSort(SortType sort) {
    _sort = sort;
    notifyListeners();
  }

  void clearCompleted() {
    _tasks.removeWhere((t) => t.isCompleted);
    _saveTasks();
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = _tasks.map((t) => t.toJson()).toList();
    await prefs.setString('tasks', json.encode(taskList));
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');
    if (data != null) {
      final List decoded = json.decode(data);
      _tasks = decoded.map((e) => Task.fromJson(e)).toList();
      notifyListeners();
    }
  }
}
