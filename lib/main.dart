import 'package:async/async.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ChipsChoice',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // single choice value
  int tag = 1;

  // multiple choice value
  List<String> tags = [];

  // list of string options
  List<String> options = [
    'News',
    'Entertainment',
    'Politics',
    'Automotive',
    'Sports',
    'Education',
    'Fashion',
    'Travel',
    'Food',
    'Tech',
    'Science',
  ];

  String user;
  final usersMemoizer = AsyncMemoizer<List<C2Choice<String>>>();

  final formKey = GlobalKey<FormState>();
  List<String> formValue;

  Future<List<C2Choice<String>>> getUsers() async {
    String url =
        "https://randomuser.me/api/?inc=gender,name,nat,picture,email&results=25";
    Response res = await Dio().get(url);
    print(res);
    return C2Choice.listFrom<String, dynamic>(
      source: res.data['results'],
      value: (index, item) => item['email'],
      label: (index, item) =>
          item['name']['first'] + ' ' + item['name']['last'],
      meta: (index, item) => item,
    )..insert(0, C2Choice<String>(value: 'all', label: 'All'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter ChipsChoice'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _about(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            Expanded(
              child: ListView(
                addAutomaticKeepAlives: true,
                children: <Widget>[
                  Content(
                    title: 'Works with FormField and Validator',
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          FormField<List<String>>(
                            autovalidate: true,
                            initialValue: formValue,
                            onSaved: (val) => setState(() => formValue = val),
                            validator: (value) {
                              if (value?.isEmpty ?? value == null) {
                                return 'Please select some categories';
                              }
                              if (value.length > 5) {
                                return "Can't select more than 5 categories";
                              }
                              return null;
                            },
                            builder: (state) {
                              return Column(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: ChipsChoice<String>.multiple(
                                      value: state.value,
                                      onChanged: (val) => state.didChange(val),
                                      choiceItems:
                                          C2Choice.listFrom<String, String>(
                                        source: options,
                                        value: (i, v) => v.toLowerCase(),
                                        label: (i, v) => v,
                                        tooltip: (i, v) => v,
                                      ),
                                      choiceStyle: const C2ChoiceStyle(
                                        color: Colors.indigo,
                                        borderOpacity: .3,
                                      ),
                                      choiceActiveStyle: const C2ChoiceStyle(
                                        color: Colors.indigo,
                                        brightness: Brightness.dark,
                                      ),
                                      wrapped: true,
                                    ),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 0, 15, 10),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        state.errorText ??
                                            state.value.length.toString() +
                                                '/5 selected',
                                        style: TextStyle(
                                            color: state.hasError
                                                ? Colors.redAccent
                                                : Colors.green),
                                      ))
                                ],
                              );
                            },
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text('Selected Value:'),
                                        SizedBox(height: 5),
                                        Text('${formValue.toString()}')
                                      ]),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                RaisedButton(
                                    child: const Text('Submit'),
                                    color: Colors.blueAccent,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      // Validate returns true if the form is valid, or false otherwise.
                                      if (formKey.currentState.validate()) {
                                        // If the form is valid, save the value.
                                        formKey.currentState.save();
                                      }
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Content extends StatefulWidget {
  final String title;
  final Widget child;

  Content({
    Key key,
    @required this.title,
    @required this.child,
  }) : super(key: key);

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content>
    with AutomaticKeepAliveClientMixin<Content> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(5),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            color: Colors.blueGrey[50],
            child: Text(
              widget.title,
              style: const TextStyle(
                  color: Colors.blueGrey, fontWeight: FontWeight.w500),
            ),
          ),
          Flexible(fit: FlexFit.loose, child: widget.child),
        ],
      ),
    );
  }
}

void _about(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(
              'chips_choice',
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  .copyWith(color: Colors.black87),
            ),
            subtitle: const Text('by davigmacode'),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Flexible(
            fit: FlexFit.loose,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Easy way to provide a single or multiple choice chips.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(color: Colors.black54),
                  ),
                  Container(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
