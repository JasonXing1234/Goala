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
  int tempInt = 0;
  @override
  void initState() {
    super.initState();
  }

  Widget _iconRow() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).bottomAppBarTheme.color,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -.1),
            blurRadius: 0,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
                width: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: tempInt == 0 ? AppColor.PROGRESS_COLOR : null, // Change color as needed
                ),
                child: _icon(Icons.person, 0),
              ),
          Container(
            width: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: tempInt == 1 ? AppColor.PROGRESS_COLOR : null, // Change color as needed
            ),
            child: _icon(Icons.public, 1),
          ),
          Container(
            width: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: tempInt == 2 ? AppColor.PROGRESS_COLOR : null, // Change color as needed
            ),
            child: _icon(Icons.search, 2),
          ),
          // _icon(null, 3, icon: Icons.message),
        ],
      ),
    );
  }

  Widget _icon(IconData iconData, int index) {
    AppState state = Provider.of<AppState>(context);
    return IconButton(
        icon: Icon(iconData, color: Theme.of(context).primaryColor),
        onPressed: () {
          setState(() {
            state.setPageIndex = index;
            tempInt = index;
          });
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _iconRow();
  }
}
