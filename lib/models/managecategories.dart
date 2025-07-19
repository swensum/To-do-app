import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/models/task_model.dart';
import 'package:todo_list/providers/category_provider.dart';
import 'package:todo_list/utils/theme.dart';

class ManageCategoriesPage extends StatefulWidget {
  final List<Task> tasks;

  const ManageCategoriesPage({super.key, required this.tasks});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  String? selectedCategory;
  late List<String> localCategories;

  @override
  void initState() {
    super.initState();
    final originalCategories =
        Provider.of<CategoryProvider>(context, listen: false).categories;
    localCategories =
        originalCategories.where((c) => c != 'No Category').toList();
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = localCategories.removeAt(oldIndex);
      localCategories.insert(newIndex, item);
    });

    // Optional: Update order in the provider if you manage persistent order
    Provider.of<CategoryProvider>(context, listen: false)
        .updateCategoryOrder(localCategories);
  }

  void _showCreateCategoryDialog({String? categoryToEdit}) {
    final TextEditingController controller =
        TextEditingController(text: categoryToEdit);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 350),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: StatefulBuilder(
              builder: (context, setInnerState) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryToEdit == null
                        ? "Create new category"
                        : "Edit category",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Stack(
                    children: [
                      TextField(
                        controller: controller,
                        maxLength: 50,
                        maxLines: 1,
                        onChanged: (_) => setInnerState(() {}),
                        decoration: InputDecoration(
                          hintText: "Input here.",
                          hintStyle: TextStyle(
                            color: Theme.of(context).primaryIconTheme.color,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          isCollapsed: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(16, 12, 50, 50),
                          counterText: '',
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 6,
                        child: Text(
                          '${controller.text.length}/50',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryIconTheme.color,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(
                              color: AppTheme.dimmedCardColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final newCategory = controller.text.trim();
                          if (newCategory.isNotEmpty) {
                            if (categoryToEdit == null) {
                              // Add new category
                              Provider.of<CategoryProvider>(context,
                                      listen: false)
                                  .addCategory(newCategory);
                              setState(() {
                                localCategories.add(newCategory);
                              });
                            } else {
                              // Edit existing category
                              Provider.of<CategoryProvider>(context,
                                      listen: false)
                                  .editCategory(categoryToEdit, newCategory);
                              setState(() {
                                final index =
                                    localCategories.indexOf(categoryToEdit);
                                if (index != -1) {
                                  localCategories[index] = newCategory;
                                }
                              });
                            }
                            setState(() {
                              selectedCategory = newCategory;
                            });
                          }
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "DONE",
                          style: TextStyle(
                              color: Theme.of(context).cardColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categoryCounts = {
      for (var category in localCategories) category: 0,
    };

    for (var task in widget.tasks) {
      final taskCategory = task.category;
      if (categoryCounts.containsKey(taskCategory)) {
        categoryCounts[taskCategory] = categoryCounts[taskCategory]! + 1;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Manage Categories'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: AppTheme.barColor,
            child: Center(
              child: Text(
                'Categories Display on Homepage',
                style: TextStyle(
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ReorderableListView(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // prevent conflict
                onReorder: _onReorder,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    elevation: 0,
                    color: Colors.transparent,
                    child: child,
                  );
                },
                children: [
                  for (final category in localCategories)
                    KeyedSubtree(
                      key: ValueKey(category),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 12,
                                color: Theme.of(context).cardColor,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  category,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (categoryProvider.isCategoryHidden(category))
                                const Padding(
                                  padding: EdgeInsets.only(left: 6.0),
                                  child: Icon(Icons.visibility_off,
                                      size: 18, color: AppTheme.namedGrey),
                                ),
                            ],
                          ),
                        ),
                        trailing: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 60, // Fixed width
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${categoryCounts[category] ?? 0}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                offset: const Offset(0, 40),
                                constraints: const BoxConstraints(maxWidth: 90),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showCreateCategoryDialog(
                                        categoryToEdit: category);
                                  } else if (value == 'delete') {
                                    final hasTasks =
                                        (categoryCounts[category] ?? 0) > 0;
                                    if (hasTasks) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Cannot delete "$category" because it has tasks.')),
                                      );
                                    } else {
                                      categoryProvider.removeCategory(category);
                                      setState(() {
                                        localCategories.remove(category);
                                      });
                                    }
                                  } else if (value == 'hide') {
                                    categoryProvider.hideCategory(category);
                                  } else if (value == 'show') {
                                    categoryProvider.showCategory(category);
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem(
                                      value: 'edit', child: Text('Edit')),
                                  PopupMenuItem(
                                    value: categoryProvider
                                                .isCategoryHidden(category)
                                        ? 'show'
                                        : 'hide',
                                    child: Text(categoryProvider
                                                .isCategoryHidden(category)
                                        ? 'Show'
                                        : 'Hide'),
                                  ),
                                  const PopupMenuItem(
                                      value: 'delete', child: Text('Delete')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),

            
              InkWell(
                onTap: () => _showCreateCategoryDialog(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Text('➕ ', style: TextStyle(fontSize: 16)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Create new',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).secondaryHeaderColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Text(
                  'Long press and drag to reorder',
                  style: TextStyle(
                    color: AppTheme.namedGrey,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
