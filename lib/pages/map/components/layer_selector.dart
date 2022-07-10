import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turistautak/shared/map_layers.dart';
import 'package:turistautak/shared/sate/map_data.dart';

class LayerSelector extends StatefulWidget {
  const LayerSelector({Key? key}) : super(key: key);

  @override
  State<LayerSelector> createState() => _LayerSelectorState();
}

class _LayerSelectorState extends State<LayerSelector> {

  Widget _categoryTitle ({required BuildContext context, required String text}) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
    );
  }

  Widget _layerWidget({required BuildContext context, required MapLayer layer}) {
    MapDataProvider provider = context.read<MapDataProvider>();
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    bool selected = provider.baseLayer == layer || provider.isActive(layer);

    return GestureDetector(
      child: Column(
        children: [
          Container(
            decoration: selected ? BoxDecoration(
              border: Border.all(
                color: colorScheme.primary,
                width: 3.0
              ),
              borderRadius: BorderRadius.circular(15.0),
            ) : null,
              margin: EdgeInsets.all(selected ? 7 : 10),
              padding: EdgeInsets.all(2),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  color: colorScheme.inverseSurface,
                  child: Image(
                    image: Image.asset('assets/images/${layer.name}.png').image,
                    width: 65.0,
                    height: 65.0,
                  ),
                ),
              ),
          ),
          
          Text(
            layer.name,
            style: TextStyle(
              color: selected ? colorScheme.primary : colorScheme.onSurface
            ),
          ),
        ],
      ),
      onTap: () {
        if(layer.overlay) {
          provider.setLayer(
            layer,
            !provider.isActive(layer)
          );
        }
        else {
          provider.baseLayer = layer;
        }
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _categoryTitle(context: context, text: 'Térkép típusa'),
        Padding(
          padding: const EdgeInsets.only(bottom: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _layerWidget(context: context, layer: MapLayers.openStreetMap),
              _layerWidget(context: context, layer: MapLayers.openTopoMap),
            ],
          ),
        ),
        Divider(color: Theme.of(context).colorScheme.outline, height: 0),
        _categoryTitle(context: context, text: 'Térkép részletei'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _layerWidget(context: context, layer: MapLayers.trails),
          ],
        ),
      ],
    );
  }
}