import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../theme.dart';
import '../widgets/task_card.dart';
import '../widgets/stats_summary.dart';
import '../widgets/empty_state.dart';
import 'task_form_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TaskFormSheet(),
    );
  }

  void _showEditTask(BuildContext context, task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFormSheet(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: AppTheme.background,
        actions: [
          Consumer<TaskProvider>(
            builder: (_, provider, __) => provider.completedCount > 0
                ? TextButton.icon(
                    onPressed: () => _showClearCompleted(context, provider),
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: const Text('Clear done'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary),
                  )
                : const SizedBox.shrink(),
          ),
          _SortFilterButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          final tasks = provider.tasks;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: StatsSummary(
                  total: provider.totalCount,
                  completed: provider.completedCount,
                  pending: provider.pendingCount,
                ),
              ),
              SliverToBoxAdapter(
                child: _FilterChips(),
              ),
              if (tasks.isEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: EmptyState(
                      title: provider.filter == FilterType.completed
                          ? 'No completed tasks'
                          : provider.filter == FilterType.active
                              ? 'No active tasks'
                              : 'No tasks yet',
                      subtitle: provider.filter == FilterType.all
                          ? 'Tap the + button to add your first task'
                          : 'Tasks will appear here once available',
                      icon: provider.filter == FilterType.completed
                          ? Icons.task_alt_rounded
                          : Icons.checklist_rounded,
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final task = tasks[i];
                      return TaskCard(
                        key: Key(task.id),
                        task: task,
                        onToggle: () => provider.toggleTask(task.id),
                        onEdit: () => _showEditTask(context, task),
                        onDelete: () => provider.deleteTask(task.id),
                      );
                    },
                    childCount: tasks.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: FloatingActionButton(
          onPressed: () => _showAddTask(context),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  void _showClearCompleted(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Completed'),
        content: Text(
            'Remove ${provider.completedCount} completed task${provider.completedCount == 1 ? '' : 's'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearCompleted();
              Navigator.pop(ctx);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (_, provider, __) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(
            children: [
              _chip(context, provider, FilterType.all, 'All'),
              const SizedBox(width: 8),
              _chip(context, provider, FilterType.active, 'Active'),
              const SizedBox(width: 8),
              _chip(context, provider, FilterType.completed, 'Done'),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(BuildContext context, TaskProvider provider, FilterType type,
      String label) {
    final isSelected = provider.filter == type;
    return GestureDetector(
      onTap: () => provider.setFilter(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SortFilterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (_, provider, __) => PopupMenuButton<SortType>(
        icon: const Icon(Icons.sort_rounded, color: AppTheme.textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tooltip: 'Sort tasks',
        onSelected: provider.setSort,
        itemBuilder: (_) => [
          _sortItem(SortType.createdDate, 'Date Created',
              Icons.calendar_today_rounded, provider.sort),
          _sortItem(SortType.dueDate, 'Due Date', Icons.schedule_rounded,
              provider.sort),
          _sortItem(
              SortType.priority, 'Priority', Icons.flag_rounded, provider.sort),
        ],
      ),
    );
  }

  PopupMenuItem<SortType> _sortItem(
      SortType type, String label, IconData icon, SortType current) {
    final isSelected = current == type;
    return PopupMenuItem(
      value: type,
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          if (isSelected)
            const Icon(Icons.check_rounded, size: 16, color: AppTheme.primary),
        ],
      ),
    );
  }
}
