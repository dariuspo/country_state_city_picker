library country_state_city_picker;

import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'model/select_status_model.dart' as locationModel;

class SelectState extends StatefulWidget {
  final int countrySelectedId;
  final int stateSelectedId;
  final ValueChanged<locationModel.Country> onCountryChanged;
  final ValueChanged<locationModel.State> onStateChanged;
  final TextStyle style;
  final Color dropdownColor;

  const SelectState(
      {Key key,
      this.onCountryChanged,
      this.countrySelectedId,
      this.stateSelectedId,
      this.onStateChanged,
      this.style,
      this.dropdownColor})
      : super(key: key);

  @override
  _SelectStateState createState() => _SelectStateState();
}

class _SelectStateState extends State<SelectState> {
  locationModel.Country _selectedCountry;
  locationModel.State _selectedState;
  List<locationModel.Country> _countries = [];
  List<locationModel.State> _states = [];
  var responses;

  @override
  void initState() {
    getCountry();
    super.initState();
  }

  Future getResponse() async {
    var res = await rootBundle.loadString(
        'packages/country_state_city_picker/lib/assets/country.json');
    return jsonDecode(res);
  }

  Future<void> getCountry() async {
    var countries = await getResponse() as List;
    _countries =
        countries.map((e) => locationModel.Country.fromJson(e)).toList();

    if (widget.countrySelectedId != null) {
      print('widget.countrySelectedId ${widget.countrySelectedId}');
      _selectedCountry = _countries
          .firstWhere((element) => element.id == widget.countrySelectedId);
      _states = _selectedCountry.state;
    }
    if (widget.stateSelectedId != null && _selectedCountry != null) {
      print('widget.stateSelectedId ${widget.stateSelectedId}');
      _selectedState = _selectedCountry.state
          .firstWhere((element) => element.id == widget.stateSelectedId);
      print(_selectedState.name);
    }
    setState(() {});
  }

  void _onSelectedCountry(locationModel.Country value) {
    if (!mounted) return;
    setState(() {
      _selectedState = null;
      _states = value.state;
      _selectedCountry = value;
      this.widget.onCountryChanged(value);
    });
  }

  void _onSelectedState(locationModel.State value) {
    if (!mounted) return;
    setState(() {
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
        Align(alignment: Alignment.centerLeft, child: Text('Country')),
        DropdownButton<locationModel.Country>(
          dropdownColor: widget.dropdownColor,
          isExpanded: true,
          items: _countries.map((locationModel.Country countryItem) {
            return DropdownMenuItem<locationModel.Country>(
              value: countryItem,
              child: Row(
                children: [
                  Text(
                    '${countryItem.emoji} ${countryItem.name}',
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
        Align(alignment: Alignment.centerLeft, child: Text('States')),
        DropdownButton<locationModel.State>(
          dropdownColor: widget.dropdownColor,
          isExpanded: true,
          focusColor: Colors.black,
          items: _states.map((locationModel.State stateItem) {
            return DropdownMenuItem<locationModel.State>(
              value: stateItem,
              child: Text(stateItem.name, style: widget.style),
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
