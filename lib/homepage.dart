import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeClass extends StatelessWidget {
  final String salesListUrl =
      'https://www.api.viknbooks.com/api/v10/sales/sale-list-page/';
  final RxList<Map<String, dynamic>> salesList = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sales Estimate',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          InkWell(
              onTap: () {
                _fetchSalesList();
              },
              child: Icon(
                Icons.add,
                color: Colors.blue,
              )),
          SizedBox(
            width: 20,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: BorderSide.none),
                  hintText: "Search",
                  suffixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey,
                  )),
            ),
          ),
          Obx(
            () => salesList.isEmpty
                ? Text('Sales List is empty.')
                : Expanded(
                    child: ListView.builder(
                      itemCount: salesList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          /*title: Text('${salesList[index]['invoice_no']}'),
                          subtitle:
                              Text('${salesList[index]['customer_name']}'),
                          trailing: Column(
                            children: [
                              Text(
                                '${salesList[index]['status']}',
                              ),
                              Text('${salesList[index]['amount']}',
                                  style: TextStyle(color: Colors.grey))
                            ],
                          ),*/
                            );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchSalesList() async {
    try {
      isLoading.value = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access') ?? '';

      final Map<String, dynamic> salesListData = {
        'BranchID': 1,
        'CompanyID': '1901b825-fe6f-418d-b5f0-7223d0040d08',
        'CreatedUserID': 62,
        'PriceRounding': 3,
        'page_no': 1,
        'items_per_page': 10,
        'type': 'Sales',
        'WarehouseID': 1,
      };

      final response = await http.post(
        Uri.parse(salesListUrl),
        body: json.encode(salesListData),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        salesList.assignAll(responseData.cast<Map<String, dynamic>>());
      } else {
        Get.snackbar('Error',
            'Failed to fetch sales list. Status Code: ${response.statusCode}');
      }
    } finally {
      isLoading.value = false;
    }
  }
}
