
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:price_management/Controller/revenue_constroller.dart';
import 'package:price_management/StorageProvider.dart';
import 'package:price_management/Views/AddScreen.dart';
import 'package:price_management/Views/Shopping.dart';
import 'package:price_management/Views/chart_screen.dart';
import 'package:price_management/Views/login_form.dart';
import 'package:price_management/shared/firebase_auth.dart';

class Dashboard extends StatelessWidget {
  final String uid;
  final FirebaseAuthentication auth;
  Dashboard({Key? key, required this.uid, required this.auth}) : super(key: key);

//   @override
//   State<Dashboard> createState() => _DashboardState();
// }
//
// class _DashboardState extends State<Dashboard> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('store').doc(uid).collection('products').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if(snapshot.hasError){
        return Text('Error');
      }
      return Scaffold(
          appBar: AppBar(
            title: const Text('Quản lý bán hàng'),
            actions: [
              IconButton(onPressed: (){

                auth.logout().then((value){
                  if(value){
                      StorageProvider.of(context).clearData();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => LoginScreen(auth: auth,)));
                  }
                  else {
                    print("Logout error");
                  }
                });
              }, icon: const Icon(Icons.logout))
            ],
          ),
          body:Body(snapshot, context)
      );
    });
  }
  Widget Body(AsyncSnapshot<QuerySnapshot> snapshot, BuildContext context){
    if(snapshot.connectionState == ConnectionState.waiting){
      return const Center(child: CircularProgressIndicator());
    }
    if(snapshot.hasData){
      StorageProvider.of(context).readPref(uid, snapshot.data!.docs);
    }

    RevenueController revenueController = RevenueController();
    revenueController.readData(uid, FirebaseFirestore.instance.collection('store').doc(uid).collection('months'));
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      primary: false,
      children: [
        buildGestureDetector(context, 'Mua hàng'),
        buildGestureDetector(context, 'Quản lý sản phẩm'),
        buildGestureDetector(context, 'Xem doanh thu')
      ],
    );
  }
  GestureDetector buildGestureDetector(BuildContext context,String text) {
    return GestureDetector(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(15)
              ),
              child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  cardIcon(text),
                  const SizedBox(height: 20,),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              )),
            ),
          ),
          onTap: (){
            if(text == 'Quản lý sản phẩm') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddScreen()));
            }
            else if (text == 'Mua hàng') {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CartProvider(child: const Shopping())));
            }
            else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChartScreen(uid: uid)));
            }
          },
        );
  }
  Widget cardIcon(String text){
    if(text == 'Quản lý sản phẩm'){
      return const Icon(Icons.add_circle, size: 50, color: Colors.white,);
    }
    else if (text == 'Mua hàng'){
      return const Icon(Icons.shopping_cart, size: 50, color: Colors.white,);
    }
    else {
      return const Icon(Icons.show_chart, size: 50, color: Colors.white,);
    }
  }
}
