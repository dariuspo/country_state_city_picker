library country_state_city_picker;

import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'model/select_status_model.dart' as StatusModel;

class SelectState extends StatefulWidget {
  final String countrySelected;
  final String stateSelected;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onStateChanged;
  final ValueChanged<String> onCityChanged;
  final TextStyle style;
  final Color dropdownColor;

  const SelectState(
      {Key key,
      this.onCountryChanged,
      this.countrySelected,
      this.stateSelected,
      this.onStateChanged,
      this.onCityChanged,
      this.style,
      this.dropdownColor})
      : super(key: key);

  @override
  _SelectStateState createState() => _SelectStateState();
}

class _SelectStateState extends State<SelectState> {
  List<String> _cities = ["Choose City"];
  List<String> _country = ["Choose Country"];
  String _selectedCity = "Choose City";
  String _selectedCountry = "Choose Country";
  String _selectedState = "Choose State";
  List<String> _states = ["Choose State"];
  var responses;

  @override
  void initState() {
    getCounty();
    super.initState();
  }

  Future getResponse() async {
    var res = await rootBundle.loadString(
        'packages/country_state_city_picker/lib/assets/country.json');
    return jsonDecode(res);
  }

  Future getCounty() async {
    var countryres = await getResponse() as List;
    countryres.forEach((data) {
      var model = StatusModel.StatusModel();
      model.name = data['name'];
      model.emoji = data['emoji'];
      if (!mounted) return;
      setState(() {
        _country.add(model.emoji + "    " + model.name);
      });
    });
    if(widget.countrySelected!=null){
      _selectedCountry = widget.countrySelected;
    }
    if(widget.stateSelected!=null){
      await getState();
      _selectedState = widget.stateSelected;
    }
    return _country;
  }

  Future getState() async {
    var response = await getResponse();
    var takestate = response
        .map((map) => StatusModel.StatusModel.fromJson(map))
        .where((item) => item.emoji + "    " + item.name == _selectedCountry)
        .map((item) => item.state)
        .toList();
    var states = takestate as List;
    states.forEach((f) {
      if (!mounted) return;
      setState(() {
        var name = f.map((item) => item.name).toList();
        for (var statename in name) {
          print(statename.toString());

          _states.add(statename.toString());
        }
      });
    });

    return _states;
  }

  void _onSelectedCountry(String value) {
    if (!mounted) return;
    setState(() {
      _selectedState = "Choose State";
      _states = ["Choose State"];
      _selectedCountry = value;
      this.widget.onCountryChanged(value);
      getState();
    });
  }

  void _onSelectedState(String value) {
    if (!mounted) return;
    setState(() {
      _selectedCity = "Choose City";
      _cities = ["Choose City"];
      _selectedState = value;
      this.widget.onStateChanged(value);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 10.0,
        ),
        Align(alignment:Alignment.centerLeft,child: Text('Country')),
        DropdownButton<String>(
          dropdownColor: widget.dropdownColor,
          isExpanded: true,
          items: _country.map((String dropDownStringItem) {
            return DropdownMenuItem<String>(
              value: dropDownStringItem,
              child: Row(
                children: [
                  Text(
                    dropDownStringItem,
                    style: widget.style,
                  )
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => _onSelectedCountry(value),
          value: _selectedCountry,
        ),
        SizedBox(
          height: 10.0,
        ),
        Align(alignment:Alignment.centerLeft,child: Text('States')),
        DropdownButton<String>(
          dropdownColor: widget.dropdownColor,
          isExpanded: true,
          focusColor: Colors.black,
          items: _states.map((String dropDownStringItem) {
            return DropdownMenuItem<String>(
              value: dropDownStringItem,
              child: Text(dropDownStringItem, style: widget.style),
            );
          }).toList(),
          onChanged: (value) => _onSelectedState(value),
          value: _selectedState,
        ),
        SizedBox(
          height: 10.0,
        ),
      ],
    );
  }
}
