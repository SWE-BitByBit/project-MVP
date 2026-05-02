import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/home_view_model.dart';
import '../../core/widgets/dashboard_button_widget.dart';

class HomeDashboardWidget extends StatelessWidget {
  const HomeDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<HomeViewModel>();
    final items = viewModel.loadDashboard.value;

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: DashboardButtonWidget(
              title: item.title,
              description: item.description,
              icon: item.icon,
              backgroundColor: item.backgroundColor,
              iconColor: item.iconColor,
              onTap: () {
                Navigator.pushNamed(context, item.routeName);
              },
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
