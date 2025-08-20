class Cell {
  final int number;
  bool visited;
  bool isRed;
  bool animateWrong = false;
  bool isHidden = false;

  Cell({
    required this.number,
    this.visited = false,
    this.isRed = false,
    this.isHidden = false,
  });
}
