import 'package:flutter/services.dart';
import 'package:web_socket_channel/io.dart';

main(List<int> img) async {
  final channel = IOWebSocketChannel.connect('ws://192.168.100.3:9999');
  print(img);
  print(img.length);
  channel.stream.listen((message) {
    channel.sink.add(img.length);
    channel.sink.add(img);
    channel.sink.close();
  });
}
