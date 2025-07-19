import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:todo_list/utils/theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        border: Border(
          top: BorderSide(color: const Color.fromARGB(159, 216, 224, 226), width: 1),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          currentIndex: currentIndex,
          onTap: onTap,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 20,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: AppTheme.namedGrey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: FaIcon(FontAwesomeIcons.listCheck),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: FaIcon(FontAwesomeIcons.solidSquareCheck),
              ),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: FaIcon(FontAwesomeIcons.calendarDays),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: FaIcon(FontAwesomeIcons.solidCalendarDays),
              ),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: FaIcon(FontAwesomeIcons.user),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: FaIcon(FontAwesomeIcons.solidUser),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}