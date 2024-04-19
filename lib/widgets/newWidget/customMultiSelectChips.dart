import 'package:flutter/material.dart';

import '../../model/user.dart';
import '../../ui/theme/theme.dart';
import '../customWidgets.dart';

// Why the frick is this called "ChildWidget"?!
// TODO: Make it some useful name...

class ChildWidget extends StatefulWidget {
  final List<UserModel?> friends;
  final Function(List<UserModel?>) onSelectionChanged;
  final String buttonText;

  ChildWidget(
      {required this.friends,
      required this.onSelectionChanged,
      required this.buttonText});

  @override
  _ChildWidgetState createState() => _ChildWidgetState();
}

class _ChildWidgetState extends State<ChildWidget> {
  List<UserModel> _selectedFriends = [];

  void _showSelectFriendsDialog() async {
    final List<UserModel>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SelectFriendsDialog(
          friends: widget.friends,
          selectedFriends: _selectedFriends,
        );
      },
    );

    if (results != null) {
      setState(() => _selectedFriends = results);
      widget.onSelectionChanged(_selectedFriends);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: ElevatedButton(
            onPressed: _showSelectFriendsDialog,
            child: customTitleText(widget.buttonText),
          ),
        ),
        Center(
          child: Wrap(
            children: _selectedFriends
                .map((friend) => ChoiceChip(
                      selectedColor: AppColor.PROGRESS_COLOR,
                      label: Text(friend.displayName!),
                      selected: true,
                      onSelected: (isSelected) {
                        setState(() {
                          _selectedFriends.removeWhere((f) => f == friend);
                          widget.onSelectionChanged(_selectedFriends);
                        });
                      },
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class SelectFriendsDialog extends StatefulWidget {
  final List<UserModel?> friends;
  final List<UserModel> selectedFriends;

  SelectFriendsDialog({required this.friends, required this.selectedFriends});

  @override
  _SelectFriendsDialogState createState() => _SelectFriendsDialogState();
}

class _SelectFriendsDialogState extends State<SelectFriendsDialog> {
  List<UserModel?> _filteredFriends = [];
  List<UserModel> _selectedFriends = [];

  @override
  void initState() {
    super.initState();
    _filteredFriends = widget.friends;
    _selectedFriends = List.from(widget.selectedFriends);
  }

  void _filterFriends(String searchTerm) {
    final query = searchTerm.toLowerCase();
    setState(() {
      _filteredFriends = widget.friends.where((friend) {
        return friend!.displayName!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterFriends,
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = _filteredFriends[index];
                return CheckboxListTile(
                  title: Text(friend!.displayName!),
                  value: _selectedFriends.contains(friend),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedFriends.add(friend);
                      } else {
                        _selectedFriends
                            .removeWhere((selected) => selected == friend);
                      }
                    });
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(_selectedFriends);
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }
}

class Friend {
  final String id;
  final String name;

  Friend({required this.id, required this.name});
}
