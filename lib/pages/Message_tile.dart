import 'package:flutter/material.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  const MessageTile({super.key, required this.message, required this.sender, required this.sentByMe});

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: widget.sentByMe? Alignment.bottomRight: Alignment.bottomLeft,
      padding:  EdgeInsets.only(
        top: 5,
        left: widget.sentByMe ? 0: 10,
        right: widget.sentByMe? 10: 0 

      ),

      child: Container(
        margin: widget.sentByMe? const EdgeInsets.only(left: 50, bottom: 4):const EdgeInsets.only(right: 50, bottom: 4),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal:10),
      decoration: BoxDecoration(
        borderRadius: widget.sentByMe? const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18)
        ):const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomRight: Radius.circular(18)
        ) ,
        color: widget.sentByMe?  Theme.of(context).primaryColor : Color.fromARGB(255, 204, 230, 7)
      ),
        child: Column(
          crossAxisAlignment:widget.sentByMe? CrossAxisAlignment.end :  CrossAxisAlignment.start,
          children: <Widget>[
            Text('${widget.sender}', style: const TextStyle(fontSize:15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10), 
            Text('${widget.message}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10), 
    
    
    
          ] 
        )
      ),
    );
  }
}