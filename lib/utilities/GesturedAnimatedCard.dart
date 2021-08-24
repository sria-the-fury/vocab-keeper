import 'dart:math';

import 'package:flutter/material.dart';


class GesturedAnimatedCard extends StatefulWidget {
  GesturedAnimatedCard ({Key? key}) : super(key: key);

  @override
  _GesturedAnimatedArdState createState() => _GesturedAnimatedArdState();
}

class _GesturedAnimatedArdState extends State<GesturedAnimatedCard> {

  bool isBack = true;
  double angle = 0;

  _flip() {
    setState(() {
      angle =(angle + pi) %(2 * pi);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        child:
        SingleChildScrollView(
          padding: EdgeInsets.all(40.0),
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [

              GestureDetector(
                onTap: () {_flip();},
                child: TweenAnimationBuilder(tween: Tween<double>(begin: 0, end: angle),
                    duration: Duration(seconds: 1),
                    builder: (BuildContext context, double val, __){
                      if(val>= (pi/2)){
                        isBack = false;
                      } else isBack = true;
                      return(
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(val),
                            child: Container(
                              width: 309,
                              height: 474,
                              child: isBack ?
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    image: DecorationImage(
                                        image: AssetImage('assets/back.png')
                                    )
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('Heading', style: TextStyle(fontSize: 35.0),),
                                      Text('sub', style: TextStyle(fontSize: 25.0),),
                                      Text('Heading', style: TextStyle(fontSize: 20.0),),
                                    ],
                                  ),
                                ),

                              )

                                  : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..rotateY(pi),
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      image: DecorationImage(
                                          image: AssetImage('assets/face.png')
                                      )
                                  ),
                                  child: Center(
                                    child: Text('Surprise! Surprise!', style: TextStyle(color: Colors.black,
                                        fontWeight: FontWeight.bold, fontSize: 35.0
                                    ),),
                                  ),

                                ),
                              ),
                            ),
                          )
                      );

                    }),
              ),


            ],
          ),
        )
    );
  }
}

