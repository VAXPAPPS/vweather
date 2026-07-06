import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vweather/core/theme/vaxp_theme.dart';
import 'package:vweather/core/colors/vaxp_colors.dart';
import '../bloc/weather_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../domain/repositories/i_weather_repository.dart';

class SearchOverlay extends StatefulWidget {
  const SearchOverlay({super.key});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<SearchOverlay> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: VaxpGlass(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Search City",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TypeAheadField<String>(
                controller: _controller,
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: TextStyle(color: VaxpColors.defaultText),
                    decoration: InputDecoration(
                      hintText: "Enter city name...",
                      hintStyle: TextStyle(color: VaxpColors.defaultText.withValues(alpha: 0.5)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: VaxpColors.defaultText.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: VaxpColors.primary),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        context.read<WeatherBloc>().add(WeatherRequested(city: value));
                        Navigator.of(context).pop();
                      }
                    },
                  );
                },
                suggestionsCallback: (pattern) async {
                  if (pattern.isEmpty) return [];
                  final repository = context.read<IWeatherRepository>();
                  return await repository.searchCities(pattern);
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(
                    title: Text(suggestion, style: TextStyle(color: VaxpColors.defaultText)),
                    tileColor: VaxpColors.glassSurface,
                  );
                },
                onSelected: (suggestion) {
                  _controller.text = suggestion;
                  context.read<WeatherBloc>().add(WeatherRequested(city: suggestion));
                  Navigator.of(context).pop();
                },
                emptyBuilder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('No cities found.', style: TextStyle(color: VaxpColors.defaultText.withValues(alpha: 0.5))),
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        context.read<WeatherBloc>().add(WeatherRequested(city: _controller.text));
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: VaxpColors.primary,
                    ),
                    child: const Text("Search"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
