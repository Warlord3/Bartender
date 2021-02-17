import 'package:flutter/material.dart';

class MYBottomNavigationBar extends StatefulWidget {
  final List<BarItem> barItems;
  final Duration animationDuration;
  final Function onBarTap;

  MYBottomNavigationBar(
      {this.barItems,
      this.animationDuration = const Duration(microseconds: 200),
      this.onBarTap});
  @override
  _MYBottomNavigationBarState createState() => _MYBottomNavigationBarState();
}

class _MYBottomNavigationBarState extends State<MYBottomNavigationBar>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 10.0,
          top: 10.0,
          left: 16.0,
          right: 16.0,
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          overflow: Overflow.clip,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: _buildBarItems(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBarItems() {
    List<Widget> _barItems = List();
    for (int i = 0; i < widget.barItems.length; i++) {
      BarItem item = widget.barItems[i];
      bool isSelected = _selectedIndex == i;
      _barItems.add(InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          setState(() {
            _selectedIndex = i;
            widget.onBarTap(_selectedIndex);
          });
        },
        child: AnimatedContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          duration: widget.animationDuration,
          decoration: BoxDecoration(
              color: isSelected
                  ? item.color.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                item.icon,
                color: isSelected ? item.color : Colors.black,
                size: 15,
              ),
              SizedBox(
                width: 10.0,
              ),
              AnimatedSize(
                duration: widget.animationDuration,
                curve: Curves.easeInOut,
                vsync: this,
                child: Text(
                  isSelected ? item.text : "",
                  style: TextStyle(
                      color: item.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.0),
                ),
              )
            ],
          ),
        ),
      ));
    }
    return _barItems;
  }
}

class BarItem {
  String text;
  IconData icon;
  Color color;
  BarItem({this.text, this.color, this.icon});
}
