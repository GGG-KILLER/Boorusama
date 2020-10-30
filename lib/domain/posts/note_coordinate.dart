class NoteCoordinate {
  final double _x;
  final double _y;
  final double _width;
  final double _height;

  NoteCoordinate(this._x, this._y, this._width, this._height);

  double get x => _x;

  double get y => _y;

  double get width => _width;

  double get height => _height;

  NoteCoordinate calibrate(
      double screenHeight,
      double screenWidth,
      double screenAspectRatio,
      double postHeight,
      double postWidth,
      double postAspectRatio) {
    var aspectRatio = 1.0;
    double offset = 0;
    double newX;
    double newY;
    double newWidth;
    double newHeight;

    if (screenHeight > screenWidth) {
      if (screenAspectRatio < postAspectRatio) {
        aspectRatio = screenWidth / postWidth;
        offset = (screenHeight - aspectRatio * postHeight) / 2;
        newX = this.x * aspectRatio;
        newY = this.y * aspectRatio + offset;
      } else {
        aspectRatio = screenHeight / postHeight;
        offset = (screenWidth - aspectRatio * postWidth) / 2;
        newX = this.x * aspectRatio + offset;
        newY = this.y * aspectRatio;
      }
    } else {
      if (screenAspectRatio > postAspectRatio) {
        aspectRatio = screenHeight / postHeight;
        offset = (screenWidth - aspectRatio * postWidth) / 2;
        newX = this.x * aspectRatio + offset;
        newY = this.y * aspectRatio;
      } else {
        aspectRatio = screenWidth / postWidth;
        offset = (screenHeight - aspectRatio * postHeight) / 2;
        newX = this.x * aspectRatio;
        newY = this.y * aspectRatio + offset;
      }
    }

    newWidth = this.width * aspectRatio;
    newHeight = this.height * aspectRatio;

    return NoteCoordinate(newX, newY, newWidth, newHeight);
  }
}