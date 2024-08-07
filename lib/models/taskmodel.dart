// ignore_for_file: public_member_api_docs, sort_constructors_first
class TaskModel {
  late String pid;
  late String asid;
  late String PrjNm;
  late String Country;
  late String State;
  late String District;
  late String Taluka;
  late String City;
  late String assignedDt;
  TaskModel({
    this.pid = '',
    required this.asid,
    required this.PrjNm,
    required this.assignedDt,
    this.State = '',
    this.City = '',
  });
}
