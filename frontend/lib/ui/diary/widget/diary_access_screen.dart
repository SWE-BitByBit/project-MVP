import 'package:flutter/widgets.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_viewmodel.dart';
import 'package:provider/provider.dart';

class DiaryAccessScreen extends StatelessWidget {
  const DiaryAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewmodel = DiaryAccessViewmodel();
      },
      child: const DiaryAccessView(),
    );
  }
}

class DiaryAccessView extends StatelessWidget {
  const DiaryAccessView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
