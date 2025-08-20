class Cell {
  final int number;
  bool visited;
  bool isLocked;
  bool animateWrong = false;
  bool isHidden = false;

  Cell({
    required this.number,
    this.visited = false,
    this.isLocked = false,
    this.isHidden = false,
  });
}
