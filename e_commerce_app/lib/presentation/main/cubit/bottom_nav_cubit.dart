enum bottomNav {home, category, search , user}

class BottomNavCubit extends Cubit<BottomNav>{
  BottomNavCubit() : super(BottomNav.home);
}