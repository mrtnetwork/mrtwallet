enum APPIsolate {
  current,
  separate;

  bool get separateThread => this == separate;
}
