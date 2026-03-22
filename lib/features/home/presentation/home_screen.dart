import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lms_app/core/presentation/theme/color_manager.dart';
import 'package:lms_app/core/presentation/theme/text_manager.dart';
import 'package:lms_app/features/chat/presentation/controllers/chat_controller.dart';
import 'package:lms_app/features/home/presentation/widgets/home_chats_list.dart';
import 'package:lms_app/features/home/presentation/widgets/home_filters_row.dart';
import 'package:lms_app/features/home/presentation/widgets/home_stats_section.dart';
import 'package:lms_app/features/home/presentation/widgets/home_top_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = ColorManager();
    AppTypography.init();
    final controllerAvailable = Get.isRegistered<ChatController>();
    final controller = controllerAvailable
        ? Get.find<ChatController>()
        : null;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                HomeTopBar(title: 'سجل المحادثات', onSearch: () {}),
                const SizedBox(height: 16),
                controller == null
                    ? const HomeStatsSection(
                        waitingCount: 0,
                        activeCount: 0,
                        closedCount: 0,
                        isLoading: false,
                      )
                    : Obx(
                        () => HomeStatsSection(
                          waitingCount:
                              controller.callCenterWaitingCount.value,
                          activeCount:
                              controller.callCenterActiveCount.value,
                          closedCount:
                              controller.callCenterClosedCount.value,
                          isLoading: controller
                              .isLoadingCallCenterDashboard
                              .value,
                        ),
                      ),
                const SizedBox(height: 14),
                const HomeFiltersRow(),
                const SizedBox(height: 10),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      if (!Get.isRegistered<ChatController>()) return;
                      await Get.find<ChatController>().refreshHome();
                    },
                    child: const HomeChatsList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
