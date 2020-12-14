enum Board {
  on_hold,
  in_progress,
  needs_review,
  approved,
}

extension BoardExt on Board {
  String get title {
    switch(this) {
      case Board.in_progress:
        return 'In progress';
      case Board.needs_review:
        return 'Needs review';
      case Board.approved:
        return 'Approved';
      case Board.on_hold:
      default:
        return 'On hold';
    }
  }

  static Board fromString(String value) {
    switch(value) {
      case '1':
        return Board.in_progress;
      case '2':
        return Board.needs_review;
      case '3':
        return Board.approved;
      case '0':
      default:
        return Board.on_hold;
    }
  }

  int get toInt {
    switch(this) {
      case Board.in_progress:
        return 1;
      case Board.needs_review:
        return 2;
      case Board.approved:
        return 3;
      case Board.on_hold:
      default:
        return 0;
    }
  }
}