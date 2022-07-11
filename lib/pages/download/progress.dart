import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:turistautak/shared/sate/download.dart';

class DownloadProgressPage extends StatefulWidget {
  const DownloadProgressPage({Key? key}) : super(key: key);

  @override
  State<DownloadProgressPage> createState() => _DownloadProgressPageState();
}

class _DownloadProgressPageState extends State<DownloadProgressPage> {
  late DownloadProvider provider = Provider.of<DownloadProvider>(context, listen: true);

  Map<String, double> _progress = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Letöltés folyamatban'),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          Scrollbar(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ..._progressBars(),
                  Container(height: 65),
                ]
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: OutlinedButton(
                onPressed: !_progress.values.any((element) => element < 1) && _progress.isNotEmpty ? () { 
                  provider.reset();
                  setState((){});
                } : null, 
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width -30, 30))
                ),
                child: Text('Kész'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _progressBars() {
    List<Widget> bars = [];
    for(var layer in provider.downloadProgress.entries) {
      layer.value.listen(
        (event) {
          setState(() {
            _progress[layer.key] = event.percentageProgress / 100;
          });
        },
        onDone: () {
          setState(() {
            _progress[layer.key] = 1;
          });
        },
      );
      bars.add(
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                layer.key,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: _progress[layer.key],
                  minHeight: 30,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
            ],
          ),
        )
      );
    }
    return bars;
  }
}