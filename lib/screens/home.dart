import 'package:flutter/material.dart';

import 'new_course.dart';
import 'course_detail.dart';
import 'course_update.dart';
import '../model/course.dart';
import '../utils/database_helper.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List> _coursesFuture;
  DatabaseHelper helper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _coursesFuture = getAllCourses();
  }

  void updateCourses() {
    _coursesFuture = getAllCourses();
  }

  Future<List<Map<String, dynamic>>> getAllCourses() async {
    return await helper.getAllCourses();
  }

  void filterSearch(String query) async {
    List<Map> searchList = await getAllCourses();
    List<Map> queryList = [];
    if (query.isNotEmpty) {
      // for(var item in searchList){
      searchList.forEach((item) {
        Course course = Course.fromMap(item);
        if (course.name.toLowerCase().contains(query.toLowerCase())) {
          queryList.add(item);
        }
      });
      _coursesFuture = Future.value(queryList);
      return;
    } else {
      updateCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite Database'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NewCourse()));
              setState(() {
                updateCourses();
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search ...',
                labelText: 'search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  filterSearch(value);
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _coursesFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                // switch (snapshot.connectionState) {
                //   case ConnectionState.done:
                //     return ListView.builder(
                //         key: UniqueKey(),
                //         itemCount: snapshot.data.length,
                //         itemBuilder: (context, index) {
                //           Course course = Course.fromMap(snapshot.data[index]);
                //           return ListTile(
                //             title: Text('${course.name} - ${course.hours} Hours'),
                //             subtitle: Text(course.content),
                //             trailing: IconButton(
                //                 icon: Icon(Icons.delete),
                //                 color: Colors.red,
                //                 onPressed: () {
                //                   setState(() {
                //                     helper.deleteCourse(course.id);
                //                   });
                //                 }),
                //           );
                //         });
                //   case ConnectionState.none:
                //   case ConnectionState.waiting:
                //   case ConnectionState.active:
                //   default:
                //     return Center(child: CircularProgressIndicator());
                // }

                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      Course course = Course.fromMap(snapshot.data[index]);
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        child: ListTile(
                          key: UniqueKey(),
                          title: Text(
                              '${course.name} - Level: ${course.level} - ${course.hours} Hours'),
                          subtitle: Text(course.content.length > 200
                              ? course.content.substring(0, 200)
                              : course.content),
                          trailing: Column(
                            children: [
                              Expanded(
                                child: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        helper.deleteCourse(course.id);
                                        updateCourses();
                                      });
                                    }),
                              ),
                              Expanded(
                                child: IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.green,
                                    ),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CourseUpdate(course),
                                        ),
                                      );
                                      setState(() {
                                        updateCourses();
                                      });
                                    }),
                              ),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseDetails(course),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
