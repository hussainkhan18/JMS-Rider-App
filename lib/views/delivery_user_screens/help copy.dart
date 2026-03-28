import 'package:flutter/material.dart';
import 'package:jms/view_models/help_viewmodel.dart';
import 'package:jms/widgets/help_video_card.dart';
import 'package:provider/provider.dart';

import '../../helper/style.dart' as style;

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HelpViewModel>().fetchHelpVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Help'),
        titleTextStyle: style.pageTitle(),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<HelpViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == HelpState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.state == HelpState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load videos'),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchHelpVideos(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Help & Tutorials',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    itemCount: viewModel.videos.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final video = viewModel.videos[index];
                      return HelpVideoCard(video: video);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
