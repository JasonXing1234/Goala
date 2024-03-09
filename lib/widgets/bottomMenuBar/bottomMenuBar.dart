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
          _icon(Icons.person, 0),
          _icon(Icons.public, 1),
          _icon(Icons.search, 2),
          // _icon(null, 3, icon: Icons.message),
        ],
      ),
    );
  }

  Widget _icon(IconData iconData, int index) {
    AppState state = Provider.of<AppState>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: IconButton(
        icon: Icon(iconData, color: Theme.of(context).primaryColor),
        onPressed: () {
          setState(() {
            state.setPageIndex = index;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _iconRow();
  }
}
