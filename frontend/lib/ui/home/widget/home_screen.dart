import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/view_model/auth_view_model.dart';

import 'home_tab_view_widget.dart'; // Il nuovo file che creeremo
import '../../core/widgets/auth_placeholder_screen.dart';

// Importa le tue vere schermate
import '../../chat/widget/chatbot_screen.dart';
import '../../diary/widget/diary_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index, bool isLoggedIn) {
    if (_currentIndex != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVm, child) {
        if (authVm.isInitializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final isLoggedIn = authVm.currentUser != null;

        return Scaffold(
          extendBody: true,

          body: Stack(
            children: [
              PageView(
                controller: _pageController,
                // onPageChanged scatta quando l'utente fa lo SWIPE con il dito
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex =
                        index;
                  });
                },
                children: [
                  // TAB 0: Chatbot
                  isLoggedIn
                      ? const ChatbotScreen()
                      : AuthPlaceholderScreen(
                          appBar: AppBar(
                            title: const Text('Assistente AI'),
                            centerTitle: true,
                          ),
                          title: 'Chat non disponibile',
                          message:
                              'Effettua l\'accesso per parlare con il nostro assistente.',
                          icon: Icons.chat_bubble_outline,
                        ),

                  // TAB 1: Home
                  const HomeTabView(),

                  // TAB 2: Diario
                  isLoggedIn
                      ? const DiaryScreen()
                      : AuthPlaceholderScreen(
                          appBar: AppBar(
                            title: const Text('Il mio Diario'),
                            centerTitle: true,
                          ),
                          title: 'Diario protetto',
                          message:
                              'Accedi per poter scrivere e conservare i tuoi pensieri nel tuo spazio privato.',
                          icon: Icons.edit_note_outlined,
                        ),
                ],
              ),
            ],
          ),

          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) => _onTabTapped(index, isLoggedIn),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.chat_bubble_outline),
                selectedIcon: const Icon(Icons.chat_bubble),
                label: 'Chatbot',
              ),
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),

              NavigationDestination(
                icon: Opacity(
                  opacity: isLoggedIn ? 1.0 : 0.4,
                  child: const Icon(Icons.edit_note_outlined),
                ),
                selectedIcon: const Icon(Icons.edit),
                label: 'Diario',
              ),
            ],
          ),
        );
      },
    );
  }
}
