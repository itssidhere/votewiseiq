import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:votewiseiq/model/post.dart';
import 'package:votewiseiq/model/reddit.dart';
import 'package:votewiseiq/model/twitter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class BarChartData {
  BarChartData(this.x, this.y);
  final String x;
  final int y;
}

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  var tableData = <Post>[];
  var order_map = <int, int>{};
  // one week old timestamp
  var from = DateTime.now().subtract(const Duration(days: 7));
  var to = DateTime.now();
  var selected_social = 'twitter';
  var input_keywords = <String>['bitcoin', 'tesla', 'university of alberta'];
  var total_negative = 1;
  var total_positive = 1;
  var scrollController = ScrollController();
  var loading = false.obs;
  var top10Keywords = <Map>[];

  Map<DateTime, int> negative_line = <DateTime, int>{};
  Map<DateTime, int> positive_line = <DateTime, int>{};

  var negativeChartData = <BarChartData>[];
  var positiveChartData = <BarChartData>[];

  var _textEditingController = TextEditingController();
  @override
  void initState() {
    fetchData(keyword: input_keywords[input_keywords.length - 1]);
    super.initState();
  }

  Future<List<Post>> getDataFromAPI(
      {required String keyword, int limit = 200}) async {
    //add second argument to the url limit to 1000
    var baseUrl = 'http://localhost:5000';
    var data = <Post>[];
    if (selected_social == "twitter") {
      var query =
          "$keyword since:${DateFormat('yyyy-MM-dd').format(from)} until:${DateFormat('yyyy-MM-dd').format(to)}";
      var url = '${baseUrl}/twitter?query=${query}&limit=${limit}';
      var response = await Dio().get(url);

      for (var i = 0; i < response.data['tweets'].length; i++) {
        data.add(Tweets.fromJson(response.data['tweets'][i]));
      }
    } else {
      var url = '${baseUrl}/reddit?query=${keyword}&limit=${limit}';
      var response = await Dio().get(url);

      for (var i = 0; i < response.data['reddits'].length; i++) {
        data.add(Reddits.fromJson(response.data['reddits'][i]));
      }
    }

    return data;
  }

  Future<void> fetchData({String keyword = 'university of alberta'}) async {
    loading.value = true;

    //first check if the keyword is already in the hive cache

    var box =
        selected_social == 'twitter' ? Hive.box('twitter') : Hive.box('reddit');

    if (box.containsKey(keyword)) {
      print('cached data found for $keyword');

      var data = box.get(keyword) as List;

      //data is list of linkedhashmap convert it to list of map<string,dynamic>

      //convert the data to list of posts
      tableData = data
          .map((json) => selected_social == 'twitter'
              ? Tweets(
                  uid: json['uid'],
                  content: json['tweet'] as String,
                  date: DateTime.parse(json['date'] as String),
                  sentiment: Sentiment(
                      negative: json['sentiment']['negative'],
                      positive: json['sentiment']['positive'],
                      neutral: json['sentiment']['neutral']),
                  url: 'https://twitter.com/${json['uid']}',
                )
              : Reddits(
                  uid: json['uid'] ?? '',
                  content: json['body'] as String,
                  date: DateTime.parse(json['date'] as String),
                  sentiment: Sentiment(
                      negative: json['sentiment']['negative'],
                      positive: json['sentiment']['positive'],
                      neutral: json['sentiment']['neutral']),
                  url: json['url'] as String,
                ))
          .toList();
    } else {
      tableData = await getDataFromAPI(keyword: keyword);

      //print first element of the list to json
      print(tableData[0].toJson());

      var newList = tableData.map((e) => e.toJson()).toList();

      //save the data to hive
      box.put(keyword, newList);
    }

    loading.value = false;

    setState(() {
      tableData.sort((a, b) => b.date.compareTo(a.date));
    });

    total_positive = 0;
    total_negative = 0;
    //drop the first element of each of the sublist
    for (var element in tableData) {
      if (element.sentiment.negative > element.sentiment.positive) {
        total_negative += 1;
      } else {
        total_positive += 1;
      }
    }

    //get the top 10 keywords from the tableData
    var keywords = <String, int>{};

    for (var element in tableData) {
      var content = element.content;
      var words = content.split(' ');
      for (var word in words) {
        if (word.length > 3) {
          keywords[word] = (keywords[word] ?? 0) + 1;
        }
      }
    }

    //take the top 10 entries from the keywords map and store it in top10Keywords

    var sortedKeys = keywords.keys.toList(growable: false)
      ..sort((k1, k2) => keywords[k2]!.compareTo(keywords[k1]!));

    top10Keywords = [];

    for (var i = 0; i < 10; i++) {
      top10Keywords.add({
        'keyword': sortedKeys[i],
        'count': keywords[sortedKeys[i]] ?? 0,
      });
    }

    negative_line.clear();
    positive_line.clear();

    // get all the dates from from to to range and set them to 0 in negative_line and positive_line
    var date = from;
    while (date.isBefore(to)) {
      var d = DateTime(date.year, date.month, date.day);
      negative_line[d] = 0;
      positive_line[d] = 0;
      date = date.add(const Duration(days: 1));
    }

    // fill negative_line and positive_line

    for (var i = 0; i < tableData.length; i++) {
      var d = tableData[i].date;
      var date = DateTime(d.year, d.month, d.day);
      var sentiment = tableData[i].sentiment;

      if (sentiment.negative > sentiment.positive) {
        negative_line[date] = (negative_line[date] ?? 0) + 1;
        positive_line[date] = (positive_line[date] ?? 0);
      } else {
        positive_line[date] = (positive_line[date] ?? 0) + 1;
        negative_line[date] = (negative_line[date] ?? 0);
      }
    }

    setState(() {
      for (var i = 0; i < 4; i++) {
        order_map[i] = -1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //create a flutter table
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: ListTile(
                  title: Text('Narendra Modi'),
                  subtitle: Text('Bharatiya Janata Party'),
                  leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage("https://picsum.photos/200/300"))),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primaryContainer,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('View Profile'),
              onTap: () {},
            ),
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.logout),
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('VotewiseIQ'),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width,
              color: Get.theme.colorScheme.primaryContainer,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        'You are currently viewing the data from twitter for the last ${to.difference(from).inDays} days',
                        style: Get.textTheme.bodyText1!
                            .copyWith(color: Colors.white)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //show drop down menu for social media
                        DropdownButton<String>(
                          value: selected_social.toUpperCase(),
                          icon: const Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selected_social = newValue.toLowerCase();
                              });
                            }
                          },
                          items: <String>[
                            'Twitter'.toUpperCase(),
                            // 'Facebook'.toUpperCase(),
                            // 'Instagram'.toUpperCase(),
                            'Reddit'.toUpperCase()
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          width: 20,
                        ),

                        //from date picker
                        TextButton(
                          onPressed: () async {
                            //show date picker
                            var date = await showDatePicker(
                                context: context,
                                initialDate: from,
                                firstDate: DateTime(2020),
                                lastDate: to.subtract(const Duration(days: 7)));

                            if (date != null) {
                              setState(() {
                                from = date;
                              });
                            }
                          },
                          child: Text(DateFormat.yMMMMEEEEd().format(from)),
                        ),
                        //show a white dash between the two dates
                        Text(
                          ' - ',
                          style: Get.textTheme.headlineLarge!
                              .copyWith(color: Colors.white),
                        ),
                        //to date picker
                        TextButton(
                          onPressed: () async {
                            //show date picker
                            var date = await showDatePicker(
                                context: context,
                                initialDate: to,
                                firstDate: DateTime(2022),
                                lastDate: DateTime.now());
                            if (date != null) {
                              if (date.difference(from) >=
                                  const Duration(days: 7)) {
                                setState(() {
                                  to = date;
                                });
                              } else {
                                Get.snackbar('Error',
                                    'The date range should be atleast 7 days');
                              }
                            }
                          },
                          child: Text(DateFormat.yMMMMEEEEd().format(to)),
                        ),
                      ],
                    ),

                    SizedBox(
                      width: Get.width * 0.5,
                      child: Row(children: <Widget>[
                        const Expanded(
                            child: const Divider(
                          color: Colors.white54,
                        )),
                        Text("HISTORY", style: TextStyle(color: Colors.white)),
                        Expanded(
                            child: Divider(
                          color: Colors.white54,
                        )),
                      ]),
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    //show chips of the keywords with a delete button
                    Container(
                      height: 50,
                      child: Wrap(
                        spacing: 8.0,
                        children: [
                          for (var keyword in input_keywords)
                            Chip(
                              label: Text(keyword),
                              deleteButtonTooltipMessage: 'Search Again',
                              deleteIcon: const Icon(Icons.history),
                              onDeleted: () {
                                //shift that keyword to the end of the list
                                input_keywords.remove(keyword);
                                input_keywords.add(keyword);
                                setState(() {
                                  fetchData(keyword: keyword);
                                });
                              },
                            )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //show a search bar
            SizedBox(
              height: 20,
            ),
            Text(
                'Showing results for ${input_keywords[input_keywords.length - 1]}',
                style: Get.textTheme.titleMedium),
            SizedBox(
              height: 20,
            ),

            Container(
              padding: const EdgeInsets.all(8.0),
              width: Get.width * 0.25,
              child: TextField(
                controller: _textEditingController,
                onSubmitted: (value) {
                  setState(() {
                    fetchData(keyword: value);
                    input_keywords.add(value);
                  });
                },
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      selected_social == 'twitter'
                          ? FontAwesomeIcons.twitter
                          : selected_social == 'facebook'
                              ? FontAwesomeIcons.facebook
                              : selected_social == 'instagram'
                                  ? FontAwesomeIcons.instagram
                                  : FontAwesomeIcons.reddit,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            var keyword = _textEditingController.text.trim();

                            if (keyword.isEmpty || keyword.length < 3) {
                              Get.snackbar(
                                  'Error', 'Please enter a valid keyword');
                              return;
                            }
                            //show a dialog to confirm the tracking
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Track $keyword?'),
                                    content: Text(
                                        'This will track the keyword $keyword and show you the results in the tracked section'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          child: Text('Cancel')),
                                      TextButton(
                                          onPressed: () {
                                            Get.back();

                                            //clear the textediting controller
                                            _textEditingController.clear();

                                            //add keyword to firebase

                                            FirebaseFirestore.instance
                                                .collection('keywords')
                                                .add({
                                              'keyword': keyword,
                                              'social': selected_social,
                                              'from': from,
                                              'to': to,
                                              'timestamp':
                                                  FieldValue.serverTimestamp(),
                                              'user': FirebaseAuth
                                                  .instance.currentUser!.uid
                                            }).then((value) {
                                              Get.snackbar('Success',
                                                  'Keyword added to track');
                                            }).catchError((e) {
                                              Get.snackbar('Error',
                                                  'Something went wrong');
                                            });
                                          },
                                          child: Text('Track'))
                                    ],
                                  );
                                });
                          },
                          icon: Icon(Icons.add),
                          tooltip: "Track",
                        ),
                        // SizedBox(
                        //   width: 10,
                        // ),

                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.search),
                          tooltip: "Search",
                        ),
                      ],
                    ),
                    hintText: 'Search a topic such as "Covid"'),
              ),
            ),

            SizedBox(
              height: 20,
            ),
            Obx(
              () => loading.value
                  ? LottieBuilder.asset('logo.json')
                  : Container(),
            ),
            //show a sf pie chart with positive, negative sentiments
            SfCircularChart(
              title: ChartTitle(
                  text: 'Distribution of Sentiments',
                  textStyle: Get.textTheme.titleMedium!
                      .copyWith(decoration: TextDecoration.underline)),
              margin: const EdgeInsets.all(10),
              legend: Legend(
                  isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              series: <CircularSeries>[
                PieSeries<Map, String>(
                    dataSource: [
                      {
                        'Positive': ((total_positive) /
                                (total_positive + total_negative) *
                                100)
                            .ceil()
                      },
                      {
                        'Negative': ((total_negative) /
                                (total_positive + total_negative) *
                                100)
                            .floor()
                      },
                    ],
                    xValueMapper: (Map sentiment, _) => sentiment.keys.first,
                    yValueMapper: (Map sentiment, _) => sentiment.values.first,
                    dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.outside))
              ],
            ),
            const SizedBox(
              height: 20,
            ),

            //show a sf line chart using negative_line and positive_line

            SfCartesianChart(
              title: ChartTitle(
                  text: 'Sentiment Trend over time',
                  textStyle: Get.textTheme.titleMedium!
                      .copyWith(decoration: TextDecoration.underline)),
              margin: const EdgeInsets.all(32),
              zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enablePanning: true,
                  enableDoubleTapZooming: false,
                  enableSelectionZooming: true,
                  enableMouseWheelZooming: false),
              primaryXAxis: DateTimeAxis(
                  name: 'Date',
                  majorGridLines: const MajorGridLines(width: 0),
                  intervalType: DateTimeIntervalType.days,
                  dateFormat: DateFormat.yMd()),
              series: <ChartSeries>[
                LineSeries<DateTime, DateTime>(
                    dataSource: negative_line.keys.toList()
                      ..sort((a, b) => a
                          .difference(b)
                          .inDays), //sort the dates in ascending order
                    xValueMapper: (DateTime sentiment, _) => sentiment,
                    yValueMapper: (DateTime sentiment, _) =>
                        negative_line[sentiment],
                    name: 'Negative',
                    color: Colors.red),
                LineSeries<DateTime, DateTime>(
                    dataSource: positive_line.keys.toList()
                      ..sort((a, b) => a.difference(b).inDays),
                    xValueMapper: (DateTime sentiment, _) => sentiment,
                    yValueMapper: (DateTime sentiment, _) =>
                        positive_line[sentiment],
                    name: 'Positive',
                    color: Colors.green),
              ],
            ),

            SizedBox(
              height: 20,
            ),

            //create a bar chat using negativeChartData and positiveChartData
            SfCartesianChart(
              title: ChartTitle(
                  text: 'Most trending keywords',
                  textStyle: Get.textTheme.titleMedium!
                      .copyWith(decoration: TextDecoration.underline)),
              margin: const EdgeInsets.all(32),
              zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enablePanning: true,
                  enableDoubleTapZooming: true,
                  enableSelectionZooming: true,
                  enableMouseWheelZooming: true),
              series: <ChartSeries>[
                ColumnSeries(
                    dataSource: top10Keywords,
                    xValueMapper: (dynamic d, c) => d['keyword'],
                    yValueMapper: (dynamic d, c) => d['count'],
                    name: 'Positive',
                    color: Colors.green),
              ],
              primaryXAxis: CategoryAxis(),
            ),

            ExpansionTile(
              leading: Icon(Icons.info_outline),
              initiallyExpanded: true,
              title: const Text('Detailed Stats'),
              subtitle: const Text('Click to view the detailed stats'),
              onExpansionChanged: (value) {
                if (value) {
                  setState(() {
                    //add a callback after 3 seconds
                    Future.delayed(const Duration(seconds: 1), () {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.ease);
                      });
                    });
                  });
                }
              },
              children: [
                if (tableData.isNotEmpty)
                  PaginatedDataTable(
                    columns: [
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('UID')),
                      DataColumn(label: Text('Positive')),
                      DataColumn(label: Text('Negative')),
                      DataColumn(label: Text('Content'))
                    ],
                    source: TweetDataTableSource(tableData),
                  ),
              ],
            ),

            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class TweetDataTableSource extends DataTableSource {
  TweetDataTableSource(this.data);

  final List<Post> data;

  @override
  DataRow getRow(int index) {
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(data[index].date.toString())),
        DataCell(TextButton(
            onPressed: () {
              launchUrlString(data[index].url.toString());
            },
            child: Text(data[index].uid.toString()))),
        DataCell(Text(data[index].sentiment.positive.toString())),
        DataCell(Text(data[index].sentiment.negative.toString())),
        DataCell(GestureDetector(
          onTap: () {
            //show full tweet in a dialog
            showDialog(
                context: Get.context!,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Full Text'),
                    content: Text(data[index].content.toString()),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Close'))
                    ],
                  );
                });
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(data[index].content.toString()),
          ),
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
