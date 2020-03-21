import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:project/models/stepsModel.dart';
import 'package:project/database.dart';
import 'package:project/stepsManager.dart';
import 'package:charts_flutter/flutter.dart' as charts;



// revoir comment faire des pas à l'interieur ou exté...
//comment analyser les pas
void main(){
  //DBProvider dbProvider = DBProvider.db;
  //StepsManager stepsManager;
  runApp(MyApp());
}

  
 

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
  
  
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Pedometer _pedometer;
  StreamSubscription<int> _subscription;
  String _stepCountValue = 'unknown';
  DBProvider dbProvider = DBProvider.db;
  final dataBase = DBProvider();
  int value = 0;
  List<Steps> steps = [];


  bool resetCounterPressed = false;
  String timeToDisplay = "00:00:00";
  var swatch = Stopwatch();
  final dur = Duration(seconds: 1);
  var now = DateTime.now();
  

  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  void starttimer(){
    Timer(dur, keeprunning);
  }
  void keeprunning(){
    if(swatch.isRunning){
      starttimer();
    }
    setState(() {
      timeToDisplay = swatch.elapsed.inHours.toString().padLeft(2,"0") + ":"
                      + (swatch.elapsed.inMinutes%60).toString().padLeft(2,"0") + ":"
                      + (swatch.elapsed.inSeconds%60).toString().padLeft(2,"0");
    });
  }
  
  Widget stopWatch(){
    return Container(
      child: Column(
        children:<Widget>[
          Container(
            alignment: Alignment.center,
            child: Text(timeToDisplay,
                  style: TextStyle(fontSize: 20.0),
                  ),
          ),
        ]
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    
    var scaffold = Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Container(
        decoration: BoxDecoration(
         //color: Colors.red[300],
        ),
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column( 
              
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
             
               Container(
                //margin: const EdgeInsets.all(10.0),
                color: Colors.amber[200],
                width: 600.0,
                height: 348.0,
                padding: const EdgeInsets.all(0.0),
                child : VerticalBarLabelChart.withSampleData(),
               ),
                Icon(Icons.directions_walk),
               Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Text('Step counter:  ex: $_stepCountValue'),
               ),
               Divider(),
               Text(DateTime.now().toString()),   
               Text(now.toString()),                   
            ]
            ),
            stopWatch(),
            _buildStepList(steps),
            RaisedButton(
              onPressed: reset,
              child: Text('reset'),
              ),
            RaisedButton(
              onPressed: resetStepCounter,
              child: Text('reset timer'),
            ),
          ],
        ),
        margin: const EdgeInsets.all(8.0),
        
      ), 
    );
    return scaffold;
  }

  void resetStepCounter() {
    setState(() {
      resetCounterPressed = false;

    });
    swatch.reset();
    timeToDisplay = "00:00:00";
  }
   
  _save() async{
    final prefs = await SharedPreferences.getInstance();
    final key = 'my_int_key';
    if ((swatch.elapsed.inSeconds%60)%10==0){
      value = int.parse('$_stepCountValue');
      prefs.setInt(key, value);
      //StepsManager(dbProvider).addNewSteps(step);
      //reset();
     // _subscription.resume();

    }
    
    print('saved $value');
  }

 /*int get resetTheCounter { 
   _save();
   
   if ((swatch.elapsed.inSeconds%60)%10==0){
   var step = new Steps(
        id: null,
        numberSteps: int.parse('$_stepCountValue')-value,
        theTime: timeToDisplay,
      );

      if(step.numberSteps != 0){
              StepsManager(dbProvider).addNewSteps(step); 
      }
   }
    return int.parse('$_stepCountValue')-value;
 
}*/
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }
  void initState() {
    //initPlatformState();
    super.initState();
    startListening();
    setupList();
  }

  Future<void> initPlatformState() async {
    startListening();
  }
  void onData(int stepCountValue) {
    print(stepCountValue);
  }

  void startListening() {
    _pedometer = new Pedometer();
    _subscription = _pedometer.pedometerStream.listen(_onData,
        onError: _onError, onDone: _onDone, cancelOnError: true);
  }
 void stopListening() {
    _subscription.cancel();
  }

  void _onData(int stepCountValue) async {
    setState(() {
       _stepCountValue = "$stepCountValue";
       swatch.start();
       starttimer();
    });
  }
  void reset() {
    setState(() {
      int stepCountValue = 0;
      stepCountValue = 0;
      _stepCountValue = "$stepCountValue";
    });
  }
 

  void _onDone() => print("Finished pedometer tracking");

  void _onError(error) => print("Flutter Pedometer Error: $error");

  Widget _buildStepList(List<Steps> stepsList) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(5.0),
        itemCount: stepsList.length,
        itemBuilder: (BuildContext context, int index) {
          return Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('Id'),
                    Text(stepsList[index].id.toString()),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('time'),
                    Text(stepsList[index].theTime),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('nb of steps'),
                    Text(stepsList[index].numberSteps.toString()),
                  ],
                ),
              ),
              
            ],
          );
        },
      ),
    );
  }


  void setupList() async{
    var _steps = await dataBase.fetchAll();
    print(_steps);
    setState(() {
      steps = _steps;
    });
  }



}

class VerticalBarLabelChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  VerticalBarLabelChart(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory VerticalBarLabelChart.withSampleData() {
    return new VerticalBarLabelChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }


  // [BarLabelDecorator] will automatically position the label
  // inside the bar if the label will fit. If the label will not fit,
  // it will draw outside of the bar.
  // Labels can always display inside or outside using [LabelPosition].
  //
  // Text style for inside / outside can be controlled independently by setting
  // [insideLabelStyleSpec] and [outsideLabelStyleSpec].
  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      // Set a bar label decorator.
      // Example configuring different styles for inside/outside:
      //       barRendererDecorator: new charts.BarLabelDecorator(
      //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
      //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
      barRendererDecorator: new charts.BarLabelDecorator<String>(),
      domainAxis: new charts.OrdinalAxisSpec(),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final data = [
      new OrdinalSales('0h', 5),
      new OrdinalSales('1h', 2),
      new OrdinalSales('2h', 0),
      new OrdinalSales('3h', 0),
      new OrdinalSales('4h', 0),
      new OrdinalSales('5h', 0),
      new OrdinalSales('6h', 0),
      new OrdinalSales('7h', 54),
      new OrdinalSales('8h', 124),
      new OrdinalSales('9h', 32),
      new OrdinalSales('10h', 4),
      new OrdinalSales('11h', 12),
      new OrdinalSales('12h', 158),
      new OrdinalSales('13h', 75),
      new OrdinalSales('14h', 12),

    ];

    return [
      new charts.Series<OrdinalSales, String>(
          id: 'Sales',
          domainFn: (OrdinalSales sales, _) => sales.year,
          measureFn: (OrdinalSales sales, _) => sales.sales,
          data: data,
          // Set a label accessor to control the text of the bar label.
          labelAccessorFn: (OrdinalSales sales, _) =>
              '${sales.sales.toString()} pas')
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}