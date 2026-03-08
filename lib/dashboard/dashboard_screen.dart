import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../auth/login_screen.dart';
import 'task_tile.dart';
import 'add_task_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  void _showAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final taskProv = context.watch<TaskProvider>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good ${_greeting()}! 👋', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                  Text('My Tasks', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_outlined),
                  onPressed: () async {
                    await auth.signOut();
                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                ),
              ],
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _StatCard(
                      label: 'Total',
                      count: taskProv.tasks.length,
                      color: theme.colorScheme.primary,
                      icon: Icons.list_alt,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Pending',
                      count: taskProv.pendingTasks.length,
                      color: Colors.orange,
                      icon: Icons.pending_actions,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Done',
                      count: taskProv.completedTasks.length,
                      color: Colors.green,
                      icon: Icons.task_alt,
                    ),
                  ],
                ),
              ),
            ),

            // Task List
            if (taskProv.status == TaskStatus.loading)
              SliverList(delegate: SliverChildBuilderDelegate(
                    (_, i) => _ShimmerTile(),
                childCount: 5,
              ))
            else if (taskProv.tasks.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('No tasks yet!', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('Tap + to add your first task', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (_, i) {
                      final task = taskProv.tasks[i];
                      return TaskTile(
                        task: task,
                        onDelete: () => taskProv.deleteTask(task.id),
                        onToggle: () => taskProv.toggleTask(task.id, task.isCompleted),
                        onEdit: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => AddTaskSheet(editTask: task),
                        ),
                      );
                    },
                    childCount: taskProv.tasks.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTask,
        label: const Text('Add Task'),
        icon: const Icon(Icons.add),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({required this.label, required this.count, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
        ],
      ),
    ),
  );
}

class _ShimmerTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: Container(height: 70, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(16))),
    ),
  );
}