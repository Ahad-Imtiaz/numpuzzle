class Cell {
  final int number;
  bool visited;
  bool isRed;
  bool animateWrong = false;

  Cell({required this.number, this.visited = false, this.isRed = false});
}
