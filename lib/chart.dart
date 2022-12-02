import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'main.dart';
import 'server.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'model/model.dart';
class ChartListPage extends StatefulWidget {
  ChartListPage({Key? key}) : super(key: key);

  @override
  State<ChartListPage> createState() => _ChartListPageState();

}

class _ChartListPageState extends State<ChartListPage> with TickerProviderStateMixin {

  Future<GETROOMLIST>? roomlist;
  int roomid=0;
  late TabController _tabController;
  List<Widget>? _pagelist;
  @override
  void initState(){
    roomlist = ServerApi.getRoom();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return
      FutureBuilder(future: roomlist,builder: (context,snapshot) {
        if (snapshot.hasData) {
          _pagelist=List<Widget>.generate(snapshot.data!.roomlist!.length!, (index) => StaticsPage(snapshot!.data!.roomlist![index].id!));
          _tabController = new TabController(vsync: this, length: snapshot.data!.roomlist!.length,);
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text('Statics',style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),),
              bottom: ButtonsTabBar(
                  controller: _tabController,
                  backgroundColor: Colors.green[600],
                  unselectedBackgroundColor: Colors.white,
                  labelStyle:
                  TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(
                      color: Colors.green[600],
                      fontWeight: FontWeight.bold),
                  borderWidth: 3,
                  unselectedBorderColor: Colors.green[600]!,
                  radius: 100,
                  tabs: List<Tab>.generate(
                      snapshot.data!.roomlist!.length, (i) =>
                      Tab(text: snapshot.data!.roomlist![i].title!))
              ),

              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      Navigator.pushNamed(context, '/modify');
                    });
                  },
                  icon: const Icon(Icons.account_circle),
                )
              ],
            ),
            body: TabBarView(
              controller: _tabController,
              children: _pagelist!,
            ),

            floatingActionButton: FloatingActionButton(
              onPressed: () async{
                await ServerApi.updatestatics();
                setState(() {

                });
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.replay),
            ),
          );
        }
        else if (snapshot.hasError) {
          return Text("error");
        }
        return CircularProgressIndicator();
      }
      );
  }
}


class CleaningChart{
  CleaningChart(this.name, this. cleaning);
  final String name;
  final int cleaning;
}
class StaticsPage extends StatefulWidget {
  int id=4;
  StaticsPage(this.id,{Key? key}) : super(key: key);

  @override
  State<StaticsPage> createState() => _StaticsPageState();
}

class _StaticsPageState extends State<StaticsPage> {

  Future<Statics>? _statics;

  @override
  void initState(){
    super.initState();

  }
  @override
  Widget build(BuildContext context) {

    _statics=ServerApi.getStatics(widget.id, null);
    return FutureBuilder(future: _statics,builder: (context,snapshot){
      if(snapshot.hasData){
        return SfCircularChart(
          title: ChartTitle(text: 'Statistics'),
          legend: (Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap)),
          series: <CircularSeries>[
            PieSeries<CleaningChart , String>(
              dataSource: List<CleaningChart>.generate(snapshot.data!.liststatics!.length!,
                      (index) => CleaningChart(snapshot.data!.liststatics![index].user!.nickname!, snapshot.data!.liststatics![index].score!)),
              xValueMapper: (CleaningChart data,_)=> data.name,
              yValueMapper: (CleaningChart data,_)=> data.cleaning,
              //dataLabelSettings: const DataLabelSettings(isVisible: true)   //숫자 말고 이름으로
            )
          ],);
      }else if(snapshot.hasError){
        return Text("No Data");
      }
      return CircularProgressIndicator();
    });
  }
}


//Dynamic update 구현
