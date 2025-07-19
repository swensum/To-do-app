import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/models/managecategories.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/screens/completedtask.dart';
import 'package:todo_list/utils/theme.dart';
import 'package:todo_list/widgets/task_list.dart';
import 'package:todo_list/providers/task_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todo_list/providers/category_provider.dart';

enum SortOption {
  nameAscending,
  nameDescending,
  dueDateAscending,
  dueDateDescending,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bool _showActiveTasks = true;
  bool _showCompletedTasks = true;
  String _selectedCategory = 'All';
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _currentSortOption = SortOption.nameAscending;
  bool _showTodayTasks = true;
  bool _showFutureTasks = true;
  bool _showPreviousTasks = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
@override
void initState() {
  super.initState();
  Future.microtask(
      () => Provider.of<TaskProvider>(context, listen: false).loadTasks());
}

  List<Task> _sortTasks(List<Task> tasks) {
    switch (_currentSortOption) {
      case SortOption.nameAscending:
        tasks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.nameDescending:
        tasks.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.dueDateAscending:
        tasks.sort((a, b) {
          // ignore: unnecessary_null_comparison
          if (a.dateTime == null && b.dateTime == null) return 0;
          return a.dateTime.compareTo(b.dateTime);
        });
        break;
      case SortOption.dueDateDescending:
        tasks.sort((a, b) {
          // ignore: unnecessary_null_comparison
          if (a.dateTime == null && b.dateTime == null) return 0;
          return b.dateTime.compareTo(a.dateTime);
        });
        break;
    }
    return tasks;
  }

  List<Task> _filterTasks(List<Task> tasks, String category) {
    List<Task> filtered = category == 'All'
        ? tasks
        : tasks.where((task) => task.category == category).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((task) =>
              task.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return _sortTasks(filtered);
  }

  void _showSortOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            'Sort By',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<SortOption>(
                title: Text(
                  'Name (A-Z)',
                  style: TextStyle(
                    color: _currentSortOption == SortOption.nameAscending
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).iconTheme.color,
                  ),
                ),
                value: SortOption.nameAscending,
                groupValue: _currentSortOption,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  setState(() {
                    _currentSortOption = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<SortOption>(
                title: Text(
                  'Name (Z-A)',
                  style: TextStyle(
                    color: _currentSortOption == SortOption.nameDescending
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).iconTheme.color,
                  ),
                ),
                value: SortOption.nameDescending,
                groupValue: _currentSortOption,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  setState(() {
                    _currentSortOption = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<SortOption>(
                title: Text(
                  'Due Date (Earliest first)',
                  style: TextStyle(
                    color: _currentSortOption == SortOption.dueDateAscending
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).iconTheme.color,
                  ),
                ),
                value: SortOption.dueDateAscending,
                groupValue: _currentSortOption,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  setState(() {
                    _currentSortOption = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<SortOption>(
                title: Text(
                  'Due Date (Latest first)',
                  style: TextStyle(
                    color: _currentSortOption == SortOption.dueDateDescending
                        ? Theme.of(context).primaryColor
                        :Theme.of(context).iconTheme.color,
                  ),
                ),
                value: SortOption.dueDateDescending,
                groupValue: _currentSortOption,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  setState(() {
                    _currentSortOption = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, List<Task>> _categorizeTasksByDate(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    Map<String, List<Task>> categorized = {
      'Today': [],
      'Previous': [],
      'Future': [],
    };

    for (var task in tasks) {
      final taskDate =
          DateTime(task.dateTime.year, task.dateTime.month, task.dateTime.day);

      if (taskDate.isBefore(today)) {
        categorized['Previous']!.add(task);
      } else if (taskDate.isAtSameMomentAs(today)) {
        categorized['Today']!.add(task);
      } else {
        categorized['Future']!.add(task);
      }
    }

    return categorized;
  }

  @override
  Widget build(BuildContext context) {
    
    final provider = Provider.of<TaskProvider>(context);
    final categoryProvider =
        Provider.of<CategoryProvider>(context).visibleCategories;

    final List<String> categories = [
      'All',
      ...categoryProvider.where((c) => c != 'No Category')
    ];

    final activeTasks = _filterTasks(provider.activeTasks, _selectedCategory);
    final completedTasks =
        _filterTasks(provider.completedTasks, _selectedCategory);

    final activeTasksByDate = _categorizeTasksByDate(activeTasks);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
        toolbarHeight: kToolbarHeight + 30,
        actions: [
          if (_showSearchBar)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showSearchBar = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.more_vert,
                      color: Theme.of(context).primaryColor),
                  onPressed: () async {
                    final RenderBox button =
                        context.findRenderObject() as RenderBox;
                    final RenderBox overlay = Overlay.of(context)
                        .context
                        .findRenderObject() as RenderBox;

                    final Offset position =
                        button.localToGlobal(Offset.zero, ancestor: overlay);
                    final RelativeRect positionRect = RelativeRect.fromLTRB(
                      position.dx,
                      position.dy + 48,
                      position.dx + 48,
                      0,
                    );

                    await showMenu(
                      context: context,
                      position: positionRect,
                      constraints: const BoxConstraints(maxWidth: 150),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      items: [
                        PopupMenuItem<String>(
                          value: 'manage_categories',
                          height: 36,
                          child: ListTile(
                            title: const Text('Manage Categories'),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'search',
                          child: ListTile(
                            title: const Text('Search'),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'sort_by',
                          child: ListTile(
                            title: const Text('Sort By'),
                          ),
                        ),
                      ],
                    ).then((selected) {
                      if (selected == 'manage_categories') {
                        final allTasks = [
                          ...provider.activeTasks,
                          ...provider.completedTasks
                        ];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ManageCategoriesPage(tasks: allTasks),
                          ),
                        );
                      } else if (selected == 'search') {
                        setState(() {
                          _showSearchBar = true;
                        });
                      } else if (selected == 'sort_by') {
                        _showSortOptionsDialog();
                      }
                    });
                  },
                ),
              ),
            ),
        ],
        flexibleSpace: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 30, 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_showSearchBar)
                Container(
                  margin: const EdgeInsets.only(left: 25, right: 0, bottom: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        hintStyle: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.cancel,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _showSearchBar = false;
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 7.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: _selectedCategory == category
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).primaryColorLight,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: _selectedCategory == category
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/back.jpg"), 
       
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.2), // Adjust opacity as needed
                BlendMode.dstATop,
              ),
            ),
          ),
          child: activeTasks.isEmpty && completedTasks.isEmpty
              ?  Center(
                  child: Text(
                    'No tasks available. Tap + to add a task.',
                    style: TextStyle(fontSize: 16,color: Theme.of(context).primaryIconTheme.color,),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (activeTasks.isNotEmpty || completedTasks.isNotEmpty) ...[
                        // Active Tasks Sections
                        if (_showActiveTasks) ...[
                          if (activeTasksByDate['Previous']!.isNotEmpty) ...[
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showPreviousTasks = !_showPreviousTasks;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(padding: EdgeInsets.only(left: 15)),
                                    Text(
                                      'Previous',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.namedGrey,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    FaIcon(
                                      _showPreviousTasks
                                          ? FontAwesomeIcons.caretUp
                                          : FontAwesomeIcons.caretDown,
                                      size: 16,
                                      color: AppTheme.namedGrey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_showPreviousTasks)
                              TaskList(tasks: activeTasksByDate['Previous']!),
                          ],
                          // Today's Tasks
                          if (activeTasksByDate['Today']!.isNotEmpty) ...[
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showTodayTasks = !_showTodayTasks;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(padding: EdgeInsets.only(left: 15)),
                                    Text(
                                      'Today',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    FaIcon(
                                      _showTodayTasks
                                          ? FontAwesomeIcons.caretUp
                                          : FontAwesomeIcons.caretDown,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_showTodayTasks)
                              TaskList(tasks: activeTasksByDate['Today']!),
                          ],
          
                          // Future Tasks
                          if (activeTasksByDate['Future']!.isNotEmpty) ...[
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showFutureTasks = !_showFutureTasks;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(padding: EdgeInsets.only(left: 15)),
                                    Text(
                                      'Future',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:AppTheme.futureColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    FaIcon(
                                      _showFutureTasks
                                          ? FontAwesomeIcons.caretUp
                                          : FontAwesomeIcons.caretDown,
                                      size: 16,
                                      color: AppTheme.futureColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_showFutureTasks)
                              TaskList(tasks: activeTasksByDate['Future']!),
                          ],
          
                          // Previous Tasks
                        ],
          
                        // Completed Tasks Section (all combined)
                        // Completed Tasks Section (all combined)
                        if (completedTasks.isNotEmpty) ...[
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showCompletedTasks = !_showCompletedTasks;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(padding: EdgeInsets.only(left: 15)),
                                  Text(
                                    'Completed Tasks',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:  Theme.of(context).secondaryHeaderColor,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FaIcon(
                                    _showCompletedTasks
                                        ? FontAwesomeIcons.caretUp
                                        : FontAwesomeIcons.caretDown,
                                    size: 16,
                                    color:  Theme.of(context).secondaryHeaderColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_showCompletedTasks) ...[
                            TaskList(tasks: completedTasks),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CompletedTasksPage(),
                                    ),
                                  );
                                },
                                child: Center(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 60, 0, 60),
                                    child: Text(
                                      'Check all completed tasks',
                                      style: TextStyle(
                                        color: AppTheme.namedGrey,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ],
                  ),
                ),
        ),
      ),
     
     
    );
  }
}
