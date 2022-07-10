import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turistautak/shared/sate/download.dart';
import 'package:turistautak/shared/vars/region_mode.dart';

class ShapeSelector extends StatelessWidget {
  const ShapeSelector({Key? key}) : super(key: key);

  static const Map<String, List<dynamic>> regionShapes = {
    'Négyzet': [
      Icons.crop_square_sharp,
      RegionMode.square,
    ],
    'Téglalap (Álló)': [
      Icons.crop_portrait_sharp,
      RegionMode.rectangleVertical,
    ],
    'Téglalap (Fekvő)': [
      Icons.crop_landscape_sharp,
      RegionMode.rectangleHorizontal,
    ],
    'Kör': [
      Icons.circle_outlined,
      RegionMode.circle,
    ],
  };

  @override
  Widget build(BuildContext context) {
    DownloadProvider provider = Provider.of<DownloadProvider>(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 25),
      child: ListView.builder(
        itemCount: regionShapes.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int i) {
          final String key = regionShapes.keys.toList()[i];
          final IconData icon = regionShapes.values.toList()[i][0];
          final RegionMode? mode = regionShapes.values.toList()[i][1];

          return ListTile(
            visualDensity: VisualDensity.compact,
            title: Text(key),
            leading: Icon(icon),
            trailing: provider.regionMode == mode ? const Icon(Icons.done) : null,
            iconColor: Theme.of(context).colorScheme.onSurface,
            textColor: Theme.of(context).colorScheme.onSurface,
            onTap: () {
              provider.regionMode = mode!;
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}