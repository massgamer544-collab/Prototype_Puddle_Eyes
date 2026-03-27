class TerrainPoint {

    final double x;
    final double y;
    final double z;

    TerrainPoint(this.x, this.y, this.z);

}

List<TerrainPoint> generateTerrain(
    double left,
    double center,
    double right) {
        return [

            TerrainPoint(-0.5, left, 1.0),
            TerrainPoint(0.0, center, 1.0),
            TerrainPoint(0.5, right, 1.0),
        ];
}