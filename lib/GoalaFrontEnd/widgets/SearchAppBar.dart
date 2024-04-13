import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar(
      {Key? key,
        this.title,
        this.scaffoldKey,
        this.icon,
        this.onActionPressed,
        this.textController,
        this.isBackButton = true,
        this.isCrossButton = false,
        this.submitButtonText,
        this.isSubmitDisable = true,
        this.isBottomLine = true,
        this.onSearchChanged})
      : super(key: key);

  final Size appBarHeight = const Size.fromHeight(56.0);
  final IconData? icon;
  final bool isBackButton;
  final bool isBottomLine;
  final bool isCrossButton;
  final bool isSubmitDisable;
  final Function? onActionPressed;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String? submitButtonText;
  final TextEditingController? textController;
  final Widget? title;
  final ValueChanged<String>? onSearchChanged;

  @override
  Size get preferredSize => appBarHeight;

  Widget _searchField() {
    return Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: TextField(
          onChanged: onSearchChanged,
          controller: textController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(width: 1, style: BorderStyle.none),
              borderRadius: BorderRadius.all(
                Radius.circular(25.0),
              ),
            ),
            hintText: 'Search..',
            fillColor: Colors.white,
            filled: true,
            focusColor: Colors.black,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            title: title ?? _searchField(),
            bottom: PreferredSize(
              child: Container(
                color: isBottomLine
                    ? Colors.grey.shade200
                    : Theme.of(context).scaffoldBackgroundColor,
                height: 1.0,
              ),
              preferredSize: const Size.fromHeight(0.0),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 800,
              child: Center(
                child: Text("Blah Blah Blah"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
