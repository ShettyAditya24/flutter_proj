import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proj/services/auth_service.dart';
import 'package:flutter_proj/services/cloudinary_services.dart';
import 'package:flutter_proj/services/db_service.dart';
import 'package:flutter_proj/views/preview_image.dart';
import 'package:flutter_proj/views/preview_video.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FilePickerResult? _filePickerResult;

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowedExtensions: ["jpg", "jpeg", "png", "mp4"],
        type: FileType.custom);
    setState(() {
      _filePickerResult = result;
    });

    if (_filePickerResult != null) {
      Navigator.pushNamed(context, "/upload", arguments: _filePickerResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Files"),
        actions: [
          IconButton(
              onPressed: () async {
                await AuthService().logout();
                Navigator.pushReplacementNamed(context, "/login");
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: StreamBuilder(
        stream: DbService().readUploadedFiles(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List userUploadedFiles = snapshot.data!.docs;
            if (userUploadedFiles.isEmpty) {
              return Center(
                child: Text("No files uploaded"),
              );
            } else {
              return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns in the grid
                    childAspectRatio: 1, // Aspect ratio for each grid item
                    crossAxisSpacing: 8, // Spacing between columns
                    mainAxisSpacing: 8, // Spacing between rows
                  ),
                  itemCount: userUploadedFiles.length,
                  itemBuilder: (context, index) {
                    String name = userUploadedFiles[index]["name"];
                    String ext = userUploadedFiles[index]["extension"];
                    String publicId = userUploadedFiles[index]["id"];
                    String fileUrl = userUploadedFiles[index]["url"];

                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text("Delete file"),
                                  content: const Text(
                                      "Are you sure you want to delete?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("No")),
                                    TextButton(
                                        onPressed: () async {
                                          final bool deleteResult =
                                              await DbService().deleteFile(
                                                  snapshot.data!.docs[index].id,
                                                  publicId);
                                          if (deleteResult) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text("File deleted"),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    "Error in deleting file."),
                                              ),
                                            );
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: Text("Yes")),
                                  ],
                                ));
                      },
                      onTap: () {
                        if (ext == "png" || ext == "jpg" || ext == "jpeg") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PreviewImage(url: fileUrl)));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PreviewVideo(videoUrl: fileUrl)));
                        }
                      },
                      child: Container(
                        color: Colors.grey.shade200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child:
                                  ext == "png" || ext == "jpg" || ext == "jpeg"
                                      ? Image.network(
                                          fileUrl,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(Icons.movie),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(ext == "png" ||
                                          ext == "jpg" ||
                                          ext == "jpeg"
                                      ? Icons.image
                                      : Icons.movie),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () async {
                                        final donwloadResult =
                                            await downloadFileFromCloudinary(
                                                fileUrl, name);
                                        if (donwloadResult) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text("File downloaded"),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  "Error in downloading the file."),
                                            ),
                                          );
                                        }
                                      },
                                      icon: Icon(Icons.download))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  });
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openFilePicker();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}