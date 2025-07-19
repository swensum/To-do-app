import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:todo_list/providers/category_provider.dart';

import 'package:todo_list/providers/task_provider.dart';
import 'package:todo_list/utils/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DateTime _currentWeekStart = _findFirstDayOfWeek(DateTime.now());
  String _timeFilter = 'in 7 days'; // Default filter

  static DateTime _findFirstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  String _formatWeekRange(DateTime startDate) {
    final endDate = startDate.add(const Duration(days: 6));
    return '${startDate.month}/${startDate.day}-${endDate.month}/${endDate.day}';
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  List<FlSpot> _getWeeklySpots(TaskProvider taskProvider) {
    List<FlSpot> spots = [];

    for (int i = 0; i < 7; i++) {
      final currentDay = _currentWeekStart.add(Duration(days: i));
      final dayTasks = taskProvider.tasks.where((task) {
        return task.dateTime.year == currentDay.year &&
            task.dateTime.month == currentDay.month &&
            task.dateTime.day == currentDay.day;
      }).toList();

      final completedTasks = dayTasks.where((task) => task.isCompleted).length;
      spots.add(FlSpot(i.toDouble(), completedTasks.toDouble()));
    }

    return spots;
  }

  String _getDayAbbreviation(int weekday) {
    const abbreviations = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return abbreviations[weekday - 1];
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  DateTime _getFirstDayOfWeek(DateTime date) {
    return date
        .subtract(Duration(days: date.weekday % 7)); // Sunday as first day
  }

  DateTime _getLastDayOfWeek(DateTime date) {
    return _getFirstDayOfWeek(date).add(const Duration(days: 6));
  }

  DateTime _getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  DateTime _getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  Map<String, int> _getCategoryDistribution(TaskProvider taskProvider) {
    DateTime startDate;
    DateTime endDate;

    switch (_timeFilter) {
      case 'in 7 days':
        // Current week (Sunday to Saturday)
        startDate = _getFirstDayOfWeek(DateTime.now());
        endDate = _getLastDayOfWeek(DateTime.now());
        break;
      case 'in 30 days':
        // Current month (1st to last day)
        startDate = _getFirstDayOfMonth(DateTime.now());
        endDate = _getLastDayOfMonth(DateTime.now());
        break;
      case 'all':
      default:
        startDate = DateTime(1970);
        endDate = DateTime(2100);
        break;
    }

    final pendingTasks = taskProvider.activeTasks.where((task) {
      return !task.dateTime.isBefore(startDate) &&
          !task.dateTime.isAfter(endDate);
    }).toList();

    final categoryCounts = <String, int>{};

    for (var task in pendingTasks) {
      final category = task.category.isEmpty ? 'No Category' : task.category;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    return categoryCounts;
  }

  String _getFilterSubtitle() {
    switch (_timeFilter) {
      case 'in 7 days':
        final start = _getFirstDayOfWeek(DateTime.now());
        final end = _getLastDayOfWeek(DateTime.now());
        return '${start.day}/${start.month} - ${end.day}/${end.month}';
      case 'in 30 days':
        final start = _getFirstDayOfMonth(DateTime.now());
        final end = _getLastDayOfMonth(DateTime.now());
        return '${start.day}/${start.month} - ${end.day}/${end.month}';
      case 'all':
      default:
        return 'All time';
    }
  }

  Color _getCategoryColor(String category) {
    // Define a consistent color for each category
    const colors = {
      'No Category': Colors.grey,
      'Work': Colors.blue,
      'Personal': Colors.green,
      'Shopping': Colors.orange,
      'Others': Colors.purple,
    };

    // If we have a predefined color, use it
    if (colors.containsKey(category)) {
      return colors[category]!;
    }

    // For custom categories, generate a color based on the hash code
    final hue = (category.hashCode % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final spots = _getWeeklySpots(taskProvider);
        // Set maxY to 8 to always show up to 8 tasks
        final maxY = 8.0;

        // Get tasks for the next 7 days
        final now = DateTime.now();
        final nextWeek = now.add(const Duration(days: 7));
        final upcomingTasks = taskProvider.tasks.where((task) {
          return !task.isCompleted &&
              task.dateTime.isAfter(now) &&
              task.dateTime.isBefore(nextWeek);
        }).toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Tasks Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),

                // Stats Cards Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                      context,
                      icon: Icons.check_circle,
                      color: Theme.of(context).secondaryHeaderColor,
                      title: 'Completed',
                      value: taskProvider.completedTasks.length,
                    ),
                    _buildStatCard(
                      context,
                      icon: Icons.pending_actions,
                      color: AppTheme.lightTheme.primaryColor,
                      title: 'Pending',
                      value: taskProvider.activeTasks.length,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Weekly Completion Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.boxColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with week navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Completion of Daily Tasks',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.titleLarge?.color,
                                ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon:  FaIcon(
                                  FontAwesomeIcons.caretLeft,
                                  size: 12,
                                  color: Theme.of(context).textTheme.titleLarge?.color,
                                ),
                                onPressed: _previousWeek,
                                splashRadius: 20,
                              ),
                              Text(
                                _formatWeekRange(_currentWeekStart),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.titleLarge?.color,
                                    ),
                              ),
                              IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.caretRight,
                                  size: 12,
                                  color: Theme.of(context).textTheme.titleLarge?.color,
                                ),
                                onPressed: _nextWeek,
                                splashRadius: 20,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                     
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            maxY: maxY,
                            minY: 0,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: Theme.of(context).textTheme.titleLarge?.color,
                                getTooltipItem:
                                    (group, groupIndex, rod, rodIndex) {
                                  final day = _getDayAbbreviation(
                                      _currentWeekStart
                                          .add(Duration(days: group.x.toInt()))
                                          .weekday);
                                  return BarTooltipItem(
                                    '$day\n${rod.toY.toInt()} tasks',
                                  TextStyle(color: Theme.of(context).scaffoldBackgroundColor,),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final day = _getDayAbbreviation(
                                        _currentWeekStart
                                            .add(Duration(days: value.toInt()))
                                            .weekday);
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        day,
                                        style: TextStyle(
                                          color: Theme.of(context).hintColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  },
                                  reservedSize: 30,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval:
                                      2, // This ensures labels at 0, 2, 4, 6, 8
                                  getTitlesWidget: (value, meta) {
                                    // Only show labels for 0, 2, 4, 6, 8
                                    if ([0, 2, 4, 6, 8]
                                        .contains(value.toInt())) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                            color: Theme.of(context).hintColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                  reservedSize:
                                      28, // Adjust this for perfect alignment
                                ),
                              ),
                              rightTitles: AxisTitles(),
                              topTitles: AxisTitles(),
                            ),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                left: BorderSide(
                                    color: AppTheme.namedGrey,
                                    width: 1),
                                bottom: BorderSide(
                                    color: AppTheme.namedGrey,
                                    width: 1),
                                top: BorderSide.none,
                                right: BorderSide.none,
                              ),
                            ),
                            barGroups: spots.asMap().entries.map((entry) {
                              final index = entry.key;
                              final spot = entry.value;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: spot.y,
                                    color:  Theme.of(context).cardColor,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: maxY,
                                      color: AppTheme.boxColor2,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Upcoming Tasks Container - Now expands with content
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.boxColor2,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tasks in next 7 days',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.titleLarge?.color,
                                ),
                      ),
                      const SizedBox(height: 0),
                      if (upcomingTasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'No upcoming tasks in the next 7 days',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
                        )
                      else
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: upcomingTasks.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final task = upcomingTasks[index];
                            return Row(
                              children: [
                                // Task Icon
                                FaIcon(
                                  FontAwesomeIcons.tasks,
                                  size: 16,
                                  color: Theme.of(context).cardColor,
                                ),
                                const SizedBox(width: 12),

                                // Task Name
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Always show date, only show time if it's set
                                Text(
                                  _formatDate(task.dateTime) +
                                      (task.dateTime.hour != 0 ||
                                              task.dateTime.minute != 0
                                          ? ' ${_formatTime(task.dateTime)}'
                                          : ''),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context).hintColor,
                                        fontSize: 12,
                                      ),
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

//
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.boxColor2,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with dropdown filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pending Tasks by Category',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color:  Theme.of(context).textTheme.titleLarge?.color,
                                    ),
                              ),
                              Text(
                                _getFilterSubtitle(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.titleColor,
                                      fontSize: 10,
                                    ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                           
                            child: DropdownButton<String>(
                              value: _timeFilter,
                               isDense: true,
                              underline:const SizedBox(), 
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              iconEnabledColor: Theme.of(context).textTheme.titleLarge?.color,
                              dropdownColor:  Theme.of(context).scaffoldBackgroundColor,
                              
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).textTheme.titleLarge?.color,
                                    fontSize: 12,
                                  ),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _timeFilter = newValue!;
                                });
                              },
                              items: <String>[
                                'in 7 days',
                                'in 30 days',
                                'all'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      if (taskProvider.activeTasks.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'No pending tasks',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 160,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Consumer<CategoryProvider>(
                              builder: (context, categoryProvider, child) {
                                final categoryData =
                                    _getCategoryDistribution(taskProvider);
                                final visibleCategories =
                                    categoryProvider.visibleCategories;

                                // Prepare pie chart sections
                                final sections =
                                    visibleCategories.where((category) {
                                  return categoryData.containsKey(category) &&
                                      categoryData[category]! > 0;
                                }).map((category) {
                                  final value =
                                      categoryData[category]!.toDouble();
                                  final color = _getCategoryColor(category);

                                  return PieChartSectionData(
                                    value: value,
                                    color: color,
                                    showTitle: false,
                                    radius: 30,
                                  );
                                }).toList();

                                return Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: PieChart(
                                        PieChartData(
                                          sections: sections,
                                          centerSpaceRadius: 30,
                                          sectionsSpace: 2,
                                          startDegreeOffset: -90,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 30),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: visibleCategories
                                              .where((category) {
                                            return categoryData
                                                    .containsKey(category) &&
                                                categoryData[category]! > 0;
                                          }).map((category) {
                                            final count =
                                                categoryData[category]!;
                                            final color =
                                                _getCategoryColor(category);

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 3.0),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 13,
                                                    height: 13,
                                                    decoration: BoxDecoration(
                                                      color: color,
                                                      shape: BoxShape.rectangle,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    category,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    child: Text(
                                                      '$count',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: Theme.of(context).cardColor,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required int value,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
