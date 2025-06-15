import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(NovaPlayer());
}

class NovaPlayer extends StatefulWidget {
  @override
  _NovaPlayerState createState() => _NovaPlayerState();
}

class _NovaPlayerState extends State<NovaPlayer> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<SongModel> songs = [];
  int? currentIndex;

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  void requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    loadSongs();
  }

  void loadSongs() async {
    songs = await _audioQuery.querySongs();
    setState(() {});
  }

  void playSong(int index) async {
    currentIndex = index;
    await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(songs[index].uri!)));
    _audioPlayer.play();
    setState(() {});
  }

  void pauseSong() {
    _audioPlayer.pause();
    setState(() {});
  }

  void playNext() {
    if (currentIndex == null) return;
    int nextIndex = (currentIndex! + 1) % songs.length;
    playSong(nextIndex);
  }

  void playPrevious() {
    if (currentIndex == null) return;
    int prevIndex = (currentIndex! - 1 + songs.length) % songs.length;
    playSong(prevIndex);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovaPlayer',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: Text('NovaPlayer'),
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'NovaPlayer',
                  applicationVersion: '1.0',
                  children: [Text('ساخته شده توسط ابوالفضل ایمانی')],
                );
              },
            ),
          ],
        ),
        body: songs.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(songs[index].title),
                    subtitle: Text(songs[index].artist ?? 'ناشناس'),
                    onTap: () => playSong(index),
                    selected: currentIndex == index,
                  );
                },
              ),
        bottomNavigationBar: currentIndex == null
            ? null
            : BottomAppBar(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(icon: Icon(Icons.skip_previous), onPressed: playPrevious),
                    IconButton(
                      icon: _audioPlayer.playing ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                      onPressed: () {
                        if (_audioPlayer.playing) {
                          pauseSong();
                        } else {
                          if (currentIndex != null) playSong(currentIndex!);
                        }
                      },
                    ),
                    IconButton(icon: Icon(Icons.skip_next), onPressed: playNext),
                  ],
                ),
              ),
      ),
    );
  }
}