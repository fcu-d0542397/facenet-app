import 'dart:io';
import 'dart:math';

main(List<int> img) async {
  print(img);
  Socket socket = await Socket.connect('192.168.100.3', 9999);
  List<int> msg = [];
  int temp;
  for (int i = 0; i < 8; i++) {
    temp = img.length & (0xff << (i * 8));
    temp = temp ~/ pow(256, i);
    msg.add(temp);
  }
  print(img.length);
  socket.add(msg);
  socket.add(img);
  socket.close();
}
