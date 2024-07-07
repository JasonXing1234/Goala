import 'package:Goala/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:Goala/state/appState.dart';
import 'package:provider/provider.dart';

class BottomMenubar extends StatefulWidget {
  const BottomMenubar({
    Key? key,
  });
  @override
  _BottomMenubarState createState() => _BottomMenubarState();
}

class _BottomMenubarState extends State<BottomMenubar> {
  @override
  void initState() {
    super.initState();
  }

  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    AppState state = Provider.of<AppState>(context);

    return BottomNavigationBar(
      currentIndex: pageIndex,
      selectedItemColor: AppColor.PROGRESS_COLOR,
      unselectedItemColor: Colors.black,
      onTap: (int index) {
        // Check that we aren't reloading the same page
        if (index != pageIndex) {
          setState(() {
            state.setPageIndex = index;
            pageIndex = index;
          });
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.public),
          label: "Feed",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.public),
          label: "Feed",
        ),
      ],
    );
  }
}
