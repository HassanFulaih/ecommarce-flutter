import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final String title;
  final String hint;
  final Function(String?) onChanged;
  final List<String> itemsList;

  const CustomDropdown(this.itemsList, this.onChanged, this.hint,
      {Key? key, required this.title})
      : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: const TextStyle(color: Colors.white)),
          Container(
            padding: const EdgeInsets.only(right: 14),
            margin: const EdgeInsets.only(top: 8, left: 8),
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    autofocus: false,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      // enabledBorder: UnderlineInputBorder(
                      //   borderSide: BorderSide(
                      //     color: Colors.white,
                      //     width: 0,
                      //   ),
                      // ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!widget.title.contains('المحافظة'))
                  Row(
                    children: [
                      DropdownButton(
                        dropdownColor: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(10),
                        items: widget.itemsList
                            .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                alignment: AlignmentDirectional.centerEnd,
                                value: value,
                                child: Text(
                                  value,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.grey),
                        iconSize: 32,
                        elevation: 4,
                        underline: Container(height: 0),
                        //style: subTitleStyle,
                        onChanged: widget.onChanged,
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
