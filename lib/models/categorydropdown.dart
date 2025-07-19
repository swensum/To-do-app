import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/providers/category_provider.dart';
import 'package:todo_list/utils/theme.dart';

class CategoryDropdown extends StatefulWidget {
  final ValueChanged<String>? onCategorySelected;
  final String? initialValue;

  const CategoryDropdown({
    super.key,
    this.onCategorySelected,
    this.initialValue,
  });

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialValue ?? 'No Category';
  }

  @override
  Widget build(BuildContext context) {
   final categoryList = Provider.of<CategoryProvider>(context).visibleCategories;

    return IntrinsicWidth(
      child: DropdownButtonFormField<String>(
        isExpanded: false,
        value: selectedCategory,
        items: [
          ...categoryList.map((category) => DropdownMenuItem(
                value: category,
                child: Text(
                  category,
                  style: TextStyle(
                    color: selectedCategory == category
                        ?  Theme.of(context).cardColor
                        : Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: selectedCategory == category
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis, 
                ),
              )),
           DropdownMenuItem(
            value: 'create_new_category',
            child: Row(
              children: [
                Text(
                  '➕ ',
                  style: TextStyle(
                    // Stronger green
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Create New',
                  style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
     onChanged: (value) {
  if (value == 'create_new_category') {
    _showCreateCategoryDialog(); 
   
  } else {
    setState(() {
      selectedCategory = value; 
    });
    if (widget.onCategorySelected != null && value != null) {
      widget.onCategorySelected!(value); 
    }
  }
},


        decoration: const InputDecoration(
          filled: true,
          fillColor: AppTheme.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
              horizontal: 12, vertical: 14), 
          isDense: true, 
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Please select a category' : null,
      ),
    );
  }

  void _showCreateCategoryDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 300, 
            maxWidth: 350, 
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
                const Text(
                  "Create new category",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 24),
                Stack(
                  children: [
                    TextField(
                      controller: controller,
                      maxLength: 50,
                      maxLines: 1,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "Input here.",
                        hintStyle: TextStyle(color: Theme.of(context).primaryIconTheme.color,),
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
                          color:Theme.of(context).primaryIconTheme.color,
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
                          Provider.of<CategoryProvider>(context, listen: false)
                              .addCategory(newCategory);
                          setState(() {
                            selectedCategory = newCategory;
                          });
                          if (widget.onCategorySelected != null) {
                            widget.onCategorySelected!(newCategory);
                          }
                        }
                        Navigator.of(context).pop();
                      },
                      child:  Text(
                        "DONE",
                        style: TextStyle(
                            color: Theme.of(context).cardColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
