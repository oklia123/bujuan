class AppRouter{
  // Note: 虽然我们从 shellRouter 中移除了 home 对应的 GoRoute（不再作为底部导航项），
  // 但保留常量以免仓库中其他地方引用 AppRouter.home 出现编译/查找错误。
  static final String home = '/';
  static final String playlist = '/playlist';
  static final String today = '/today';
  static final String splash = '/splash';
  static final String login = '/login';
  static final String user = '/user';
  static final String setting = '/setting';
  static final String mv = '/mv';
  static final String play = '/play';
}
