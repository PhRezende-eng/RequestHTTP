import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../providers/orders.dart';
import '../widgets/order_widget.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // bool isLoading = true;
  // @override
  // void initState() {
  //   // Provider.of<Orders>(context, listen: false).loadOrder().then((_) {    -> não precisa mais pois tiramos o ternário e o init state é no Future Builder
  //   //   setState(() {
  //   //     isLoading = false;
  //   //   });
  //   // });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // final Orders orders = Provider.of(context);
    // final orders = Provider.of<Orders>(context);
    final ordersPro = Provider.of<Orders>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Pedidos'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: ordersPro.loadOrder(),
        builder: (contextt, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.error != null) {
            return Center(
              child: Text('Ocorreu um erro!'),
            );
          } else {
            return Consumer<Orders>(
              builder: (context, ordersBui, child) {
                return RefreshIndicator(
                  onRefresh: () => _loadScreen(context),
                  child: ListView.builder(
                    itemCount: ordersBui.itemsCount,
                    itemBuilder: (ctx, index) =>
                        OrderWidget(ordersBui.items[index]),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _loadScreen(BuildContext context) async {
    await Provider.of<Orders>(context, listen: false).loadOrder();
  }
}
