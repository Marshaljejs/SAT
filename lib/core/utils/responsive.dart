class Responsive {
  const Responsive._();

  static int gridColumns(double width) {
    if (width >= 480) {
      return 3;
    }
    return 2;
  }
}
