import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:provider/provider.dart';
import 'package:turistautak/shared/map_layers.dart';
import 'package:turistautak/shared/sate/download.dart';

class DownloadOptions extends StatefulWidget {
  const DownloadOptions({Key? key}) : super(key: key);

  @override
  State<DownloadOptions> createState() => _DownloadOptionsState();
}

class _DownloadOptionsState extends State<DownloadOptions> {
  late DownloadProvider provider = Provider.of<DownloadProvider>(context, listen: true);

  @override
  Widget build(BuildContext context) {
    DownloadProvider provider = Provider.of<DownloadProvider>(context, listen: true);
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Terület letöltése'),
      ),
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<int>(
                            future: _totalTiles(),
                            builder: (context, snapshot) {
                              return Row(
                                children: [
                                  Text(
                                    'Kiválasztva ',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.onBackground
                                    ),
                                  ),
                                  snapshot.hasData ? Text(
                                    snapshot.data.toString(),
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.onBackground
                                    ),
                                  ) : SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(),
                                  ), 
                                  Text(
                                    ' csempe',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.onBackground
                                    ),
                                  ),
                                ],
                              );
                            }
                          ),
                          FutureBuilder<double>(
                            future: _estSize(),
                            builder: (context, snapshot) {
                              return Row(
                                children: [
                                  Text(
                                    'Kb. ',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onBackground
                                    ),
                                  ),
                                  snapshot.hasData ? Text(
                                    snapshot.data!.toStringAsFixed(2),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onBackground
                                    ),
                                  ) : SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(),
                                  ), 
                                  Text(
                                    ' MB',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onBackground
                                    ),
                                  ),
                                ],
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        'Zoom kiválasztása',
                        style: theme.textTheme.caption?.copyWith(
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                    ),
                    RangeSlider(
                      values: provider.zoomRange,
                      min: 1, 
                      max: 17,
                      divisions: 16,
                      labels: RangeLabels(
                        provider.zoomRange.start.toStringAsFixed(0), 
                        provider.zoomRange.end.toStringAsFixed(0)
                      ),
                      onChanged: (RangeValues values) {
                        provider.zoomRange = values;
                        setState(() {});
                      }, 
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 15),
                      child: Text(
                        'Rétegek kiválasztása',
                        style: theme.textTheme.caption?.copyWith(
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                    ),
                    ListView.separated(
                      itemCount: MapLayers.all.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, i) {
                        MapLayer layer = MapLayers.all[i];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              color: theme.colorScheme.surfaceVariant,
                              child: layer.image,
                            )
                          ),
                          title: Text(
                            layer.name,
                            style: TextStyle(
                              color: theme.colorScheme.onBackground,
                              fontSize: 17,
                            ),
                          ),
                          trailing: Switch(
                            onChanged: (value) {
                              provider.selectedLayers[layer] = value;
                              setState(() {});
                            },
                            value: provider.isSelected(layer),
                          ),
                          contentPadding: EdgeInsets.fromLTRB(15, 20, 15, 20),
                          onTap: () {
                            provider.selectedLayers[layer] = !(provider.selectedLayers[layer]??false);
                            setState(() {});
                          },
                        ); 
                      },
                      separatorBuilder: (BuildContext context, int index) { 
                        return Divider(
                          color: Theme.of(context).colorScheme.outline,
                          height: 0,
                        ); 
                      },
                    ),
                    SizedBox(
                      height: 65,
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  for (var layer in provider.selectedLayers.entries) {
                    if(layer.value) {
                      provider.downloadProgress[layer.key.name] = layer.key.cachingInstance.download.startForeground(
                        region: provider.region!.toDownloadable(
                          provider.zoomRange.start.round(),
                          provider.zoomRange.end.round(),
                          layer.key.getOptions()  
                        ),
                      ).asBroadcastStream();
                    }
                  }
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Letöltés',
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(theme.colorScheme.primary),
                  foregroundColor: MaterialStateProperty.all(theme.colorScheme.onPrimary), 
                  fixedSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width -30, 50))
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<int> _totalTiles() async {
    int sum = 0;
    for (var layer in provider.selectedLayers.entries) {
      if(layer.value) {
        sum += await layer.key.cachingInstance.download.check(
          provider.region!.toDownloadable(provider.zoomRange.start.round(), provider.zoomRange.end.round(), layer.key.getOptions())
        );
      }
    }
    return sum;
  }

  Future<double> _estSize() async {
    double sum = 0;
    for (var layer in provider.selectedLayers.entries) {
      if(layer.value) {
        StoreDirectory store = layer.key.cachingInstance;
        int tiles = await store.download.check(
          provider.region!.toDownloadable(provider.zoomRange.start.round(), provider.zoomRange.end.round(), layer.key.getOptions())
        );
        double avgSize = 0.015;
        if(await store.stats.storeLengthAsync != 0) {
          avgSize = (await store.stats.storeSizeAsync / 1000) / await store.stats.storeLengthAsync;
        }
        sum += tiles * avgSize;
      }
    }
    return sum;
  }
}