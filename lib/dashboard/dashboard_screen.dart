import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../auth/login_screen.dart';
import 'task_model.dart';
import 'add_task_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late Animation<double> _headerAnim;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerAnim =
        CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic);
    _headerCtrl.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning!';
    if (h < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final taskProv = context.watch<TaskProvider>();
    final email = auth.currentUser?.email ?? '';
    final name = email.contains('@')
        ? email.split('@')[0].capitalize()
        : 'User';

    return Scaffold(
      backgroundColor: const Color(0xFF1C2331),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(name, auth),

            // Content
            Expanded(
              child: taskProv.status == TaskStatus.loading
                  ? _buildShimmer()
                  : taskProv.tasks.isEmpty
                  ? _buildEmptyState()
                  : _buildTaskList(taskProv),
            ),
          ],
        ),
      ),

      // Bottom Nav
      bottomNavigationBar: _DayTaskBottomNav(
        selectedIndex: _selectedTab,
        onTap: (i) {
          if (i == 2) {
            // FAB center button → Add task
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const AddTaskSheet(),
            );
          } else {
            setState(() => _selectedTab = i);
          }
        },
      ),
    );
  }

  Widget _buildHeader(String name, AuthProvider auth) {
    return AnimatedBuilder(
      animation: _headerAnim,
      builder: (_, __) => Opacity(
        opacity: _headerAnim.value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - _headerAnim.value)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              children: [
                // Top row: greeting + avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFF5C518),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        await auth.signOut();
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        }
                      },
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5C518),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                              const Color(0xFFF5C518).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF1C2331),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Search bar + filter
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF263040),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(Icons.search_rounded,
                                color: Color(0xFF8A9BB0), size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Search tasks',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF8A9BB0),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5C518),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune_rounded,
                          color: Color(0xFF1C2331), size: 22),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(TaskProvider taskProv) {
    final pending = taskProv.pendingTasks;
    final completed = taskProv.completedTasks;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Completed Tasks section (horizontal scroll cards)
          if (completed.isNotEmpty) ...[
            _SectionHeader(
              title: 'Completed Tasks',
              onSeeAll: () {},
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: completed.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _CompletedTaskCard(task: completed[i]),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Ongoing / All Tasks section
          _SectionHeader(
            title: pending.isEmpty ? 'All Tasks' : 'Ongoing Tasks',
            onSeeAll: () {},
          ),
          const SizedBox(height: 12),

          if (pending.isEmpty && completed.isNotEmpty)
            _AllDoneCard()
          else
            ...pending.asMap().entries.map((e) => _AnimatedTaskTile(
              task: e.value,
              index: e.key,
              onDelete: () =>
                  taskProv.deleteTask(e.value.id),
              onToggle: () =>
                  taskProv.toggleTask(e.value.id, e.value.isCompleted),
              onEdit: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddTaskSheet(editTask: e.value),
              ),
            )),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF263040),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.inbox_outlined,
                color: Color(0xFF8A9BB0), size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            'No tasks yet!',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first task',
            style: GoogleFonts.poppins(
              color: const Color(0xFF8A9BB0),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF263040),
      highlightColor: const Color(0xFF2D3748),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 140,
                height: 18,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                2,
                    (_) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 160,
                    height: 120,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              4,
                  (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'See all',
            style: GoogleFonts.poppins(
              color: const Color(0xFFF5C518),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Completed Task Card (horizontal scroll) ───────────────────────────────
class _CompletedTaskCard extends StatelessWidget {
  final Task task;
  const _CompletedTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5C518),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: const Color(0xFF1C2331),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const Spacer(),
          Text(
            'Completed',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1C2331).withOpacity(0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor:
                    const Color(0xFF1C2331).withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF1C2331).withOpacity(0.7)),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '100%',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1C2331),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Animated Task Tile ────────────────────────────────────────────────────
class _AnimatedTaskTile extends StatefulWidget {
  final Task task;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;

  const _AnimatedTaskTile({
    required this.task,
    required this.index,
    required this.onDelete,
    required this.onToggle,
    this.onEdit,
  });

  @override
  State<_AnimatedTaskTile> createState() => _AnimatedTaskTileState();
}

class _AnimatedTaskTileState extends State<_AnimatedTaskTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Progress color based on index
  Color get _progressColor {
    final colors = [
      const Color(0xFFF5C518),
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFE91E63),
    ];
    return colors[widget.index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Opacity(
        opacity: _anim.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(40 * (1 - _anim.value), 0),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Slidable(
          key: ValueKey(widget.task.id),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.28,
            children: [
              SlidableAction(
                onPressed: (_) => widget.onDelete(),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline_rounded,
                label: 'Delete',
                borderRadius: BorderRadius.circular(14),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF263040),
              borderRadius: BorderRadius.circular(14),
              border: Border(
                left: BorderSide(color: _progressColor, width: 3),
              ),
            ),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: widget.onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.task.isCompleted
                          ? const Color(0xFFF5C518)
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.task.isCompleted
                            ? const Color(0xFFF5C518)
                            : const Color(0xFF8A9BB0),
                        width: 2,
                      ),
                    ),
                    child: widget.task.isCompleted
                        ? const Icon(Icons.check_rounded,
                        size: 14, color: Color(0xFF1C2331))
                        : null,
                  ),
                ),

                const SizedBox(width: 14),

                // Title + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: GoogleFonts.poppins(
                          color: widget.task.isCompleted
                              ? const Color(0xFF8A9BB0)
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: widget.task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        child: Text(widget.task.title),
                      ),
                      if (widget.task.description != null &&
                          widget.task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.task.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF8A9BB0),
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Due date
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 12, color: Color(0xFF8A9BB0)),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(widget.task.createdAt),
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF8A9BB0),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Edit button
                if (widget.onEdit != null)
                  GestureDetector(
                    onTap: widget.onEdit,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _progressColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.edit_outlined,
                          size: 16, color: _progressColor),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'Due on : ${dt.day} ${months[dt.month - 1]}';
  }
}

// ─── All Done Card ─────────────────────────────────────────────────────────
class _AllDoneCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF263040),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFFF5C518).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5C518).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: Color(0xFFF5C518), size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('All tasks completed! 🎉',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              Text('Add more tasks to stay productive',
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF8A9BB0), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Navigation ─────────────────────────────────────────────────────
class _DayTaskBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _DayTaskBottomNav(
      {required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF1C2331),
        border: Border(
          top: BorderSide(
              color: const Color(0xFF2D3748).withOpacity(0.5), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
              icon: Icons.home_rounded,
              label: 'Home',
              selected: selectedIndex == 0,
              onTap: () => onTap(0)),
          _NavItem(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Chat',
              selected: selectedIndex == 1,
              onTap: () => onTap(1)),

          // Center FAB
          GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF5C518),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF5C518).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded,
                  color: Color(0xFF1C2331), size: 28),
            ),
          ),

          _NavItem(
              icon: Icons.calendar_today_outlined,
              label: 'Calendar',
              selected: selectedIndex == 3,
              onTap: () => onTap(3)),
          _NavItem(
              icon: Icons.notifications_none_rounded,
              label: 'Alerts',
              selected: selectedIndex == 4,
              onTap: () => onTap(4)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(0xFFF5C518)
                  : const Color(0xFF8A9BB0),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: selected
                    ? const Color(0xFFF5C518)
                    : const Color(0xFF8A9BB0),
                fontSize: 10,
                fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}